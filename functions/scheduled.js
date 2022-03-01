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

exports.cleanNotifications = functions.pubsub.schedule('every 120 minutes').onRun((context) => {
    const db = admin.firestore();
    const nowSeconds = Date.now();
    db.collection('myNotifications').get().then(querySnapshot => {
        return Promise.all(
            querySnapshot.docs.map(
                async function (doc) {
                    // delete notifications older than 2 days
                    if (nowSeconds - 1000 * doc.get('createdAt')._seconds > 1000 * 60 * 60 * 24 * 2) {
                        return doc.ref.delete()
                    }
                    return null;
                }
            )
        );
    });
    return null;
});


exports.cleanMessages = functions.pubsub.schedule('every 120 minutes').onRun((context) => {
    const nowSeconds = Date.now();
    const defaultBucket = admin.storage().bucket();
    db.collection('messages').get().then(querySnapshot => {
        return Promise.all(
            querySnapshot.docs.map(
                async function (doc) {
                    // delete messages older than 7 days
                    if (nowSeconds - 1000 * doc.get('createdAt')._seconds > 1000 * 60 * 60 * 24 * 7) {
                        if (doc.get('isMedia')) {
                            const text = doc.get('text');
                            const indexA = text.indexOf('images%2F');
                            const path = text.substring(indexA + 9, indexA + 9 + 36);
                            admin.storage().bucket(defaultBucket.name).file("images/" + path).delete();
                        }
                        return doc.ref.delete()
                    }
                    return null;
                }
            )
        );
    });
    return null;
});

exports.cleanUnverifiedUsers = functions.pubsub.schedule('every 60 minutes').onRun((context) => {
    const users = []
    const listAllUsers = (nextPageToken) => {
        // List batch of users, 1000 at a time.
        return admin.auth().listUsers(1000, nextPageToken).then((listUsersResult) => {
            listUsersResult.users.forEach((userRecord) => {
                users.push(userRecord)
            });
            if (listUsersResult.pageToken) {
                // List next batch of users.
                listAllUsers(listUsersResult.pageToken);
            }
        }).catch((error) => {
            console.log('Error listing users:', error);
        });
    };
    // Start listing users from the beginning, 1000 at a time.
    await listAllUsers();
    const unVerifiedUsers = users.filter((user) => !user.emailVerified && Math.abs(Date.parse(user.metadata.creationTime) - Date.now()) > 1000 * 60 * 30).map((user) => user.uid)

    //DELETING USERS
    return admin.auth().deleteUsers(unVerifiedUsers).then((deleteUsersResult) => {
        deleteUsersResult.errors.forEach((err) => {
            console.log(err.error.toJSON());
        });
        return true
    }).catch((error) => {
        console.log('Error deleting users:', error);
        return false
    });
});