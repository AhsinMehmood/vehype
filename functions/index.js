const { onCall, HttpsError, onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const cors = require('cors')({ origin: true });
const nodemailer = require("nodemailer");
const { google } = require('googleapis');
const admin = require('firebase-admin');
const { onMessagePublished } = require("firebase-functions/v2/pubsub");
const GOOGLE_PLAY_KEY = defineSecret('GOOGLE_PLAY_KEY');

admin.initializeApp();

exports.deleteUserAccount = onRequest(async (req, res) => {
  const uid = req.query.uid;
  // const currentUserID = req.query.uid;

  try
  {
 
    
      await admin.auth().deleteUser(uid);

      // Commit the Firestore batch delete


      // res.status(200).send('User account deleted successfully.');
      res.status(200).send('User account deleted successfully.');
  } catch (error)
  {

      res.status(500).send('Failed to delete user account.');
  }
});








exports.handleSubscriptionNotifications = onMessagePublished({
  topic: 'projects/vehype-386313/topics/play-subscription-updates', // Replace with your Pub/Sub topic name
}, async (event) => {
  try {
    const message = event.data.message;
    if (!message || !message.data) {
      console.error("No message data received");
      return;
    }

    const decodedData = Buffer.from(message.data, 'base64').toString('utf8');
    const notification = JSON.parse(decodedData);

    console.log("Received RTDN:", notification);

    if (notification.subscriptionNotification) {
      const purchaseToken = notification.subscriptionNotification.purchaseToken;
      const notificationType = notification.subscriptionNotification.notificationType; // Define notificationType

      console.log(`Purchase Token: ${purchaseToken}`);
      console.log(`Notification Type: ${notificationType}`);

      const status = statusFromNotificationType(notificationType); // Get status from notification type

      await updateUserPlan(purchaseToken, status); // Call updateUserPlan with purchaseToken and status

    } else if (notification.testNotification) {
      console.log("Received test notification");
    }

  } catch (error) {
    console.error("Error processing Pub/Sub message:", error);
  }
});


function statusFromNotificationType(notificationType) {
  switch (notificationType) {
    case 1: // Subscription Recovered
    return 'active';
    case 2: // Subscription Renewed
    return 'active';
    case 3: // Subscription Canceled
      return 'cancelled';
    case 4: // Subscription Purchased (Initial purchase)
    return 'active';
    case 5: // Subscription Expired
    return 'expired';
    case 6: // Subscription Reactivated
    return 'active';
    case 7: // Subscription in Grace Period
    return 'active';
    case 8: // Subscription on Hold
    return 'pause';
    case 15: // Subscription resumed
      return 'active';
    case 13: // Subscription paused
      return 'paused';
    case 16: // Subscription revoked
      return 'revoked';
    default:
      return 'unknown';
  }
}
async function updateUserPlan(purchaseToken, status) {
  console.log(`Updating user plan. PurchaseToken: ${purchaseToken}, Status: ${status}`);

  if (typeof status !== 'string') {
    console.error(`Invalid status received:`, status);
    return; // Stop early to prevent .includes error
  }

  const userSnapshot = await admin.firestore()
    .collection('users')
    .where('purchaseToken', '==', purchaseToken)
    .get();

  if (userSnapshot.empty) {
    console.warn(`No user found with purchaseToken: ${purchaseToken}`);
    return;
  }

  const userDoc = userSnapshot.docs[0];
  const userId = userDoc.data().userId;
  const userDocRef = admin.firestore().collection('users').doc(userId);

  // const cancellationStatuses = ['cancelled', 'expired', 'paused', 'revoked'];
  let planToUpdate;

  if (status == 'cancelled') {
    planToUpdate = 'free';
  } else if (status == 'expired') {
    planToUpdate = 'free';
  }
  else if (status == 'paused') {
    planToUpdate = 'free';
  } else if (status == 'revoked') {
    planToUpdate = 'free';
  } else {
    console.warn(`Unhandled subscription status: ${status}`);
    return;
  }

  await userDocRef.update({ plan: planToUpdate });
  console.log(`Successfully updated user ${userId} to plan: ${planToUpdate}`);
}









/**
 * @typedef {object} VerifyPurchaseData
 * @property {string} purchaseToken
 * @property {string} productId
 * @property {string} userId
 */

/**
 * @typedef {object} Purchase
 * @property {number} purchaseState
 * @property {number} [consumptionState]
 * @property {number} [acknowledgementState]
 * @property {string} [kind]
 * @property {string} [obfuscatedExternalProfileId]
 * @property {string} [obfuscatedExternalAccountId]
 * @property {string} [purchaseTimeMillis]
 * @property {number} [purchaseType]
 * @property {number} [quantity]
 * @property {string} [profileId]
 * @property {string} [profileName]
 * @property {string} [regionCode]
 */

// Firebase Cloud Function to verify purchase
exports.verifyPurchase = onCall(
  { secrets: [GOOGLE_PLAY_KEY] },
  async (request) => {
    const { purchaseToken, productId, userId } = request.data;
    const googlePlay = google.androidpublisher('v3');
    // const corsHandler = cors({ origin: true });
    console.log("Request Data:", request.data);
    // Your Google Play API credentials
    const packageName = 'com.nomadllc.vehype';

    const serviceAccountKey = JSON.parse(GOOGLE_PLAY_KEY.value());

    try {
      const auth = new google.auth.JWT({
        email: serviceAccountKey.client_email,
        key: serviceAccountKey.private_key,
        scopes: ['https://www.googleapis.com/auth/androidpublisher'],
      });
      console.log("Package Name:", packageName);
      console.log("Product ID:", productId);
      console.log("Purchase Token:", purchaseToken);
      // Verify the purchase with Google Play Developer API
      const response = await googlePlay.purchases.products.get({
        auth,
        packageName,
        productId,
        token: purchaseToken,
      });

      /** @type {Purchase} */
      const purchase = response.data;

      // If the purchase is valid (purchaseState === 0 means successful)
      if (purchase.purchaseState === 0) {
        console.log(`Purchase successful for ${userId}`);

        // Update user’s subscription plan in Firestore
        // await updateUserPlan(userId, purchase, productId);
        return { status: 'success', message: 'Purchase verified and user plan updated.' };
      } else {
        console.log(`Purchase not successful for ${userId}. Purchase state: ${purchase.purchaseState}`);
        throw new HttpsError('invalid-argument', 'Purchase not successful.', purchase);
      }
    } catch (error) {
      console.error('Error verifying purchase:', error);
      if (error instanceof HttpsError) {
        throw error;
      } else if (error.response) { // Log the detailed error response
        console.error('Detailed Google Play API Error:', error.response.data);
        throw new HttpsError('unknown', 'Error verifying purchase with Google Play.', error.response.data.error);
      } else {
        throw new HttpsError('unknown', 'An unexpected error occurred while verifying the purchase.', error);
      }
    }
  }
);



async function updateUserPlan(userId, purchase, productId) {
  const userRef = admin.firestore().collection('users').doc(userId);

  // Determine the plan type based on productId
  let plan = 'free';
  if (productId.includes('pro')) {
    plan = 'pro';
  } else if (productId.includes('business')) {
    plan = 'business';
  }


  const duration = productId.includes('yearly') ? 'yearly' : 'monthly';

  await userRef.update({
    plan: plan,
    duration: duration,
    productId: productId,
    purchaseToken: purchase.purchaseToken,
    purchaseTime: purchase.purchaseTime,
    expirationTime: purchase.expirationTime || null,
  });

  console.log(`User ${userId} upgraded to ${plan} (${duration})`);
}




// Handle Subscription Purchased
async function handleSubscriptionPurchased(subscriptionId, purchaseToken) {
  const userRef = admin.firestore().collection('users').doc(subscriptionId);
  await userRef.update({
    subscriptionStatus: 'active',
    purchaseToken: purchaseToken,
  });
  console.log(`Subscription purchased for user ${subscriptionId}`);
}

// Handle Subscription Canceled
async function handleSubscriptionCanceled(subscriptionId) {
  const userRef = admin.firestore().collection('users').doc(subscriptionId);
  await userRef.update({
    subscriptionStatus: 'canceled',
  });
  console.log(`Subscription canceled for user ${subscriptionId}`);
}


// Handle Subscription Renewed
async function handleSubscriptionRenewed(subscriptionId) {
  const userRef = admin.firestore().collection('users').doc(subscriptionId);
  await userRef.update({
    subscriptionStatus: 'active',
  });
  console.log(`Subscription renewed for user ${subscriptionId}`);
}

// Handle Subscription Expired
async function handleSubscriptionExpired(subscriptionId) {
  const userRef = admin.firestore().collection('users').doc(subscriptionId);
  await userRef.update({
    subscriptionStatus: 'expired',
  });
  console.log(`Subscription expired for user ${subscriptionId}`);
}


















const GMAIL_EMAIL = "developera574@gmail.com"; 
const GMAIL_PASSWORD = "ozcriypjmnmmslox"; 

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: GMAIL_EMAIL,
    pass: GMAIL_PASSWORD, // Use App Password here
  },
});

// exports.sendPDFEmail = functions.https.onCall(async (data, context) => {
//   const { pdfUrl, recipientEmail } = data;

//   if (!recipientEmail || !pdfUrl) {
//     throw new functions.https.HttpsError("invalid-argument", "Missing email or PDF URL.");
//   }

//   const mailOptions = {
//     from: GMAIL_EMAIL,
//     to: recipientEmail,
//    subject: "Your Invoice from VEHYPE",
//   text: `Hello,\n\nAttached is your invoice from VEHYPE.\n\nYou can download it here: ${pdfUrl}\n\nBest Regards,\nVEHYPE Team`
//   };

//   try {
//     await transporter.sendMail(mailOptions);
//     return { success: true, message: "Email sent successfully!" };
//   } catch (error) {
//     console.error("Error sending email:", error);
//     throw new functions.https.HttpsError("Error sending email", error);
//   }
// });





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