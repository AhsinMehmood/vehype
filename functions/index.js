const functions = require("firebase-functions");

const admin = require('firebase-admin');


admin.initializeApp();

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

