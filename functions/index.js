const { setGlobalOptions } = require("firebase-functions");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

setGlobalOptions({
  maxInstances: 10,
});

// =========================================================
// HEALTH TIPS
// Runs every day at 11:00 AM Sri Lanka time
// =========================================================

exports.sendHealthTips = onSchedule(
  {
    schedule: "0 11 * * *",
    timeZone: "Asia/Colombo",
  },
  async () => {
    console.log("Starting Health Tips notifications...");

    const usersSnapshot = await db
      .collection("users")
      .get();

    const messages = [];

    usersSnapshot.forEach((doc) => {
      const data = doc.data();

      const settings = data.notificationSettings;

      if (!settings) {
        return;
      }

      // Check all required settings
      if (
        settings.allowNotifications === true &&
        settings.healthTips === true &&
        settings.fcmToken
      ) {
        messages.push({
          token: settings.fcmToken,

          notification: {
            title: "💚 Health Tip",
            body:
              "Choose healthy foods and stay active to support your liver health.",
          },

          data: {
            type: "health_tip",
          },
        });
      }
    });

    if (messages.length === 0) {
      console.log("No users available for Health Tips.");
      return;
    }

    // FCM supports sending up to 500 messages per batch.
    for (let i = 0; i < messages.length; i += 500) {
      const batch = messages.slice(i, i + 500);

      const response =
        await messaging.sendEach(batch);

      console.log(
        `Health Tips: ${response.successCount} sent, ${response.failureCount} failed.`
      );
    }

    console.log("Health Tips notifications completed.");
  }
);


// =========================================================
// ROUTINE REMINDER
// Runs every day at 7:00 AM Sri Lanka time
// =========================================================

exports.sendRoutineReminder = onSchedule(
  {
    schedule: "0 7 * * *",
    timeZone: "Asia/Colombo",
  },
  async () => {
    console.log("Starting Routine Reminder notifications...");

    const usersSnapshot = await db
      .collection("users")
      .get();

    const messages = [];

    usersSnapshot.forEach((doc) => {
      const data = doc.data();

      const settings = data.notificationSettings;

      if (!settings) {
        return;
      }

      // Check all required settings
      if (
        settings.allowNotifications === true &&
        settings.routineReminder === true &&
        settings.fcmToken
      ) {
        messages.push({
          token: settings.fcmToken,

          notification: {
            title: "🏃 Routine Reminder",
            body:
              "Good morning! It's time to follow your daily routine and workout plan.",
          },

          data: {
            type: "routine_reminder",
          },
        });
      }
    });

    if (messages.length === 0) {
      console.log("No users available for Routine Reminders.");
      return;
    }

    // FCM supports sending up to 500 messages per batch.
    for (let i = 0; i < messages.length; i += 500) {
      const batch = messages.slice(i, i + 500);

      const response =
        await messaging.sendEach(batch);

      console.log(
        `Routine Reminder: ${response.successCount} sent, ${response.failureCount} failed.`
      );
    }

    console.log("Routine Reminder notifications completed.");
  }
);