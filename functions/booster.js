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

// exports.boostPostLikes = functions.pubsub.schedule('every 15 minutes').onRun((context) => {
//     const db = admin.firestore();
//     const nowSeconds = Date.now();
//     db.collection('posts').where('createdAt', '>', nowSeconds - 1000 * 60 * 60 * 24).get().then(querySnapshot => {
//         return Promise.all(
//             querySnapshot.docs.map(
//                 async function (doc) {
//                     // delete notifications older than 2 days
//                     if (nowSeconds - 1000 * doc.get('createdAt')._seconds > 1000 * 60 * 60 * 24 * 2) {
//                         return doc.ref.delete()
//                     }
//                     return null;
//                 }
//             )
//         );
//     });
//     return null;
// });