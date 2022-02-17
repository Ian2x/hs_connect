// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");

if (!admin.apps.length) {
    const firebaseAdmin = admin.initializeApp({
        credential: admin.credential.applicationDefault(),
        storageBucket: 'gs://hs-connect-db0c0.appspot.com'
    });
}

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
    .document("myNotifications/{myNotificationId}")
    .onCreate(async (snap, context) => {
        const notification = snap.data();
        const notifiedUser = await realRef(notification.notifiedUserRef).get();
        const tokens = notifiedUser.get('tokens');
        if (tokens.length != 0) {
            if (!fakeRefsArrayIncludes(notifiedUser.get('blockedUserRefs'), notification.sourceUserRef) && !fakeRefsArrayIncludes(notifiedUser.get('blockedPostRefs'), notification.parentPostRef)) {
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
                return admin.messaging().sendMulticast(payload).then((response) => {
                    return true;
                });
            }
        }
        return null;
    })

exports.dmNotification = functions.firestore
    .document("messages/{messageId}")
    .onCreate(async (snap, context) => {
        const message = snap.data();
        const receiver = await realRef(message.receiverRef).get();
        const tokens = receiver.get('tokens');
        if (tokens.length != 0) {
            if (!fakeRefsArrayIncludes(receiver.get('blockedUserRefs'), message.senderRef)) {
                const sender = await realRef(message.senderRef).get();
                var body = message.text;
                if (message.isMedia) {
                    body = "(an image)"
                }
                const payload = {
                    tokens: tokens,
                    notification: {
                        title: "New message from " + sender.get("fundamentalName"),
                        body: body,
                    },
                    data: {
                        type: "dmNotification",
                        otherUserId: message.senderRef._path.segments[1],
                    },
                    apns: {
                        payload: {
                            aps: {
                                sound: "default",
                            },
                        },
                    },
                };
                return admin.messaging().sendMulticast(payload).then((response) => {
                    return true;
                });
            }
        }
        return null;
    });
