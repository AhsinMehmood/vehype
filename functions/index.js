const functions = require("firebase-functions");
const cors = require('cors')({ origin: true });
const nodemailer = require("nodemailer");

const admin = require('firebase-admin');
// For details and booking, please call at 0300 9464109 & 0328 4233372
// 📍Our Location:
// 4-Main Zeenat Block,Hafeez Taib Road, Allama Iqbal Town, Lahore.
//Elite Residency Lahore 
// const axios = require('axios');
admin.initializeApp();
// const ONE_SIGNAL_APP_ID = 'e236663f-f5c0-4a40-a2df-81e62c7d411f';
// const ONE_SIGNAL_API_KEY = 'NmZiZWJhZDktZGQ5Yi00MjBhLTk2MGQtMmQ5MWI1NjEzOWVi';

// const firestore = admin.firestore();



// const appPassGmail = 'ozcriypjmnmmslox';
// const mail = 'developera574@gmail.com';

const GMAIL_EMAIL = "developera574@gmail.com"; 
const GMAIL_PASSWORD = "ozcriypjmnmmslox"; 

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: GMAIL_EMAIL,
    pass: GMAIL_PASSWORD, // Use App Password here
  },
});

exports.sendPDFEmail = functions.https.onCall(async (data, context) => {
  const { pdfUrl, recipientEmail } = data;

  if (!recipientEmail || !pdfUrl) {
    throw new functions.https.HttpsError("invalid-argument", "Missing email or PDF URL.");
  }

  const mailOptions = {
    from: GMAIL_EMAIL,
    to: recipientEmail,
   subject: "Your Invoice from VEHYPE",
  text: `Hello,\n\nAttached is your invoice from VEHYPE.\n\nYou can download it here: ${pdfUrl}\n\nBest Regards,\nVEHYPE Team`
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true, message: "Email sent successfully!" };
  } catch (error) {
    console.error("Error sending email:", error);
    throw new functions.https.HttpsError("Error sending email", error);
  }
});

// exports.handleOneSignalWebhook = functions.https.onRequest(async (req, res) => {
//   try {
//     const event = req.body;

//     // Check if it's a delivery event
//     if (event.event === 'notification.delivered') {
//       const { notification_id, data } = event;

//       // Extract relevant information from the payload
//       const chatId = data.chatId; // Example: assuming your data contains chatId
//       const messageId = data.messageId; // Example: assuming your data contains messageId
//       const type = data.type;
//       if(type == 'chat'){
//             // Update the message state in Firebase Realtime Database
//       await admin.database().ref(`messages/${chatId}/${messageId}`).update({
//         state: 1, // Update state as delivered
//       });
//       }

//       console.log(`Message state updated: ${chatId}/${messageId}`);
//     }

//     res.status(200).send('Webhook processed successfully');
//   } catch (error) {
//     console.error('Error processing webhook:', error);
//     res.status(500).send('Error processing webhook');
//   }
// });


// exports.sendMessageNotification = functions.https.onCall(async (data, context) => {
//     const { chatId, messageId, title, subtitle, userIds } = data;

//     const message = {
//         notification: {
//             title: title,
//             body: subtitle,
//         },
//         data: {
//             chatId: chatId,
//             type: 'chat',
//             messageId: messageId,
//         },
//         tokens: userIds, // FCM registration tokens
//     };

//     try {
//         const response = await admin.messaging().sendMulticast(message);
//         console.log('Successfully sent message:', response);
//         return { success: true };
//     } catch (error) {
//         console.error('Error sending message:', error);
//         return { success: false, error: error.message };
//     }
// });




// exports.sendNotification = functions.https.onCall(async (data, context) => {
//     const { offerId, requestId, title, subtitle, userIds } = data;

//     const message = {
//         notification: {
//             title: title,
//             body: subtitle,
//         },
//         data: {
//             offerId: offerId,
//             type: 'request',
//             requestId: requestId || '',
//         },
//         tokens: userIds, // FCM registration tokens
//     };

//     try {
//         const response = await admin.messaging().sendMulticast(message);
//         console.log('Successfully sent message:', response);
//         return { success: true };
//     } catch (error) {
//         console.error('Error sending message:', error);
//         return { success: false, error: error.message };
//     }
// });









// // exports.notifyInactiveVehicleOwners = functions.pubsub.schedule('0 0 * * 1-5').onRun(async (context) => {
// //     const now = admin.firestore.Timestamp.now();
// //     const fourHoursAgo = new Date(now.toDate().getTime() - 4 * 60 * 60 * 1000);

// //     // Query vehicle owners who were last active more than 4 hours ago
// //     const usersSnapshot = await db.collection('users')
// //         .where('accountType', '==', 'vehicleOwner')
// //         .where('lastActive', '<=', admin.firestore.Timestamp.fromDate(fourHoursAgo))
// //         .get();

// //     // Process each user
// //     for (const userDoc of usersSnapshot.docs) {
// //         const userData = userDoc.data();
// //         const userId = userDoc.id;

// //         // Query offers collection for this user
// //         const offersSnapshot = await db.collection('offers')
// //             .where('ownerId', '==', userId)
// //             .where('status', '==', 'active')  // Assuming offers are related to the user by userId
// //             .get();

// //         // Filter offers based on checkByList condition
// //         const matchingOffers = offersSnapshot.docs.filter(offerDoc => {
// //             const offerData = offerDoc.data();
// //             const checkByList = offerData.checkByList || [];

// //             // Check if any map in checkByList meets the conditions
// //             return checkByList.some(check => 
// //                 check.checkById === userId && 
// //                 check.createdAt.toMillis() <= fourHoursAgo.getTime()
// //             );
// //         });

// //         // If there are matching offers, send a notification via OneSignal
// //         if (matchingOffers.length > 0) {
// //             const notificationPayload = {
// //                 app_id: ONE_SIGNAL_APP_ID,
// //                 include_external_user_ids: [userId], // Assuming userId is mapped to OneSignal external user ID
// //                 headings: { "en": "You have new offers to check" },
// //                 contents: { "en": "Please check the new offers in your account." },
// //             };

// //             try {
// //                 await axios.post('https://onesignal.com/api/v1/notifications', notificationPayload, {
// //                     headers: {
// //                         'Content-Type': 'application/json',
// //                         'Authorization': `Basic ${ONE_SIGNAL_API_KEY}`,
// //                     },
// //                 });
// //                 console.log(`Notification sent to user ${userId} via OneSignal`);
// //             } catch (error) {
// //                 console.error(`Failed to send notification to user ${userId} via OneSignal: `, error);
// //             }
// //         }
// //     }

// //     return null;
// // });






































// exports.sendPushNotifications = functions.https.onRequest(async (req, res) => {
//     try
//     {
//         const usersRef = admin.firestore().collection('users');
//         const snapshot = await usersRef.where('accountType', '==', 'provider').where('status', '==', 'active').get();

//         if (snapshot.empty)
//         {
//             console.log('No matching documents.');
//             return res.status(404).send('No matching documents.');
//         }

//         const userIds = [];
//         snapshot.forEach(doc => {
//             const userData = doc.data();
//             userIds.push(userData.id);
//         });

//         if (userIds.length === 0)
//         {
//             console.log('No users with OneSignal user IDs.');
//             return res.status(404).send('No users with OneSignal user IDs.');
//         }

//         const message = 'Created a new Offer';

//         const response = await axios.post('https://onesignal.com/api/v1/notifications', {
//             app_id: ONE_SIGNAL_APP_ID,
//             include_player_ids: userIds,
//             contents: { en: `${req.body.name} ${message}` }
//         }, {
//             headers: {
//                 'Content-Type': 'application/json',
//                 'Authorization': `Basic ${ONE_SIGNAL_API_KEY}`
//             }
//         });

//         console.log('Notification sent successfully:', response.data);
//         return res.status(200).send({ success: true, message: 'Notification sent successfully' });
//     } catch (error)
//     {
//         console.error('Error sending notification:', error);
//         return res.status(500).send({ success: false, error: error.message });
//     }
// });
// exports.deleteUserAccount = functions.https.onRequest(async (req, res) => {
//     const uid = req.query.uid;
//     // const currentUserID = req.query.uid;

//     try
//     {
   
      
//         await admin.auth().deleteUser(uid);

//         // Commit the Firestore batch delete
 

//         // res.status(200).send('User account deleted successfully.');
//         res.status(200).send('User account deleted successfully.');
//     } catch (error)
//     {

//         res.status(500).send('Failed to delete user account.');
//     }
// });

// // exports.updateOfferStatus = functions.firestore
// //     .document('offersReceived/{offerId}')
// //     .onCreate((snap, context) => {
// //         const offerId = context.params.offerId;
// //         const offerRef = admin.firestore().collection('offersReceived').doc(offerId);
// //         const now = new Date();
// //         const createdAt = now.toISOString();
// //         return offerRef.update({

// //             createdAt: createdAt

// //         });
// //     });

//   // const offersReceived = admin.firestore().collection('offers').doc().collection('offersReceived').where('ownerId', '==', uid);
//         /// 35116023
//         //////


//         // developer1@vehype.com

//         // Devel@per1@@
//         // Vehype@pp01
//         /////
//         // offersReceived
     



//         // firestoreDeleteBatch.delete(connectionsRed);

//         // firestoreDeleteBatch.delete(purchasesRed);
       
//         // Delete the user from Firebase Authentication