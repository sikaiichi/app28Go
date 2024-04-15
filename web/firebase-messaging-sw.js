importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyAWMhT8dWVXhXV1fRf_ijQd-aUfkHMOdag",
  authDomain: "credible-glow-410409.firebaseapp.com",
  projectId: "credible-glow-410409",
  storageBucket: "credible-glow-410409.appspot.com",
  messagingSenderId: "244552898375",
  appId: "1:244552898375:web:91b69cdff4089b3a881e62",
  databaseURL: "...",
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});