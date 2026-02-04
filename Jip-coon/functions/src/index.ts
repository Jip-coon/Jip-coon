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
// export const onquestcreated = onDocumentCreated("Quests/{questId}", async (event) => {
//     const quest = event.data?.data();
//     if (!quest) return;

//     if (quest.assignedTo && quest.assignedTo !== quest.createdBy) {
//         const emoji = categoryEmojis[quest.category] || "✨";
//         await sendNotification(
//             quest.assignedTo,
//             "questAssigned",
//             "퀘스트가 도착했어요!",
//             `${emoji} ${quest.title}`
//         );
//     }
// });
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
    const now = new Date();

    // A. 실제 퀘스트 체크(50~60분 사이 퀘스트 조회)
    const in50Mins = new admin.firestore.Timestamp(Math.floor(now.getTime() / 1000) + 50 * 60, 0);
    const in60Mins = new admin.firestore.Timestamp(Math.floor(now.getTime() / 1000) + 60 * 60, 0);

    const realQuests = await db.collection("quests")
        .where("status", "not-in", ["completed", "approved"])
        .where("dueDate", ">=", in50Mins)
        .where("dueDate", "<=", in60Mins)
        .get();

    // B. 가상 퀘스트(템플릿) 체크
    const templates = await db.collection("questTemplates").get();

    const promises: any[] = [];

    // 실제 퀘스트 알림
    realQuests.docs.forEach(doc => {
        const q = doc.data();
        if (!q.lastNotifiedAt && q.assignedTo) {
            promises.push(sendNotification
                (q.assignedTo,
                    "deadline",
                    "마감 1시간 전! ⏰",
                    `${q.title} 잊지 말아주세요 🥺`
                ));
            promises.push(doc.ref.update({
                lastNotifiedAt: admin.firestore.Timestamp.now()
            }));
        }
    });

    // 가상 퀘스트 알림 (오늘 반복일이고, 마감 시간이 1시간 뒤인 것)
    templates.docs.forEach(doc => {
        const t = doc.data();
        // 오늘이 반복일이고 담당자가 있는지 확인
        if (t.assignedTo && isDateInRecurringTemplate(t, now)) {
            // 이미 실제 퀘스트로 변환(생성)된 게 있다면 중복 알림 방지를 위해 스킵
            const isAlreadyCreated = realQuests.docs.some(q => q.data().templateId === t.id);
            if (isAlreadyCreated) return;

            const dueTime = t.recurringDueTime.toDate();
            // 오늘 날짜의 해당 마감 시간 계산
            const todayDue = new Date(now.getFullYear(), now.getMonth(), now.getDate(), dueTime.getHours(), dueTime.getMinutes());
            const diff = (todayDue.getTime() - now.getTime()) / (1000 * 60);

            // 마감이 50~60분 남았고, 오늘 실제 퀘스트로 생성되지 않은 경우
            if (diff >= 50 && diff <= 60) {
                promises.push(sendNotification(
                    t.assignedTo,
                    "deadline",
                    "마감 1시간 전! ⏰",
                    `${t.title} 잊지 말아주세요 🥺`
                ));
            }
        }
    });

    await Promise.all(promises);
});
// export const checkdeadline = onSchedule({
//     schedule: "every 10 minutes",
//     timeZone: "Asia/Seoul",
// }, async (event) => {
//     const now = admin.firestore.Timestamp.now();
//     // 사용자님의 로직 유지: 50~60분 사이 퀘스트 조회
//     const in50Mins = new admin.firestore.Timestamp(now.seconds + 50 * 60, 0);
//     const in60Mins = new admin.firestore.Timestamp(now.seconds + 60 * 60, 0);

//     const snapshot = await db.collection("quests")
//         .where("status", "not-in", ["completed", "approved"])
//         .where("dueDate", ">=", in50Mins)
//         .where("dueDate", "<=", in60Mins)
//         .get();

//     const promises = snapshot.docs.map(async (doc) => {
//         const quest = doc.data();

//         // 이미 알림을 보냈는지 확인
//         if (quest.lastNotifiedAt) return;

//         if (quest.assignedTo) {
//             await sendNotification(
//                 quest.assignedTo,
//                 "deadline",
//                 "마감 1시간 전! ⏰",
//                 `${quest.title} 잊지 말아주세요 🥺`
//             );

//             // 알림 완료 표시
//             return doc.ref.update({ lastNotifiedAt: now });
//         }
//     });
//     await Promise.all(promises);
// });

// 3. 오늘 하루 요약 알림 (매일 오전 9시)
export const dailysummary = onSchedule({
    schedule: "0 9 * * *",
    timeZone: "Asia/Seoul",
}, async (event) => {
    const now = new Date();
    const startToday = admin.firestore.Timestamp.fromDate(new Date(now.getFullYear(), now.getMonth(), now.getDate()));
    const endToday = admin.firestore.Timestamp.fromDate(new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59));

    // 1. 오늘 마감인 실제 퀘스트
    const realQuests = await db.collection("quests")
        .where("status", "not-in", ["completed", "approved"])
        .where("dueDate", ">=", startToday).where("dueDate", "<=", endToday).get();

    // 2. 오늘 반복 주기에 해당하는 템플릿
    const templates = await db.collection("questTemplates").get();

    const userCount = new Map<string, number>();

    // 실제 퀘스트 카운트
    realQuests.docs.forEach(doc => {
        const uid = doc.data().assignedTo;
        if (uid) userCount.set(uid, (userCount.get(uid) || 0) + 1);
    });

    // 가상 퀘스트 카운트
    templates.docs.forEach(doc => {
        const t = doc.data();
        if (t.assignedTo && isDateInRecurringTemplate(t, now)) {
            // 이미 실제 퀘스트로 생성된 건 제외 (Swift의 mergeRealAndVirtualQuests 로직과 동일)
            const alreadyCreated = realQuests.docs.some(q => q.data().templateId === t.id);
            if (!alreadyCreated) {
                userCount.set(t.assignedTo, (userCount.get(t.assignedTo) || 0) + 1);
            }
        }
    });

    const promises = Array.from(userCount.entries()).map(([userId, count]) =>
        sendNotification(
            userId,
            "dailySummary",
            "오늘의 퀘스트 요약",
            `오늘 마감인 퀘스트가 ${count}개 있어요! 기분 좋게 시작해 볼까요? ☀️`
        )
    );
    await Promise.all(promises);
});
// export const dailysummary = onSchedule({
//     schedule: "0 9 * * *",  // (분 시 일 월 요일)
//     timeZone: "Asia/Seoul",
// }, async (event) => {
//     const now = new Date();
//     const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
//     const endOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59);

//     // 오늘 마감인 모든 미완료 퀘스트 가져오기
//     const snapshot = await db.collection("quests")
//         .where("status", "not-in", ["completed", "approved"])
//         .where("dueDate", ">=", admin.firestore.Timestamp.fromDate(startOfToday))
//         .where("dueDate", "<=", admin.firestore.Timestamp.fromDate(endOfToday))
//         .get();

//     // 유저별로 퀘스트 개수 카운트
//     const userQuestCount = new Map<string, number>();
//     snapshot.docs.forEach(doc => {
//         const assignedTo = doc.data().assignedTo;
//         if (assignedTo) {
//             userQuestCount.set(assignedTo, (userQuestCount.get(assignedTo) || 0) + 1);
//         }
//     });

//     const promises = Array.from(userQuestCount.entries()).map(([userId, count]) => {
//         return sendNotification(
//             userId,
//             "dailySummary",
//             "오늘의 퀘스트 요약",
//             `오늘 마감인 퀘스트가 ${count}개 있어요. 기분 좋게 시작해 볼까요? ☀️`
//         );
//     });
//     await Promise.all(promises);
// });