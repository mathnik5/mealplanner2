import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAbbuIlZXI3P4eteGSQrWPajKb_1N66nWY",
            authDomain: "mealmaster-qilqg.firebaseapp.com",
            projectId: "mealmaster-qilqg",
            storageBucket: "mealmaster-qilqg.firebasestorage.app",
            messagingSenderId: "578703647409",
            appId: "1:578703647409:web:be70cdc4b3c1c4b49cb890"));
  } else {
    await Firebase.initializeApp();
  }
}
