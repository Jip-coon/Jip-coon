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
export const onquestcreated = onDocumentCreated("quests/{id}", async (event) => {
    const quest = event.data?.data();
    if (quest?.assignedTo && quest.assignedTo !== quest.createdBy) {
        const emoji = categoryEmojis[quest.category] || "✨";
        const now = Date.now();
        const dueDate = quest.dueDate.toDate().getTime();
        const diffMinutes = (dueDate - now) / (1000 * 60);

        let title = "퀘스트가 도착했어요! 🔔";
        let body = `${emoji} ${quest.title}`;

        // [추가] 생성 시점에 이미 마감이 1시간 이내라면 문구 추가
        if (diffMinutes <= 0) {
            title = "마감이 지난 퀘스트가 할당되었습니다! 🔔";
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
export const ontemplatecreated = onDocumentCreated("quest_templates/{id}", async (event) => {
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
    const templates = await db.collection("quest_templates").get();
    const nowDate = now.toDate();

    // B. 가상 퀘스트(템플릿) 체크 부분 (수정본)
    for (const doc of templates.docs) {
        const t = doc.data();

        if (t.assignedTo && isDateInRecurringTemplate(t, nowDate)) {
            // 오늘 이미 알림을 보냈다면 건너뛰기
            if (t.lastNotifiedAt) {
                const lastDate = t.lastNotifiedAt.toDate().toDateString();
                const todayDate = nowDate.toDateString();
                if (lastDate === todayDate) continue; // 날짜가 같으면 중복이므로 패스!
            }

            const isAlreadyCreated = realQuests.docs.some(q => q.data().templateId === doc.id);
            if (isAlreadyCreated) continue;

            if (t.recurringDueTime) {
                // 유저의 타임존을 가져와서 정확한 현지 마감 시각 계산
                const userSnap = await db.collection("users").doc(t.assignedTo).get();
                const userTimeZone = userSnap.data()?.timeZone || "Asia/Seoul";

                // 1. 유저 타임존 기준 '오늘' 날짜 문자열 추출 (예: "2026-02-05")
                const dateStr = new Intl.DateTimeFormat('en-CA', {
                    timeZone: userTimeZone,
                    year: 'numeric', month: '2-digit', day: '2-digit'
                }).format(nowDate);

                // 2. 템플릿의 시/분 추출
                const dueTimeDate = t.recurringDueTime.toDate();
                const hours = dueTimeDate.getHours().toString().padStart(2, '0');
                const minutes = dueTimeDate.getMinutes().toString().padStart(2, '0');

                // 3. 유저 타임존 기준의 정확한 마감 ISO 문자열 생성 후 Date 객체화
                // 예: "2026-02-05T11:45:00" -> 이 시각은 유저 타임존 기준임을 명시
                const todayDue = new Date(`${dateStr}T${hours}:${minutes}:00`);

                // 4. 현재 시간(nowDate)과의 차이 계산
                const diffMinutes = (todayDue.getTime() - nowDate.getTime()) / (1000 * 60);

                // 마감이 0~60분 사이일 때만 발송
                if (diffMinutes > 0 && diffMinutes <= 60) {
                    promises.push(sendNotification(
                        t.assignedTo,
                        "deadline",
                        "마감 1시간 전! ⏰",
                        `${t.title} 잊지 말아주세요 🥺`
                    ));

                    // 알림 발송 후 '오늘 날짜' 기록
                    promises.push(doc.ref.update({
                        lastNotifiedAt: now
                    }));
                }
            }
        }
    }

    await Promise.all(promises);
});

// 3. 오늘 하루 요약 알림 (매일 오전 9시)
export const dailysummary = onSchedule({
    schedule: "0 * * * *",
    timeZone: "UTC",
}, async (event) => {
    try {
        const now = new Date();

        // 현재 UTC 시간의 시(hour)를 가져옴
        const currentUTCHour = now.getUTCHours();

        // 모든 타임존 가져오기
        const allTimeZones = (Intl as any).supportedValuesOf
            ? (Intl as any).supportedValuesOf('timeZone')
            : ["Asia/Seoul"];

        // 현재 9시인 타임존 찾기
        const targetTimeZones = allTimeZones.filter((tz: string) => {
            try {
                const formatter = new Intl.DateTimeFormat('en-US', {
                    timeZone: tz,
                    hour: 'numeric',
                    hour12: false
                });
                const hour = parseInt(formatter.format(now));
                return hour === 9; // 9시에 알림 보내기
            } catch {
                return false;
            }
        });

        if (targetTimeZones.length === 0) {
            console.log(`현재 UTC ${currentUTCHour}시 - 9시인 타임존 없음`);
            return;
        }

        console.log(`현재 UTC ${currentUTCHour}시 - 9시인 타임존: ${targetTimeZones.join(', ')}`);

        // Firestore 'in' 쿼리는 최대 30개까지
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
        console.log(`알림 대상 사용자: ${usersToNotify.length}명`);

        // 중복 방지를 위한 처리 완료 사용자 추적
        const processedUsers = new Set<string>();

        for (const userDoc of usersToNotify) {
            const userId = userDoc.id;

            // 이미 처리한 사용자는 스킵
            if (processedUsers.has(userId)) {
                console.log(`사용자 ${userId} 이미 처리됨 - 스킵`);
                continue;
            }

            const userData = userDoc.data();
            await sendSummaryToUser(userId, userData.timeZone);
            processedUsers.add(userId);
        }

    } catch (error) {
        console.error("dailysummary 실행 중 에러:", error);
    }
});

async function sendSummaryToUser(userId: string, timeZone: string) {
    try {
        console.log(`\n=== 사용자 ${userId} 알림 처리 시작 (타임존: ${timeZone}) ===`);

        // 사용자 타임존 기준 오늘의 시작/끝 계산
        const { startToday, endToday } = getTodayRange(timeZone);

        console.log(`오늘 범위: ${startToday.toISOString()} ~ ${endToday.toISOString()}`);

        const startTs = admin.firestore.Timestamp.fromDate(startToday);
        const endTs = admin.firestore.Timestamp.fromDate(endToday);

        // 실제 퀘스트 조회
        const realQuestsSnapshot = await db.collection("quests")
            .where("assignedTo", "==", userId)
            .where("dueDate", ">=", startTs)
            .where("dueDate", "<=", endTs)
            .get();

        // 미완료 퀘스트만 필터링 (not-in은 복합 쿼리 제한이 있어서 클라이언트에서 필터링)
        const realQuests = realQuestsSnapshot.docs.filter(doc => {
            const status = doc.data().status;
            return status !== "completed" && status !== "approved";
        });

        console.log(`실제 퀘스트: ${realQuests.length}개`);
        realQuests.forEach(doc => {
            const q = doc.data();
            console.log(`  - ${q.title} (마감: ${q.dueDate?.toDate().toISOString()})`);
        });

        let count = realQuests.length;

        // 반복 템플릿 조회
        const templatesSnapshot = await db.collection("quest_templates")
            .where("assignedTo", "==", userId)
            .get();

        console.log(`템플릿: ${templatesSnapshot.size}개`);

        const todayDayOfWeek = getTodayDayOfWeek(timeZone);
        console.log(`오늘 요일: ${todayDayOfWeek} (0=일요일)`);

        templatesSnapshot.docs.forEach(doc => {
            const template = doc.data();
            const templateId = doc.id;

            // 반복 템플릿이 오늘에 해당하는지 확인
            if (shouldShowTemplateToday(template, startToday, todayDayOfWeek)) {
                // 이미 오늘 날짜로 실제 퀘스트가 생성되었는지 확인
                const alreadyCreated = realQuests.some(q => q.data().templateId === templateId);

                if (!alreadyCreated) {
                    count++;
                    console.log(`  + 가상 퀘스트 추가: ${template.title}`);
                } else {
                    console.log(`  - 이미 생성됨: ${template.title}`);
                }
            }
        });

        console.log(`최종 카운트: ${count}개`);

        // 알림 발송
        if (count > 0) {
            await sendNotification(
                userId,
                "dailySummary",
                "오늘의 퀘스트 요약 ☀️",
                `오늘 마감인 퀘스트가 ${count}개 있어요! 기분 좋게 시작해 볼까요?`
            );
            console.log(`✅ 알림 발송 완료`);
        } else {
            console.log(`📭 오늘 마감 퀘스트 없음 - 알림 미발송`);
        }

    } catch (error) {
        console.error(`사용자 ${userId} 알림 처리 중 에러:`, error);
    }
}

/**
 * 사용자 타임존 기준으로 오늘의 시작(00:00:00)과 끝(23:59:59.999)을 반환
 */
function getTodayRange(timeZone: string): { startToday: Date; endToday: Date } {
    const now = new Date();

    // 사용자 타임존의 현재 날짜 문자열 (YYYY-MM-DD)
    const dateStr = new Intl.DateTimeFormat('en-CA', {
        timeZone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    }).format(now);

    // 사용자 타임존의 오늘 00:00:00 ISO 문자열 생성
    const localMidnight = `${dateStr}T00:00:00`;

    // 이 문자열을 Date로 변환 (타임존 정보 포함)
    // 예: "2026-02-06T00:00:00" in Asia/Seoul
    const parts = localMidnight.match(/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/);
    if (!parts) throw new Error("날짜 파싱 실패");

    const [, year, month, day] = parts;

    // 해당 타임존에서 이 날짜/시간이 의미하는 UTC 시각을 계산
    // Intl.DateTimeFormat으로 역산
    const testDate = new Date(`${year}-${month}-${day}T12:00:00Z`);
    const formatter = new Intl.DateTimeFormat('en-US', {
        timeZone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    });

    const formatted = formatter.format(testDate);
    const match = formatted.match(/(\d{2})\/(\d{2})\/(\d{4}),?\s*(\d{2}):(\d{2}):(\d{2})/);
    if (!match) throw new Error("시간 파싱 실패");

    const [, m, d, y, h, min, s] = match;
    const localDate = new Date(`${y}-${m}-${d}T${h}:${min}:${s}Z`);
    const offset = testDate.getTime() - localDate.getTime();

    // 자정 계산
    const midnightUTC = new Date(`${year}-${month}-${day}T00:00:00Z`);
    const startToday = new Date(midnightUTC.getTime() + offset);

    // 23:59:59.999
    const endToday = new Date(startToday.getTime() + 24 * 60 * 60 * 1000 - 1);

    return { startToday, endToday };
}

/**
 * 사용자 타임존 기준으로 오늘의 요일 반환 (0=일요일, 6=토요일)
 */
function getTodayDayOfWeek(timeZone: string): number {
    const now = new Date();
    const dateStr = new Intl.DateTimeFormat('en-CA', {
        timeZone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    }).format(now);

    // 임시 Date 객체로 요일 계산 (UTC 기준이지만 날짜만 맞으면 요일은 동일)
    const tempDate = new Date(dateStr + 'T00:00:00Z');
    return tempDate.getUTCDay();
}

/**
 * 반복 템플릿이 오늘 표시되어야 하는지 확인
 */
function shouldShowTemplateToday(
    template: any,
    todayStart: Date,
    todayDayOfWeek: number
): boolean {
    const { recurringType, selectedRepeatDays, startDate, recurringEndDate } = template;

    // 반복 타입이 없으면 false
    if (!recurringType || recurringType === "none") {
        return false;
    }

    // 시작일 확인
    const start = startDate?.toDate ? startDate.toDate() : new Date(startDate);
    if (todayStart < start) {
        console.log(`    템플릿 ${template.title}: 시작일 이전`);
        return false;
    }

    // 종료일 확인
    if (recurringEndDate) {
        const end = recurringEndDate.toDate ? recurringEndDate.toDate() : new Date(recurringEndDate);
        if (todayStart > end) {
            console.log(`    템플릿 ${template.title}: 종료일 이후`);
            return false;
        }
    }

    // 요일 확인 (주간 반복인 경우)
    if (recurringType === "weekly" && selectedRepeatDays && selectedRepeatDays.length > 0) {
        const isMatchingDay = selectedRepeatDays.includes(todayDayOfWeek);
        console.log(`    템플릿 ${template.title}: 요일 체크 ${isMatchingDay} (오늘=${todayDayOfWeek}, 반복요일=${selectedRepeatDays})`);
        return isMatchingDay;
    }

    // 일간 반복
    if (recurringType === "daily") {
        console.log(`    템플릿 ${template.title}: 매일 반복`);
        return true;
    }

    // 월간 반복 (추가 구현 필요)
    if (recurringType === "monthly") {
        // 예: 매월 같은 날짜에 반복
        const startDay = start.getUTCDate();
        const todayDay = todayStart.getUTCDate();
        console.log(`    템플릿 ${template.title}: 월간 반복 체크 ${startDay === todayDay}`);
        return startDay === todayDay;
    }

    return false;
}