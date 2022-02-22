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
