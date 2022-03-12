// firebase deploy --only functions
exports.notifications = require("./notifications");
exports.scheduled = require("./scheduled");
exports.contentModeration = require("./contentModeration");

const functions = require('firebase-functions');
const admin = require("firebase-admin");
exports.checkIfPhoneExists = functions.https.onCall((data, context) => {
    const phone = data.phone
    return admin.auth().getUserByPhoneNumber(phone)
     .then(function(userRecord){
         return true;
     })
     .catch(function(error) {
         return false;
     });
 });

exports.queryForDomains = functions.https.onCall(async (data, context) => {
    const db = admin.firestore();
    const domainsData = await db.collection('domainsData').get().catch(function(error) {
        return [];
    });
    return domainsData.docs.map((qds) => qds.id);
})
