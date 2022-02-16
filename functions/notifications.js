// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();

async function notificationTitle(notification) {
    switch (notification.myNotificationType) {
        case "commentToPost":
            var sourceUser = await realRef(notification.sourceUserRef).get();
            if (!sourceUser.exists) {
                return "Someone commented on your post";
            } else {
                return sourceUser.get("fundamentalName") + " commented on your post:";
            }
        case "replyToReply":
            var sourceUser = await realRef(notification.sourceUserRef).get();
            if (!sourceUser.exists) {
                return "Someone replied after you";
            } else {
                return sourceUser.get("fundamentalName") + " replied after you:";
            }
        case "replyToComment":
            var sourceUser = await realRef(notification.sourceUserRef).get();
            if (!sourceUser.exists) {
                return "Someone replied to your comment";
            } else {
                return sourceUser.get("fundamentalName") + " replied to your comment:";
            }
        case "replyVotes":
            return "";
        case "commentVotes":
            return "";
        case "postVotes":
            return "";
        case "fromMe":
            return "The team at Circles.co have a message:";
        case "featuredPost":
            return "Featured post:";
        default:
            return "[Error: unknown notification]";
    }
}

function realRef(fakeRef) {
    return admin.firestore().collection(fakeRef._path.segments[0]).doc(fakeRef._path.segments[1]);
}

function notificationBody(notification) {
    switch (notification.myNotificationType) {
        case "commentToPost":
            return notification.extraData;
        case "replyToReply":
            return notification.extraData;
        case "replyToComment":
            return notification.extraData;
        case "replyVotes":
            return "Your reply got " + notification.extraData + " likes!";
        case "commentVotes":
            return "Your comment got " + notification.extraData + " likes!";
        case "postVotes":
            return "Your post got " + notification.extraData + " likes!";
        case "fromMe":
            return notification.extraData;
        case "featuredPost":
            return notification.extraData;
        default:
            return "[Error: unknown notification]";
    }
}

function notificationArrayIncludes(notificationArray, notification) {
    const length = notificationArray.length;
    for (var i = 0; i < length; i++) {
        const testNotification = notificationArray[i];
        if (testNotification.createdAt._seconds == notification.createdAt._seconds &&
            testNotification.createdAt._nanoseconds == notification.createdAt._nanoseconds &&
            testNotification.extraData == notification.extraData) {
            return true;
        }
    }
    return false;
}

function userMessageArrayIncludes(userMessagesArray, userMessage) {
    const length = userMessagesArray.length;
    for (var i = 0; i < length; i++) {
        const testUserMessage = userMessagesArray[i];
        if (testUserMessage.otherUserRef._path.segments[1] == userMessage.otherUserRef._path.segments[1] &&
            testUserMessage.lastMessage._seconds == userMessage.lastMessage._seconds &&
            testUserMessage.lastMessage._nanoseconds == userMessage.lastMessage._nanoseconds) {
            return true;
        }
    }
    return false;
}

function fakeRefsArrayIncludes(fakeRefsArray, fakeRef) {
    const length = fakeRefsArray.length;
    for (var i = 0; i< length; i++) {
        const testFakeRef = fakeRefsArray[i];
        if (testFakeRef._path.segments[0]==fakeRef._path.segments[0] &&
            testFakeRef._path.segments[1]==fakeRef._path.segments[1]) {
            return true;
        }
    }
    return false;
}

exports.contentNotifications = functions.firestore
    .document("userData/{userId}")
    .onUpdate((change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();
        if (newData.hasOwnProperty("tokens")) {
            const tokens = newData.tokens;
            if (tokens.length != 0) {
                const newMyNotifications = newData.myNotifications;
                const oldMyNotifications = oldData.myNotifications;
                if (newMyNotifications.length != oldMyNotifications.length) {
                    const newNotifications = newMyNotifications.filter(x => !notificationArrayIncludes(oldMyNotifications, x));
                    newNotifications.forEach(
                        async function (notification) {
                            if (!fakeRefsArrayIncludes(newData.blockedUserRefs, notification.sourceUserRef) && !fakeRefsArrayIncludes(newData.blockedPostRefs, notification.parentPostRef)) {
                                const payload = {
                                    tokens: tokens,
                                    notification: {
                                        title: await notificationTitle(notification),
                                        body: notificationBody(notification),
                                    },
                                    data: {
                                        type: "contentNotification",
                                        postId: notification.parentPostRef._path.segments[1],
                                    },
                                    apns: {
                                        payload: {
                                            aps: {
                                                sound: "default",
                                            },
                                        },
                                    },
                                };
                                return await admin.messaging().sendMulticast(payload).then((response) => {
                                    return true;
                                });
                            }
                        }
                    );
                }
            }
        }
    });

exports.dmNotification = functions.firestore
    .document("userData/{userId}")
    .onUpdate((change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();
        if (newData.hasOwnProperty("tokens")) {
            const tokens = newData.tokens;
            if (tokens.length != 0) {
                const newUserMessages = newData.userMessages;
                const oldUserMessages = oldData.userMessages;
                const newMessages = newUserMessages.filter(x => !userMessageArrayIncludes(oldUserMessages, x));
                newMessages.forEach(async function (message) {
                    if (!fakeRefsArrayIncludes(newData.blockedUserRefs, message.otherUserRef)) {
                        const otherUser = await realRef(message.otherUserRef).get();
                        const payload = {
                            tokens: tokens,
                            notification: {
                                title: "",
                                body: "New message from " + otherUser.get("fundamentalName"),
                            },
                            data: {
                                type: "dmNotification",
                                otherUserId: message.otherUserRef._path.segments[1],
                            },
                            apns: {
                                payload: {
                                    aps: {
                                        sound: "default",
                                    },
                                },
                            },
                        };
                        return await admin.messaging().sendMulticast(payload).then((response) => {
                            return true;
                        });
                    }
                });

            }
        }
    });
