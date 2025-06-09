// scripts/migrate_meals3.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORTANT: Ensure your Firebase project options are correct.
// You can find these in your lib/backend/firebase/firebase_config.dart file.
const firebaseOptions = FirebaseOptions(
  apiKey:
      "AIzaSyAbbuIlZXI3P4eteGSQrWPajKb_1N66nWY", // From your firebase_config.dart
  authDomain:
      "mealmaster-qilqg.firebaseapp.com", // From your firebase_config.dart
  projectId: "mealmaster-qilqg", // From your firebase_config.dart
  storageBucket:
      "mealmaster-qilqg.firebasestorage.app", // From your firebase_config.dart
  messagingSenderId: "578703647409", // From your firebase_config.dart
  appId:
      "1:578703647409:web:be70cdc4b3c1c4b49cb890", // From your firebase_config.dart
);

Future<void> main() async {
  print('--- Starting meals3 data migration script (v2) ---');

  // Initialize Firebase
  await Firebase.initializeApp(options: firebaseOptions);
  final firestore = FirebaseFirestore.instance;
  print('Firebase initialized successfully.');

  // List of fields that should be a List<String>
  final fieldsToFix = ['category', 'dietType', 'foodType', 'tags', 'related'];

  try {
    final meals3Collection = firestore.collection('meals3');
    final snapshot = await meals3Collection.get();

    if (snapshot.docs.isEmpty) {
      print('No documents found in meals3 collection. Exiting.');
      return;
    }
    print('Found ${snapshot.docs.length} documents to process.');

    WriteBatch batch = firestore.batch();
    int documentsToUpdate = 0;

    // Helper function to safely convert a field to a List<String>
    // This is the updated part of the code.
    List<String> safelyConvertToList(dynamic fieldData) {
      if (fieldData == null) {
        return [];
      }
      if (fieldData is List) {
        // If it's already a list, just ensure all items are strings.
        return List<String>.from(
            fieldData.map((item) => item.toString().trim()));
      }
      if (fieldData is String) {
        // If it's a string, split it by commas and trim whitespace from each part.
        // This handles both "Breakfast" and "lunch, dinner".
        return fieldData
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      // For any other type, return an empty list to be safe.
      return [];
    }

    for (final doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();
      Map<String, dynamic> updates = {};

      for (String fieldName in fieldsToFix) {
        if (data.containsKey(fieldName)) {
          final fieldValue = data[fieldName];
          // We check if the field is a String, which is the incorrect type we want to fix.
          if (fieldValue is String) {
            updates[fieldName] = safelyConvertToList(fieldValue);
          }
        }
      }

      if (updates.isNotEmpty) {
        print('Updating document: ${doc.id}');
        batch.update(doc.reference, updates);
        documentsToUpdate++;
      }
    }

    if (documentsToUpdate > 0) {
      print(
          '\nFound $documentsToUpdate documents that need updates. Committing batch...');
      await batch.commit();
      print('--- MIGRATION COMPLETE! ---');
      print('$documentsToUpdate documents were successfully updated.');
    } else {
      print('--- MIGRATION COMPLETE! ---');
      print('No documents with string fields needed updates.');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
