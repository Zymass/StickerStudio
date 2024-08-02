/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const path = require("path");
const fs = require("fs");
const functions = require("firebase-functions/v2");
const axios = require("axios");
const admin = require("firebase-admin");
const serviceAccount = require("./cred.json");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
setGlobalOptions({maxInstances: 10});
const serviceKey = (
  "OvypnElGk8xfI9Zo7k2SBHXowjXPG93FlgsHn9tkSDR8e2wqAkHbVFpNdy49"
);
const {pipeline} = require("stream");
const {promisify} = require("util");
const pipelineAsync = promisify(pipeline);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://stickerstudio-737c4-default-rtdb.firebaseio.com/",
  storageBucket: "gs://stickerstudio-737c4.appspot.com",
});

// Main database reference
const db = admin.firestore();

const {
  beforeUserSignedIn,
} = require("firebase-functions/v2/identity");
// const {log} = require("firebase-functions/logger");

// триггер на авторизации пользователя
exports.add_new_user = beforeUserSignedIn(async (event) => {
  const user = event.data;
  const uid = user.uid || "";

  const doc = await db.collection("users").doc(uid).get();
  if (doc.exists) {
    // такой юзер есть, обновяем дату входа
    const data = {
      lastSignInTime: Date.now() || "none",
    };
    await db.collection("users").doc(uid).set(data, {merge: true});
  } else {
    // Юзера нет, создаем ему запись
    const data = {
      email: user.email || "none",
      uid: user.uid || "none",
      lastSignInTime: user.metadata.lastSignInTime || "none",
      creationTime: user.metadata.creationTime || "none",
      generations: 10,
      generationsDone: 0,
      freeGenerationrequestDate: 0,
      stickers: Array(""),
    };
    await db.collection("users").doc(uid).set(data, {merge: true});
  }
});


// получение модели юзера
exports.get_user_info = onCall(async (req) => {
  if (!req.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new HttpsError("failed-precondition", "The function must be " +
            "called while authenticated.");
  }

  const auth = req.auth.uid;
  const doc = await db.collection("users").doc(auth).get();

  if (doc.exists) {
    // такой юзер есть
    return {result: doc.data()};
  } else {
    return {result: "User not found"};
  }
});


// генерация картинки
exports.create_sticker = functions.https.onCall({
  timeoutSeconds: 120,
  memory: "1GiB",
}, async (req) => {
  if (!req.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Требуется аутентификация.",
    );
  }

  const trackId = req.auth.uid + Date.now() / 1000;
  const requestData = {
    key: serviceKey,
    model_id: "anything-v4",
    prompt: req.data.prompt,
    negative_prompt: "",
    width: 512,
    height: 512,
    samples: 1,
    scheduler: "UniPCMultistepScheduler",
    webhook: `https://onendcreation-6aypxuipjq-uc.a.run.app?userId=${req.auth.uid}&id=${trackId}`,
    track_id: trackId,
  };

  const apiUrl = "https://modelslab.com/api/v6/realtime/text2img";

  const headers = {
    "Content-Type": "application/json",
  };

  try {
    const response = await axios.post(apiUrl, requestData, {headers});

    if (response.data.future_links && response.data.future_links.length > 0) {
      await admin.firestore().collection("createdStickers").doc(trackId).set({
        imageUrl: response.data.future_links,
      });
    } else {
      throw new functions.https.HttpsError(
          "Error",
          "future_links is empty",
      );
    }
  } catch (error) {
    return {result: "Error", error: error.message};
  }
});


// Webhook
exports.onEndCreation = functions.https.onRequest(async (request, response) => {
  try {
    const uid = request.query.userId;
    const id = request.query.id;

    if (!uid || !id) {
      throw new functions.https.HttpsError(
          "Error",
          "uid or ud is empty",
      );
    }

    const doc = await admin.firestore()
        .collection("createdStickers").doc(id).get();

    if (!doc.exists) {
      throw new functions.https.HttpsError("not-found", "Документ не найден");
    }

    const imageUrl = doc.get("imageUrl");

    if (!imageUrl) {
      throw new functions.https.HttpsError(
          "Error",
          "imageUrl is empty",
      );
    }

    // Download and resize image (if needed)
    const tempFilePath = path.join("/tmp", `${id}.jpg`);
    const imageResponse = await axios({
      url: imageUrl,
      responseType: "stream",
    });
    const fileStream = fs.createWriteStream(tempFilePath);
    await pipelineAsync(imageResponse.data, fileStream);
    // Resize if needed
    // await sharp(tempFilePath).resize(width, height).toFile(tempFilePath);

    // Upload to Firebase Storage
    const bucket = admin.storage().bucket();
    const destination = `users/${uid}/createdStickers/${id}.jpg`;
    await bucket.upload(tempFilePath, {destination});

    // Delete temp file
    fs.unlinkSync(tempFilePath);

    // Batch updates
    const batch = admin.firestore().batch();
    batch.update(admin.firestore().collection("users").doc(uid), {
      stickers: admin.firestore.FieldValue.arrayUnion(id),
    });
    // Potentially add updates to other collections if needed
    await batch.commit();

    return response.send({result: "Success"});
  } catch (error) {
    console.error(error);
    throw new functions.https.HttpsError(
        "Error",
        error,
    );
  }
});
