import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import 'index.dart';

/// A Dart representation of a Firestore document in the `meals3` collection,
/// using your new schema (strings and lists of strings).
///
/// Fields in Firestore (meals3):
///   - mealName   : String
///   - createdby  : String
///   - tags       : List<String>
///   - related    : List<String>
///   - foodType   : List<String>
///   - dietType   : List<String>
///   - category   : List<String>
class meals3Record extends FirestoreRecord {
  /// The raw Firestore snapshot. We store this so we can call `snapshot.data()`.
  final DocumentSnapshot _snapshot;

  meals3Record._(
    this._snapshot,
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // ──────────── Fields ────────────

  // “mealName” field (String)
  String? _mealName;
  String get mealName => _mealName ?? '';
  bool hasMealName() => _mealName != null;

  // “createdby” field (String)
  String? _createdby;
  String get createdby => _createdby ?? '';
  bool hasCreatedby() => _createdby != null;

  // “tags” field (List<String>)
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  // “related” field (List<String>)
  List<String>? _related;
  List<String> get related => _related ?? const [];
  bool hasRelated() => _related != null;

  // “foodType” field (List<String>)
  List<String>? _foodType;
  List<String> get foodType => _foodType ?? const [];
  bool hasFoodType() => _foodType != null;

  // “dietType” field (List<String>)
  List<String>? _dietType;
  List<String> get dietType => _dietType ?? const [];
  bool hasDietType() => _dietType != null;

  // “category” field (List<String>)
  List<String>? _category;
  List<String> get category => _category ?? const [];
  bool hasCategory() => _category != null;

  /// Initialize all field values from `_snapshot.data()`.
  void _initializeFields() {
    final snapshotData = _snapshot.data() as Map<String, dynamic>;

    _mealName = snapshotData['mealName'] as String?;
    _createdby = snapshotData['createdby'] as String?;
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
  }

  // ──────────── Collection Reference ────────────

  /// A reference to the `meals3` collection in Firestore.
  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('meals3');

  /// Stream a single document’s changes.
  static Stream<meals3Record> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => meals3Record.fromSnapshot(s));

  /// Get a single document once.
  static Future<meals3Record> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => meals3Record.fromSnapshot(s));

  /// Construct a `meals3Record` from a Firestore snapshot.
  static meals3Record fromSnapshot(DocumentSnapshot snapshot) => meals3Record._(
        snapshot,
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  /// Construct a `meals3Record` from raw data (if you already have a Map).
  static meals3Record getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      meals3Record._(
        reference as DocumentSnapshot,
        reference,
        mapFromFirestore(data),
      );

  @override
  String toString() =>
      'meals3Record(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(Object other) =>
      other is meals3Record &&
      reference.path.hashCode == other.reference.path.hashCode;
}

/// Create a new Firestore‐compatible map for adding or updating a `meals3` document.
///
/// Pass in any of the fields you want to set; nulls will be removed.
Map<String, dynamic> createmeals3RecordData({
  String? mealName,
  String? createdby,
  List<String>? tags,
  List<String>? related,
  List<String>? foodType,
  List<String>? dietType,
  List<String>? category,
}) {
  final data = <String, dynamic>{
    'mealName': mealName,
    'createdby': createdby,
    'tags': tags,
    'related': related,
    'foodType': foodType,
    'dietType': dietType,
    'category': category,
  };
  data.removeWhere((key, value) => value == null);
  final firestoreData = mapToFirestore(data);

  return firestoreData;
}

/// Custom equality class for comparing two `meals3Record` objects by value.
class meals3RecordDocumentEquality implements Equality<meals3Record> {
  const meals3RecordDocumentEquality();

  @override
  bool equals(meals3Record? e1, meals3Record? e2) {
    return e1?.mealName == e2?.mealName &&
        e1?.createdby == e2?.createdby &&
        const ListEquality().equals(e1?.tags, e2?.tags) &&
        const ListEquality().equals(e1?.related, e2?.related) &&
        const ListEquality().equals(e1?.foodType, e2?.foodType) &&
        const ListEquality().equals(e1?.dietType, e2?.dietType) &&
        const ListEquality().equals(e1?.category, e2?.category);
  }

  @override
  int hash(meals3Record? e) => const ListEquality().hash([
        e?.mealName,
        e?.createdby,
        e?.tags,
        e?.related,
        e?.foodType,
        e?.dietType,
        e?.category,
      ]);

  @override
  bool isValidKey(Object? o) => o is meals3Record;
}
