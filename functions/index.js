const functions = require("firebase-functions");
const cors = require('cors')({ origin: true });

const admin = require('firebase-admin');
// For details and booking, please call at 0300 9464109 & 0328 4233372
// 📍Our Location:
// 4-Main Zeenat Block,Hafeez Taib Road, Allama Iqbal Town, Lahore.
//Elite Residency Lahore 
const axios = require('axios');
admin.initializeApp();
const ONE_SIGNAL_APP_ID = 'e236663f-f5c0-4a40-a2df-81e62c7d411f';
const ONE_SIGNAL_API_KEY = 'NmZiZWJhZDktZGQ5Yi00MjBhLTk2MGQtMmQ5MWI1NjEzOWVi';


const puppeteer = require('puppeteer');
const functions = require('firebase-functions');

exports.scrapeEbayGarage = functions.https.onRequest(async (req, res) => {
    try
    {
        const browser = await puppeteer.launch({ headless: true });
        const page = await browser.newPage();

        // Step 1: Navigate to the login page
        await page.goto('https://www.ebay.com/signin/', { waitUntil: 'networkidle2' });

        // Step 2: Fill in the login form
        await page.type('#userid', 'your-email@example.com'); // Replace with your email
        await page.type('#pass', 'your-password'); // Replace with your password

        // Step 3: Submit the login form
        await page.click('#signin-continue-btn');

        // Wait for navigation after login
        await page.waitForNavigation({ waitUntil: 'networkidle2' });

        // Step 4: Navigate to the eBay Garage page
        await page.goto('https://www.ebay.com/motors/garage', { waitUntil: 'networkidle2' });

        // Step 5: Scrape the data (example for scraping years)
        const years = await page.evaluate(() => {
            const options = Array.from(document.querySelectorAll('select#year option'));
            return options.map(option => option.textContent.trim()).filter(year => year);
        });

        // Similarly, scrape makes, models, trims, etc.

        await browser.close();

        res.status(200).json({ years });

    } catch (error)
    {
        console.error('Error scraping eBay Garage:', error);
        res.status(500).send('Error occurred while scraping eBay Garage');
    }
});

























exports.sendPushNotifications = functions.https.onRequest(async (req, res) => {
    try
    {
        const usersRef = admin.firestore().collection('users');
        const snapshot = await usersRef.where('accountType', '==', 'provider').where('status', '==', 'active').get();

        if (snapshot.empty)
        {
            console.log('No matching documents.');
            return res.status(404).send('No matching documents.');
        }

        const userIds = [];
        snapshot.forEach(doc => {
            const userData = doc.data();
            userIds.push(userData.id);
        });

        if (userIds.length === 0)
        {
            console.log('No users with OneSignal user IDs.');
            return res.status(404).send('No users with OneSignal user IDs.');
        }

        const message = 'Created a new Offer';

        const response = await axios.post('https://onesignal.com/api/v1/notifications', {
            app_id: ONE_SIGNAL_APP_ID,
            include_player_ids: userIds,
            contents: { en: `${req.body.name} ${message}` }
        }, {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Basic ${ONE_SIGNAL_API_KEY}`
            }
        });

        console.log('Notification sent successfully:', response.data);
        return res.status(200).send({ success: true, message: 'Notification sent successfully' });
    } catch (error)
    {
        console.error('Error sending notification:', error);
        return res.status(500).send({ success: false, error: error.message });
    }
});
exports.deleteUserAccount = functions.https.onRequest(async (req, res) => {
    const uid = req.query.uid;
    const currentUserID = req.query.uid;

    try
    {
        const firestoreDeleteBatch = admin.firestore().batch();
        // const userFirestorePurchasesRef = admin.firestore().collection('users').doc(uid).collection('purchases');
        const connectionsRed = admin.firestore().collection('garages').where('ownerId', '==', uid);
        const userFirestorePurchasesRef = admin.firestore().collection('offers').where('ownerId', '==', uid);

        // const offersReceived = admin.firestore().collection('offers').doc().collection('offersReceived').where('ownerId', '==', uid);
        /// 35116023
        //////


        // developer1@vehype.com

        // Devel@per1@@
        // Vehype@pp01
        /////
        // offersReceived
        const querySnapshot = await userFirestorePurchasesRef.get();
        const connections = await connectionsRed.get();


        const batch = admin.firestore().batch();
        querySnapshot.forEach((doc) => {

            batch.delete(doc.ref);
        });
        const connectionsBatch = admin.firestore().batch();
        connections.forEach((doc) => {
            connectionsBatch.delete(doc.ref);
        });
        await connectionsBatch.commit();

        await batch.commit();
        const userFirestoreRef = admin.firestore().collection('users').doc(uid);
        // 





        // firestoreDeleteBatch.delete(connectionsRed);

        // firestoreDeleteBatch.delete(purchasesRed);
        firestoreDeleteBatch.delete(userFirestoreRef);

        const chatsRef = admin.database().ref('chats');
        const chatsSnapshot = await chatsRef.child(currentUserID).once('value');
        chatsSnapshot.forEach((chatSnapshot) => {
            const secondUserID = chatSnapshot.key;
            chatsRef.child(currentUserID).child(secondUserID).remove();
            chatsRef.child(secondUserID).child(currentUserID).remove();
        });

        // Delete messages
        const messagesRef = admin.database().ref('messages');
        const messagesSnapshot = await messagesRef.once('value');
        messagesSnapshot.forEach((messageSnapshot) => {
            const chatID = messageSnapshot.key;
            if (chatID.includes(currentUserID))
            {
                messagesRef.child(chatID).remove();
            }
        });


        // Delete user's Firebase Storage images
        const storageDeletePromises = [];
        const storageRef = admin.storage().bucket();

        // List all files in the user's folder
        const [files] = await storageRef.getFiles({ prefix: `users/${uid}/` });

        files.forEach((file) => {
            const fileRef = storageRef.file(file.name);
            storageDeletePromises.push(fileRef.delete());
        });

        // Wait for all storage deletions to complete
        await Promise.all(storageDeletePromises);

        // Delete the user from Firebase Authentication
        await admin.auth().deleteUser(uid);

        // Commit the Firestore batch delete
        await firestoreDeleteBatch.commit();

        // res.status(200).send('User account deleted successfully.');
        res.status(200).send('User account deleted successfully.');
    } catch (error)
    {

        res.status(500).send('Failed to delete user account.');
    }
});

exports.updateOfferStatus = functions.firestore
    .document('offersReceived/{offerId}')
    .onCreate((snap, context) => {
        const offerId = context.params.offerId;
        const offerRef = admin.firestore().collection('offersReceived').doc(offerId);
        const now = new Date();
        const createdAt = now.toISOString();
        return offerRef.update({

            createdAt: createdAt

        });
    });

