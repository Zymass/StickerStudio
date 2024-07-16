/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");
const serviceAccount = require("./cred.json");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {setGlobalOptions, logger} = require("firebase-functions/v2");
setGlobalOptions({maxInstances: 10});
const serviceKey = (
  "OvypnElGk8xfI9Zo7k2SBHXowjXPG93FlgsHn9tkSDR8e2wqAkHbVFpNdy49"
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://stickerstudioai-e0262-default-rtdb.europe-west1.firebasedatabase.app",
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
exports.create_sticker = onCall(async (req) => {
  if (!req.auth) {
    throw new HttpsError(
        "unauthenticated", "Требуется аутентификация.",
    );
  }
  const trackId = req.auth.uid + Date.now() / 1000;
  const requestData = {
    "key": serviceKey,
    "model_id": "anything-v4",
    "prompt": req.data.prompt,
    "negative_prompt": "",
    "width": 512,
    "height": 512,
    "samples": 1,
    "num_inference_steps": "21",
    "safety_checker": "yes",
    "enhance_prompt": "no",
    "seed": null,
    "guidance_scale": 7.5,
    "multi_lingual": "no",
    "panorama": "no",
    "self_attention": "yes",
    "upscale": "1",
    "embeddings_model": null,
    "lora_model": "stickermodel",
    "tomesd": "yes",
    "clip_skip": "2",
    "use_karras_sigmas": "yes",
    "vae": null,
    "lora_strength": "0.5",
    "scheduler": "UniPCMultistepScheduler",
    "webhook": "https://us-central1-stickerstudio-737c4.cloudfunctions.net/onEndCreation?userId=" + req.auth.uid + "&id=" + trackId,
    "track_id": trackId,
  };

  const apiUrl = "https://stablediffusionapi.com/api/v4/dreambooth";

  const headers = {
    "Content-Type": "application/json",
  };

  const response = await axios.post(apiUrl, requestData, headers);

  const responseData = response.data;

  return {result: "Success", responseData};
});


// получение картинки
exports.fetch_image = onCall(async (req) => {
  if (!req.auth) {
    throw new HttpsError(
        "unauthenticated", "Требуется аутентификация.",
    );
  }

  const apiUrl = "https://stablediffusionapi.com/api/v4/dreambooth/fetch?"+
  "key=" + serviceKey +
  "&request_id=" + req.data.image_id;

  const response = await axios.post(apiUrl);

  const responseData = response.data;

  return {result: "Success", responseData};
});


// обновить данные пользователя
exports.update_user = onCall(async (req) => {
  if (!req.auth) {
    throw new HttpsError(
        "unauthenticated", "Требуется аутентификация.",
    );
  }

  const auth = req.auth.uid;
  const doc = await db.collection("users").doc(auth).get();

  if (doc.exists) {
    const currentStickers = doc.data().stickers;
    currentStickers.push(req.data.sticker);
    logger.info(currentStickers);

    const data = {
      stickers: currentStickers,
    };
    await db.collection("users").doc(auth).set(data, {merge: true});

    return {result: "Success"};
  } else {
    return {result: "User not found"};
  }
});

exports.onEndCreation = functions.https.onRequest((request, response) => {
  const userId = request.query.userId;
  const id = request.query.id;

  // if (!userId || !id) {
  //   response.status(400).send('Missing parameters userId or id');
  //   return;
  // }

  console.log(`Received userId: ${userId}, id: ${id}`);
  response.send(`Hello from Firebase! Received userId: ${userId}, id: ${id}`);
});
