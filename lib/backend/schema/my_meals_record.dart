import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import 'index.dart';
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

  /// Container for the raw snapshot; used to populate the fields above.
  void _initializeFields() {
    final snapshotData = this.snapshotData;

    _mealName = snapshotData['mealName'] as String?;
    _createdBy = snapshotData['createdBy'] as String?;

    _tags = snapshotData['tags'] != null
        ? List<String>.from(
            (snapshotData['tags'] as List).map((e) => e as String))
        : null;
    _related = snapshotData['related'] != null
        ? List<String>.from(
            (snapshotData['related'] as List).map((e) => e as String))
        : null;
    _foodType = snapshotData['foodType'] != null
        ? List<String>.from(
            (snapshotData['foodType'] as List).map((e) => e as String))
        : null;
    _dietType = snapshotData['dietType'] != null
        ? List<String>.from(
            (snapshotData['dietType'] as List).map((e) => e as String))
        : null;
    _category = snapshotData['category'] != null
        ? List<String>.from(
            (snapshotData['category'] as List).map((e) => e as String))
        : null;

    _isSelected = snapshotData['isSelected'] as bool?;
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

  static MyMealsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MyMealsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MyMealsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MyMealsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MyMealsRecord(reference: ${reference.path}, data: $snapshotData)';

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
  }.withoutNulls);

  return firestoreData;
}

/// Equality helper that compares two `MyMealsRecord` instances by value.
class MyMealsRecordDocumentEquality implements Equality<MyMealsRecord> {
  const MyMealsRecordDocumentEquality();

  @override
  bool equals(MyMealsRecord? e1, MyMealsRecord? e2) {
    if (e1 == null || e2 == null) return false;
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
    return const ListEquality<Object?>().hash([
      e.mealName,
      e.createdBy,
      listEquality.hash(e.tags),
      listEquality.hash(e.related),
      listEquality.hash(e.foodType),
      listEquality.hash(e.dietType),
      listEquality.hash(e.category),
      e.isSelected,
    ]);
  }

  @override
  bool isValidKey(Object? o) => o is MyMealsRecord;
}
