import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// A Dart representation of a Firestore document in the `myMeals` subcollection,
/// fully migrated to Array‐of‐String fields instead of individual Boolean flags.
///
/// Firestore fields in `myMeals` now should be:
///   - mealName   : String
///   - createdBy  : String
///   - tags       : List<String>
///   - related    : List<String>
///   - foodType   : List<String>
///   - dietType   : List<String>
///   - category   : List<String>
///   - isSelected : Boolean (optional, if you still use it for selection state)
class MyMealsRecord extends FirestoreRecord {
  MyMealsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // ──────────── FIELDS ────────────

  // "mealName" field (String)
  String? _mealName;
  String get mealName => _mealName ?? '';
  bool hasMealName() => _mealName != null;

  // "createdBy" field (String)
  String? _createdBy;
  String get createdBy => _createdBy ?? '';
  bool hasCreatedBy() => _createdBy != null;

  // "tags" field (List<String>)
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  // "related" field (List<String>)
  List<String>? _related;
  List<String> get related => _related ?? const [];
  bool hasRelated() => _related != null;

  // "foodType" field (List<String>)
  List<String>? _foodType;
  List<String> get foodType => _foodType ?? const [];
  bool hasFoodType() => _foodType != null;

  // "dietType" field (List<String>)
  List<String>? _dietType;
  List<String> get dietType => _dietType ?? const [];
  bool hasDietType() => _dietType != null;

  // "category" field (List<String>)
  List<String>? _category;
  List<String> get category => _category ?? const [];
  bool hasCategory() => _category != null;

  // "isSelected" field (Boolean)
  bool? _isSelected;
  bool get isSelected => _isSelected ?? false;
  bool hasIsSelected() => _isSelected != null;

  /// Initializes fields from the data map stored in the FirestoreRecord superclass.
  void _initializeFields() {
    // Access the data map from the superclass (FirestoreRecord).
    // This assumes FirestoreRecord makes its internal data map (passed in its constructor)
    // available via a getter or public field named `data`.
    // If your FirestoreRecord uses a different name (e.g., `_snapshotData`, `rawData`),
    // use that name here instead of `this.data`.
    final Map<String, dynamic> recordData = this.data; // MODIFIED LINE

    _mealName = recordData['mealName'] as String?;
    _createdBy = recordData['createdBy'] as String?;

    _tags = recordData['tags'] != null
        ? List<String>.from(
            (recordData['tags'] as List).map((e) => e as String))
        : null;
    _related = recordData['related'] != null
        ? List<String>.from(
            (recordData['related'] as List).map((e) => e as String))
        : null;
    _foodType = recordData['foodType'] != null
        ? List<String>.from(
            (recordData['foodType'] as List).map((e) => e as String))
        : null;
    _dietType = recordData['dietType'] != null
        ? List<String>.from(
            (recordData['dietType'] as List).map((e) => e as String))
        : null;
    _category = recordData['category'] != null
        ? List<String>.from(
            (recordData['category'] as List).map((e) => e as String))
        : null;

    _isSelected = recordData['isSelected'] as bool?;
  }

  // ──────────── COLLECTION REFERENCE ────────────

  /// If you store `myMeals` as a subcollection under each user, you can pass the parent.
  /// Otherwise, use `collectionGroup('myMeals')` to query all users’ meals.
  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('myMeals')
          : FirebaseFirestore.instance.collectionGroup('myMeals');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('myMeals').doc(id);

  static Stream<MyMealsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MyMealsRecord.fromSnapshot(s));

  static Future<MyMealsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MyMealsRecord.fromSnapshot(s));

  static MyMealsRecord fromSnapshot(DocumentSnapshot snapshot) {
    // Ensure that `snapshot.data()` is not null before casting.
    // Firestore's `snapshot.data()` can be null if the document doesn't exist.
    final snapshotData = snapshot.data() as Map<String, dynamic>?;
    if (snapshotData == null) {
      // Handle the case where the document doesn't exist or data is null.
      // You might throw an error, return a default record, or handle it as appropriate.
      // For simplicity, this example assumes `mapFromFirestore` can handle null or
      // you have upstream checks ensuring `snapshot.exists` is true.
      // If mapFromFirestore expects non-null, you need robust handling here.
      // For now, let's assume mapFromFirestore might return an empty map or similar.
      // A more robust approach might be to check snapshot.exists before calling this.
      print(
          'Warning: DocumentSnapshot data is null for ${snapshot.reference.path}');
      return MyMealsRecord._(
        snapshot.reference,
        mapFromFirestore(<String, dynamic>{}), // Pass empty map or handle error
      );
    }
    return MyMealsRecord._(
      snapshot.reference,
      mapFromFirestore(snapshotData),
    );
  }

  static MyMealsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MyMealsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      // Use `this.data` to access the data map from the FirestoreRecord superclass
      'MyMealsRecord(reference: ${reference.path}, data: ${this.data})'; // MODIFIED LINE

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(Object other) =>
      other is MyMealsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

/// Create a Firestore‐compatible map for adding/updating a `myMeals` document.
///
/// All old Boolean fields (foodTypeDessert, dMealCategoryBf, dietTypeVeg, etc.)
/// have been removed. You now write arrays of strings instead:
///   - `category`
///   - `dietType`
///   - `tags`
///   - `related`
///   - `foodType`
/// Optionally include `isSelected` if you still need to track that state.
Map<String, dynamic> createMyMealsRecordData({
  String? mealName,
  String? createdBy,
  List<String>? tags,
  List<String>? related,
  List<String>? foodType,
  List<String>? dietType,
  List<String>? category,
  bool? isSelected,
}) {
  final firestoreData = mapToFirestore({
    'mealName': mealName,
    'createdBy': createdBy,
    'tags': tags,
    'related': related,
    'foodType': foodType,
    'dietType': dietType,
    'category': category,
    'isSelected': isSelected,
  }.withoutNulls); // .withoutNulls is presumably a utility extension method

  return firestoreData;
}

/// Equality helper that compares two `MyMealsRecord` instances by value.
class MyMealsRecordDocumentEquality implements Equality<MyMealsRecord> {
  const MyMealsRecordDocumentEquality();

  @override
  bool equals(MyMealsRecord? e1, MyMealsRecord? e2) {
    if (e1 == null && e2 == null) return true; // Both null, considered equal
    if (e1 == null || e2 == null) return false; // One is null, not equal

    const listEquality = ListEquality<String>();
    return e1.mealName == e2.mealName &&
        e1.createdBy == e2.createdBy &&
        listEquality.equals(e1.tags, e2.tags) &&
        listEquality.equals(e1.related, e2.related) &&
        listEquality.equals(e1.foodType, e2.foodType) &&
        listEquality.equals(e1.dietType, e2.dietType) &&
        listEquality.equals(e1.category, e2.category) &&
        e1.isSelected == e2.isSelected;
  }

  @override
  int hash(MyMealsRecord? e) {
    if (e == null) return 0;
    const listEquality = ListEquality<String>();
    return Object.hash(
      // Use Object.hash for better hash distribution
      e.mealName,
      e.createdBy,
      listEquality.hash(e.tags),
      listEquality.hash(e.related),
      listEquality.hash(e.foodType),
      listEquality.hash(e.dietType),
      listEquality.hash(e.category),
      e.isSelected,
    );
  }

  @override
  bool isValidKey(Object? o) => o is MyMealsRecord;
}

// Dummy FirestoreRecord for context, replace with your actual FirestoreRecord definition
// This is just to illustrate what `this.data` refers to.
// Your actual FirestoreRecord class might be more complex.
abstract class FirestoreRecord {
  final DocumentReference reference;
  final Map<String, dynamic> data; // This is the data map

  FirestoreRecord(this.reference, this.data);

  // Potentially other common methods or getters
}

// Dummy mapFromFirestore for context, if it's not from flutter_flow_util
// or if you need a specific behavior for nulls.
Map<String, dynamic> mapFromFirestore(Map<String, dynamic> data) {
  // This is often an identity function or might handle specific transformations
  // like Timestamps to DateTimes if not handled by Firestore SDK itself.
  return data;
}

// Dummy mapToFirestore for context.
Map<String, dynamic> mapToFirestore(Map<String, dynamic> data) {
  // This might handle specific transformations like DateTimes to Timestamps.
  return data;
}

// Dummy .withoutNulls extension for context.
extension MapExtension<K, V> on Map<K, V?> {
  Map<K, V> withoutNulls() {
    final map = <K, V>{};
    forEach((key, value) {
      if (value != null) {
        map[key] = value;
      }
    });
    return map;
  }
}
