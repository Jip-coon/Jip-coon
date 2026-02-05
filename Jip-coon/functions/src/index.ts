import { setGlobalOptions } from "firebase-functions/v2";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// 전역 설정: 서울 리전으로 고정
setGlobalOptions({ region: "asia-northeast3" });

type NotificationType = "questAssigned" | "deadline" | "dailySummary";

// --- 카테고리별 이모지 매핑 ---
const categoryEmojis: { [key: string]: string } = {
    cleaning: "🧹",
    cooking: "👨‍🍳",
    laundry: "👕",
    dishes: "🍽️",
    trash: "🗑️",
    pet: "🐕",
    study: "📚",
    exercise: "💪",
    other: "📝"
};

// --- 헬퍼: 특정 날짜가 반복 요일에 포함되는지 확인 ---
function isDateInRecurringTemplate(template: any, targetDate: Date): boolean {
    const calendar = new Date(targetDate);
    const dayOfWeek = calendar.getDay(); // 0(일)~6(토)

    // 1. 제외된 날짜인지 확인
    if (template.excludedDates) {
        const isExcluded = template.excludedDates.some((exDate: admin.firestore.Timestamp) =>
            exDate.toDate().toDateString() === targetDate.toDateString()
        );
        if (isExcluded) return false;
    }

    // 2. 시작일 이후인지, 종료일 이전인지 확인
    const startDate = template.startDate.toDate();
    if (targetDate < new Date(startDate.setHours(0, 0, 0, 0))) return false;
    if (template.recurringEndDate && targetDate > template.recurringEndDate.toDate()) return false;

    // 3. 반복 요일에 포함되는지 확인
    return template.selectedRepeatDays.includes(dayOfWeek);
}

// --- 헬퍼 함수: 특정 유저의 FCM 토큰으로 알림 보내기 ---
async function sendNotification(
    userId: string,
    type: NotificationType,
    title: string,
    body: string
) {
    const userRef = db.collection("users").doc(userId);
    const userSnap = await userRef.get();
    const user = userSnap.data();

    if (!user) return;

    // 1. 알림 설정 체크 (설정이 없거나 false면 중단)
    const setting = user.notificationSetting || {};
    if (setting[type] === false) return;

    // 2. 토큰 체크
    const tokens: string[] = user.fcmTokens || (user.fcmToken ? [user.fcmToken] : []);
    if (tokens.length === 0) return;

    // 3. badge 누적 및 DB 업데이트
    const newBadge = (user.badgeCount || 0) + 1;

    const message = {
        tokens,
        notification: { title, body },
        apns: {
            payload: {
                aps: {
                    sound: "default",
                    badge: newBadge
                }
            }
        }
    };

    try {
        // 여러 기기에 동시 발송 (Multicast)
        await admin.messaging().sendEachForMulticast(message);
        // 발송 성공 시 DB의 배지 카운트 업데이트
        await userRef.update({ badgeCount: newBadge });
    } catch (error) {
        console.error("FCM 전송 실패:", error);
    }
}

// 1. 새로운 퀘스트 할당 알림
export const onquestcreated = onDocumentCreated("quests/{questId}", async (event) => {
    const quest = event.data?.data();
    if (quest?.assignedTo && quest.assignedTo !== quest.createdBy) {
        const emoji = categoryEmojis[quest.category] || "✨";
        const now = Date.now();
        const dueDate = quest.dueDate.toDate().getTime();
        const diffMinutes = (dueDate - now) / (1000 * 60);

        let title = "퀘스트가 도착했어요!";
        let body = `${emoji} ${quest.title}`;

        // [추가] 생성 시점에 이미 마감이 1시간 이내라면 문구 추가
        if (diffMinutes <= 0) {
            title = "마감이 지난 퀘스트가 할당되었습니다! ⚠️";
        } else if (diffMinutes <= 60) {
            title = "마감 임박 퀘스트 도착! 🚨";
            body = `${emoji} ${quest.title} 퀘스트가 1시간도 남지 않았어요!`;
        }

        await sendNotification(
            quest.assignedTo,
            "questAssigned",
            title,
            body
        );
    }
});

// 새로운 반복 퀘스트 할당
export const ontemplatecreated = onDocumentCreated("questTemplates/{templateId}", async (event) => {
    const template = event.data?.data();
    if (template?.assignedTo && template.assignedTo !== template.createdBy) {
        const emoji = categoryEmojis[template.category] || "✨";
        await sendNotification(
            template.assignedTo,
            "questAssigned",
            "퀘스트가 도착했어요!",
            `${emoji} ${template.title}`
        );
    }
});

// 2. 마감 1시간 전 체크 (매 10분마다 실행하여 누락 방지)
export const checkdeadline = onSchedule({
    schedule: "every 10 minutes",
    timeZone: "Asia/Seoul",
}, async (event) => {
    // 1. 기준 시간 설정
    const now = admin.firestore.Timestamp.now();
    const nowSeconds = now.seconds;

    // 마감 임박 기준: 현재로부터 60분 이내 (안전하게 61분으로)
    const oneHourLater = new admin.firestore.Timestamp(nowSeconds + 61 * 60, 0);

    // A. 실제 퀘스트 체크
    const realQuests = await db.collection("quests")
        .where("status", "not-in", ["completed", "approved"])
        .where("dueDate", ">", now) // 이미 지난 건 제외
        .where("dueDate", "<=", oneHourLater)
        .get();

    const promises: any[] = [];

    // 실제 퀘스트 알림 처리
    realQuests.docs.forEach(doc => {
        const q = doc.data();

        // 이미 알림을 보낸 적이 없는 경우에만 발송
        if (!q.lastNotifiedAt && q.assignedTo) {
            promises.push(sendNotification(
                q.assignedTo,
                "deadline",
                "마감 1시간 전! ⏰",
                `${q.title} 잊지 말아주세요 🥺`
            ));

            // 알림 발송 기록 저장 (중복 발송 방지)
            promises.push(doc.ref.update({
                lastNotifiedAt: now
            }));
        }
    });

    // B. 가상 퀘스트(템플릿) 체크
    const templates = await db.collection("questTemplates").get();
    const nowDate = now.toDate();

    templates.docs.forEach(doc => {
        const t = doc.data();

        // 오늘 반복일인지 확인
        if (t.assignedTo && isDateInRecurringTemplate(t, nowDate)) {
            // 이미 실제 퀘스트로 변환된 건 스킵
            const isAlreadyCreated = realQuests.docs.some(q => q.data().templateId === t.id);
            if (isAlreadyCreated) return;

            if (t.recurringDueTime) {
                const dueTime = t.recurringDueTime.toDate();
                const todayDue = new Date(nowDate.getFullYear(), nowDate.getMonth(), nowDate.getDate(), dueTime.getHours(), dueTime.getMinutes());

                const diffSeconds = (todayDue.getTime() / 1000) - nowSeconds;
                const diffMinutes = diffSeconds / 60;

                // 마감이 0~60분 사이이고, 오늘 이 템플릿으로 알림을 보낸 적이 없는지 체크
                if (diffMinutes > 0 && diffMinutes <= 60) {
                    promises.push(sendNotification(
                        t.assignedTo,
                        "deadline",
                        "마감 1시간 전! ⏰",
                        `${t.title} 잊지 말아주세요 🥺`
                    ));
                }
            }
        }
    });

    await Promise.all(promises);
});

// 3. 오늘 하루 요약 알림 (매일 오전 9시)
export const dailysummary = onSchedule({
    schedule: "0 * * * *",
    timeZone: "UTC",
}, async (event) => {
    try {
        const now = new Date();
        const allTimeZones = (Intl as any).supportedValuesOf
            ? (Intl as any).supportedValuesOf('timeZone')
            : ["Asia/Seoul"];

        // 1. 해당 오프셋을 사용하는 타임존 이름 리스트 가져오기
        // (Intl을 사용하여 전 세계 타임존 중 현재 9시인 곳들을 필터링)
        const targetTimeZones = allTimeZones.filter((tz: string) => {
            try {
                const hour = parseInt(new Intl.DateTimeFormat('en-US', {
                    timeZone: tz,
                    hour: 'numeric',
                    hour12: false
                }).format(now));
                return hour === 9;
            } catch { return false; }
        });

        // 만약 현재 9시인 지역이 없다면 (드물지만) 종료
        if (targetTimeZones.length === 0) return;

        // 2. DB 쿼리 최적화: 9시인 타임존에 속한 유저만 '한 번에' 가져오기
        // Firestore 'in' 쿼리는 한 번에 최대 30개까지만 가능하므로 나눠서 처리
        const chunks = [];
        for (let i = 0; i < targetTimeZones.length; i += 30) {
            chunks.push(targetTimeZones.slice(i, i + 30));
        }

        const snapshots = await Promise.all(
            chunks.map(chunk => {
                if (!chunk || chunk.length === 0) return Promise.resolve({ docs: [] });

                return db.collection("users")
                    .where("notificationSetting.dailySummary", "==", true)
                    .where("timeZone", "in", chunk)
                    .get();
            })
        );

        const usersToNotify = snapshots.flatMap(s => s.docs);

        // 대상자가 있을 때만 실행
        if (usersToNotify.length > 0) {
            await Promise.all(usersToNotify.map(userDoc =>
                sendSummaryToUser(userDoc.id, userDoc.data().timeZone)
            ));
        }

    } catch (error) {
        console.error("dailysummary 실행 중 에러:", error);
    }
});

// 특정 유저의 타임존에 맞춰 오늘 마감인 퀘스트 개수를 계산하고 알림을 보냅니다.
async function sendSummaryToUser(userId: string, timeZone: string) {
    const now = new Date();

    // 1. 해당 타임존의 '오늘' 날짜를 YYYY-MM-DD 형식으로 추출
    const formatter = new Intl.DateTimeFormat('en-CA', {
        timeZone: timeZone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    });
    const dateStr = formatter.format(now); // 예: "2026-02-06"

    // 2. 해당 타임존 기준 오늘의 시작(00:00:00)과 끝(23:59:59) 생성
    const startToday = new Date(`${dateStr}T00:00:00`);
    const endToday = new Date(`${dateStr}T23:59:59`);

    const startTs = admin.firestore.Timestamp.fromDate(startToday);
    const endTs = admin.firestore.Timestamp.fromDate(endToday);

    // 3. 실제 퀘스트 조회 (본인에게 할당된 미완료 퀘스트)
    const realQuests = await db.collection("quests")
        .where("assignedTo", "==", userId)
        .where("status", "not-in", ["completed", "approved"])
        .where("dueDate", ">=", startTs)
        .where("dueDate", "<=", endTs)
        .get();

    let count = realQuests.size;

    // 4. 가상 퀘스트(반복 템플릿) 체크
    const templates = await db.collection("questTemplates")
        .where("assignedTo", "==", userId)
        .get();

    templates.docs.forEach(doc => {
        const t = doc.data();
        // 오늘이 반복 요일에 해당하고, 아직 실제 퀘스트로 생성되지 않은 경우 카운트
        if (isDateInRecurringTemplate(t, now)) {
            const alreadyCreated = realQuests.docs.some(q => q.data().templateId === t.id);
            if (!alreadyCreated) {
                count++;
            }
        }
    });

    // 5. 알림 발송 (개수가 0보다 클 때만)
    if (count > 0) {
        await sendNotification(
            userId,
            "dailySummary",
            "오늘의 퀘스트 요약 ☀️",
            `오늘 마감인 퀘스트가 ${count}개 있어요! 기분 좋게 시작해 볼까요?`
        );
    }
}
