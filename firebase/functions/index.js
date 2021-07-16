const functions = require('firebase-functions');
const admin = require('firebase-admin')

admin.initializeApp();

exports.addGeohash = functions
    .region('europe-west1')    
    .firestore
    .document('posts/{messageId}')
    .onCreate((snap, context) => { 

        const ngeohash = require('ngeohash');
        const coordinates = snap.data()['coordinates'];
        const geohash = ngeohash.encode(coordinates.latitude, coordinates.longitude);
        const id = snap.data()['id']; 

        return admin.firestore()
            .collection('posts')
            .doc(id)
            .set({ geohash: geohash }, { merge: true })
    });

exports.addCreatedPostToUser = functions
    .region('europe-west1')
    .firestore
    .document('posts/{messageId}')
    .onCreate((snap, context) => {

        const referencedDocument = admin.firestore()
                                            .collection('posts')
                                            .doc(snap.data()['id']);
        const creatorID = snap.data()['creatorID']

        return admin.firestore()
            .collection('users')
            .doc(creatorID)
            .collection('createdPosts')
            .doc(context.params.messageId)
            .set({ createdPost: referencedDocument }, { merge: true })
    });

exports.sendLikedNotification = functions
    .region('europe-west1')
    .firestore
    .document('posts/{messageId}')
    .onUpdate((change, context) => {

        const creatorID = change.after.data()['creatorID'];
        const postID = context.params.messageId
        const userRef = admin.firestore()
            .collection('users')
            .doc(creatorID);

        return userRef
            .get()
            .then(doc => {
                if (!doc.exists) {
                    throw new Error('No such User document!');
                } else {
                    
                    const fcmToken = doc.data().fcmToken;
                    const title = "That's surprising"
                    const body = "I guess you didn't expect that. But somebody liked your post. No kidding!"

                    let payload = {
                        notification: {
                            title: title,
                            body: body,
                        },
                        data: {
                            "postID": `${postID}`
                        },
                        apns: {
                            payload: {
                                aps: {
                                    badge: 0,
                                    sound: "default"
                                },
                            },
                        },
                        token: fcmToken,
                    };
                    return admin.messaging().send(payload);
                }
            })
            .catch(err => {
                console.log('Error getting document', err);
                return false;
            });
    });