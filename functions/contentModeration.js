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

var Filter = require("bad-words");

var badWordsFilter = new Filter({ emptyList: true });

var badWords = ['nigger', 'nigga', 'chink', 'faggot', 'fag', 'sped', 'retard', 'retarded', 'ianbad'];

badWordsFilter.addWords(...badWords);

function moderateMessage(message) {
    // Moderate if the user uses SwearWords.
    if (containsSwearwords(message)) {
        message = moderateSwearwords(message);
    }
    return message;
}

// Returns true if the string contains swearwords.
function containsSwearwords(message) {
    return message !== badWordsFilter.clean(message);
}

// Hide all swearwords. e.g: Crap => ****.
function moderateSwearwords(message) {
    return badWordsFilter.clean(message);
}

exports.postModerator = functions.firestore
    .document("posts/{postId}")
    .onCreate((snap, context) => {
        const post = snap.data();

        // Run moderation checks on on the post and moderate if needed.
        const moderatedTitle = moderateMessage(post.title);
        var moderatedText;
        if (post.hasOwnProperty('text') && post.text != "") {
            moderatedText = moderateMessage(post.text);
        } else {
            moderatedText = post.text;
        }

        if (post.title != moderatedTitle || post.text != moderatedText) {
            return snap.ref.update({
                title: moderatedTitle,
                text: moderatedText,
                moderated: true,
                mature: true
            });
        } else {
            return false;
        }
    });

exports.commentModerator = functions.firestore
    .document("comments/{commentId}")
    .onCreate((snap, context) => {
        const comment = snap.data();

        // Run moderation checks on on the comment and moderate if needed.
        const moderatedText = moderateMessage(comment.text);
        if (comment.text != moderatedText) {
            return snap.ref.update({
                text: moderatedText,
                moderated: true,
            });
        } else {
            return false;
        }
    });

exports.repliesModerator = functions.firestore
    .document("replies/{replyId}")
    .onCreate((snap, context) => {
        const reply = snap.data();

        // Run moderation checks on on the comment and moderate if needed.
        const moderatedText = moderateMessage(reply.text);
        if (reply.text != moderatedText) {
            return snap.ref.update({
                text: moderatedText,
                moderated: true,
            });
        } else {
            return false;
        }
    });