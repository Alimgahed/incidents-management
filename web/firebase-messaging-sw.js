importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

const firebaseConfig = {
  apiKey: "AIzaSyAharYe12biNaaz7voJ7EL-24disKIMLb4",
  appId: "1:818149125918:web:2c287dc473370f3e95230f",
  messagingSenderId: "818149125918",
  projectId: "risk-manamgment",
  authDomain: "risk-manamgment.firebaseapp.com",
  storageBucket: "risk-manamgment.firebasestorage.app",
  measurementId: "G-VTB7GB84Y0"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification?.title ?? 'Notification';
  const notificationOptions = {
    body: payload.notification?.body,
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});
