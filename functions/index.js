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

const firestore = admin.firestore();



exports.sendMessageNotification = functions.https.onCall(async (data, context) => {
    const { chatId, messageId, title, subtitle, userIds } = data;

    const message = {
        notification: {
            title: title,
            body: subtitle,
        },
        data: {
            chatId: chatId,
            type: 'chat',
            messageId: messageId,
        },
        tokens: userIds, // FCM registration tokens
    };

    try {
        const response = await admin.messaging().sendMulticast(message);
        console.log('Successfully sent message:', response);
        return { success: true };
    } catch (error) {
        console.error('Error sending message:', error);
        return { success: false, error: error.message };
    }
});




exports.sendNotification = functions.https.onCall(async (data, context) => {
    const { offerId, requestId, title, subtitle, userIds } = data;

    const message = {
        notification: {
            title: title,
            body: subtitle,
        },
        data: {
            offerId: offerId,
            type: 'request',
            requestId: requestId || '',
        },
        tokens: userIds, // FCM registration tokens
    };

    try {
        const response = await admin.messaging().sendMulticast(message);
        console.log('Successfully sent message:', response);
        return { success: true };
    } catch (error) {
        console.error('Error sending message:', error);
        return { success: false, error: error.message };
    }
});









exports.notifyInactiveVehicleOwners = functions.pubsub.schedule('0 0 * * 1-5').onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const fourHoursAgo = new Date(now.toDate().getTime() - 4 * 60 * 60 * 1000);

    // Query vehicle owners who were last active more than 4 hours ago
    const usersSnapshot = await db.collection('users')
        .where('accountType', '==', 'vehicleOwner')
        .where('lastActive', '<=', admin.firestore.Timestamp.fromDate(fourHoursAgo))
        .get();

    // Process each user
    for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        const userId = userDoc.id;

        // Query offers collection for this user
        const offersSnapshot = await db.collection('offers')
            .where('ownerId', '==', userId)
            .where('status', '==', 'active')  // Assuming offers are related to the user by userId
            .get();

        // Filter offers based on checkByList condition
        const matchingOffers = offersSnapshot.docs.filter(offerDoc => {
            const offerData = offerDoc.data();
            const checkByList = offerData.checkByList || [];

            // Check if any map in checkByList meets the conditions
            return checkByList.some(check => 
                check.checkById === userId && 
                check.createdAt.toMillis() <= fourHoursAgo.getTime()
            );
        });

        // If there are matching offers, send a notification via OneSignal
        if (matchingOffers.length > 0) {
            const notificationPayload = {
                app_id: ONE_SIGNAL_APP_ID,
                include_external_user_ids: [userId], // Assuming userId is mapped to OneSignal external user ID
                headings: { "en": "You have new offers to check" },
                contents: { "en": "Please check the new offers in your account." },
            };

            try {
                await axios.post('https://onesignal.com/api/v1/notifications', notificationPayload, {
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Basic ${ONE_SIGNAL_API_KEY}`,
                    },
                });
                console.log(`Notification sent to user ${userId} via OneSignal`);
            } catch (error) {
                console.error(`Failed to send notification to user ${userId} via OneSignal: `, error);
            }
        }
    }

    return null;
});


// exports.getAndSaveData = functions.https.onRequest(async (req, res) => {
//     try
//     {
//         const jwtToken = await getJwtToken();

//         if (!jwtToken)
//         {
//             throw new Error("Failed to retrieve JWT token");
//         }

//         const makes = await getVehicleMakeToSaveData('Passenger vehicle', jwtToken);
//         for (const element of makes)
//         {
//             await firestore.collection('passenger_vehicle_makes')
//                 .doc(element['id'].toString())
//                 .set(element);

//             const years = await getVehicleYear(element['name'], jwtToken);
//             for (const year of years)
//             {
//                 await firestore.collection('passenger_vehicle_years')
//                     .doc(year.toString() + element['id'])
//                     .set({ 'year': year, 'make_id': element['id'] });

//                 const modelsData = await getModelsToStoreData(element['name'], year.toString(), jwtToken);
//                 for (const model of modelsData)
//                 {
//                     await firestore.collection('passenger_vehicle_models')
//                         .doc(model['id'].toString())
//                         .set(model);

//                     const trims = await getTrimsToStoreData(element['name'], year.toString(), 'Passenger vehicle', model['name'], jwtToken);
//                     for (const trim of trims)
//                     {
//                         await firestore.collection('passenger_vehicle_trims')
//                             .doc(trim['id'].toString())
//                             .set(trim);
//                     }
//                 }
//             }
//         }
//         res.status(200).send({ success: true });
//     } catch (error)
//     {
//         console.error('Error fetching and saving car data:', error);
//         res.status(500).send({ success: false, error: error.message });
//     }
// });


// Cloud Scheduler trigger: Runs every 30 days
exports.enqueueDataProcessing = functions.pubsub.schedule('0 0 1 * *').onRun(async (context) => {
    try
    {
        // Fetch JWT token for API authentication
        const jwtToken = await getJwtToken();

        if (!jwtToken)
        {
            throw new Error("Failed to retrieve JWT token");
        }

        // Get vehicle makes to process
        const makes = await getVehicleMakeToSaveData('Passenger vehicle', jwtToken);

        // Enqueue tasks for each vehicle make
        for (const element of makes)
        {
            await firestore.collection('passenger_vehicle_makes').add({
                type: 'processMake', // Task type
                makeId: element['id'].toString(), // Vehicle make ID
                makeName: element['name'], // Vehicle make name
                status: 'pending' // Task status
            });
        }
    } catch (error)
    {
        console.error('Error enqueueing data processing:', error);
    }
});

exports.processQueue = functions.pubsub.schedule('every 5 minutes').onRun(async (context) => {
    try
    {
        // Query for pending tasks from the Firestore queue
        const tasksSnapshot = await firestore.collection('passenger_vehicle_makes').where('status', '==', 'pending').limit(10).get();
        if (tasksSnapshot.empty)
        {
            console.log('No tasks to process');
            return;
        }

        // Process each pending task
        for (const taskDoc of tasksSnapshot.docs)
        {
            const task = taskDoc.data();
            const { makeId, makeName } = task;

            try
            {
                // Fetch JWT token for API authentication
                const jwtToken = await getJwtToken();

                if (!jwtToken)
                {
                    throw new Error("Failed to retrieve JWT token");
                }

                // Fetch vehicle years for the make
                const years = await getVehicleYear(makeName, jwtToken);
                for (const year of years)
                {
                    // Save vehicle year data to Firestore
                    await firestore.collection('passenger_vehicle_years')
                        .doc(year.toString() + makeId)
                        .set({ 'year': year, 'make_id': makeId });

                    // Fetch and save vehicle models
                    const modelsData = await getModelsToStoreData(makeName, year.toString(), jwtToken);
                    for (const model of modelsData)
                    {
                        await firestore.collection('passenger_vehicle_models')
                            .doc(model['id'].toString())
                            .set(model);

                        // Fetch and save vehicle trims
                        const trims = await getTrimsToStoreData(makeName, year.toString(), 'Passenger vehicle', model['name'], jwtToken);
                        for (const trim of trims)
                        {
                            await firestore.collection('passenger_vehicle_trims')
                                .doc(trim['id'].toString())
                                .set(trim);
                        }
                    }
                }
                // Update task status to 'completed'
                await taskDoc.ref.update({ status: 'completed' });
            } catch (error)
            {
                console.error('Error processing task:', error);
                // Update task status to 'failed' with error message
                await taskDoc.ref.update({ status: 'failed', error: error.message });
            }
        }
    } catch (error)
    {
        console.error('Error processing queue:', error);
    }
});



async function getJwtToken () {
    try
    {
        const response = await axios.post('https://carapi.app/api/auth/login', {
            api_token: 'ba831f89-cd77-4efc-9b3b-2a4ef151f959',
            api_secret: 'c4234b2783a659dad7f5f13cbfc54683'
        }, {
            headers: {
                'Content-type': 'application/json',
                'Accept': 'text/plain'
            }
        });

        if (response.status === 200)
        {
            return response.data;  // Assuming response.body contains the JWT token
        } else
        {
            console.error('Failed to get JWT token:', response.status, response.statusText);
            return '';
        }
    } catch (error)
    {
        console.error('Error fetching JWT token:', error);
        return '';
    }
}

async function getVehicleMakeToSaveData (type, jwtToken) {
    const vehicleType = type === 'Passenger vehicle' ? 'Car' : type;
    const vehicleMakeList = [];
    try
    {
        if (vehicleType === 'Car')
        {
            const recallApi = 'https://carapi.app/api/makes';
            const response = await axios.get(recallApi, {
                headers: {
                    'Content-type': 'application/json',
                    'Authorization': `Bearer ${jwtToken}`
                }
            });
            const listOfData = response.data['data'];
            listOfData.forEach(element => vehicleMakeList.push(element));
        }
        return vehicleMakeList;
    } catch (error)
    {
        console.error('Error fetching vehicle makes:', error);
        return [];
    }
}

async function getVehicleYear (make, jwtToken) {
    const vehicleYearList = [];
    try
    {
        const response = await axios.get(`https://carapi.app/api/years?make=${make}`, {
            headers: {
                'Content-type': 'application/json',
                'Authorization': `Bearer ${jwtToken}`
            }
        });
        const listOfData = response.data;
        listOfData.forEach(element => vehicleYearList.push(element));
        if (vehicleYearList.includes(2025)) vehicleYearList.splice(vehicleYearList.indexOf(2025), 1);
        if (vehicleYearList.length === 0)
        {
            vehicleYearList.push(...Array.from({ length: 225 }, (_, i) => 2024 - i));
        }
        return vehicleYearList;
    } catch (error)
    {
        console.error('Error fetching vehicle years:', error);
        return [];
    }
}

async function getModelsToStoreData (make, year, jwtToken) {
    try
    {
        const response = await axios.get(`https://carapi.app/api/models?year=${year}&make=${make}`, {
            headers: {
                'Content-type': 'application/json',
                'Authorization': `Bearer ${jwtToken}`
            }
        });
        return response.data['data'];
    } catch (error)
    {
        console.error('Error fetching models:', error);
        return [];
    }
}

async function getTrimsToStoreData (make, year, type, model, jwtToken) {
    try
    {
        const response = await axios.get(`https://carapi.app/api/trims?year=${year}&make=${make}&model=${model}`, {
            headers: {
                'Content-type': 'application/json',
                'Authorization': `Bearer ${jwtToken}`
            }
        });
        return response.data['data'];
    } catch (error)
    {
        console.error('Error fetching trims:', error);
        return [];
    }
}































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
   
        // const offersReceived = admin.firestore().collection('offers').doc().collection('offersReceived').where('ownerId', '==', uid);
        /// 35116023
        //////


        // developer1@vehype.com

        // Devel@per1@@
        // Vehype@pp01
        /////
        // offersReceived
     



        // firestoreDeleteBatch.delete(connectionsRed);

        // firestoreDeleteBatch.delete(purchasesRed);
       
        // Delete the user from Firebase Authentication
        await admin.auth().deleteUser(uid);

        // Commit the Firestore batch delete
 

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

