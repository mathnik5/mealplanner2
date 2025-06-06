import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import 'index.dart';

import '/backend/schema/util/schema_util.dart'; // For getDataList
// import 'index.dart'; // Usually not needed within a specific record file itself unless referencing other records directly by type
import '/flutter_flow/flutter_flow_util.dart'; // For .withoutNulls in createmeals3RecordData

class meals3Record extends FirestoreRecord {
  meals3Record._(
    super.reference,
    super.data,
  ) {
    // Passes reference and data to FirestoreRecord base
    _initializeFields();
  }

  // Fields
  String? _mealName;
  String get mealName => _mealName ?? '';
  bool hasMealName() => _mealName != null;

  String?
      _createdby; // Note: Firestore fields are often camelCase (e.g., createdBy) by convention
  String get createdby => _createdby ?? '';
  bool hasCreatedby() => _createdby != null;

  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  List<String>? _related;
  List<String> get related => _related ?? const [];
  bool hasRelated() => _related != null;

  List<String>? _foodType;
  List<String> get foodType => _foodType ?? const [];
  bool hasFoodType() => _foodType != null;

  List<String>? _dietType;
  List<String> get dietType => _dietType ?? const [];
  bool hasDietType() => _dietType != null;

  List<String>? _category;
  List<String> get category => _category ?? const [];
  bool hasCategory() => _category != null;

  void _initializeFields() {
    // Uses `this.snapshotData` from the FirestoreRecord base class
    _mealName = snapshotData['mealName'] as String?;
    _createdby = snapshotData['createdby']
        as String?; // Assuming 'createdby' is the field name in Firestore
    _tags = getDataList(snapshotData['tags']);
    _related = getDataList(snapshotData['related']);
    _foodType = getDataList(snapshotData['foodType']);
    _dietType = getDataList(snapshotData['dietType']);
    _category = getDataList(snapshotData['category']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('meals3');

  static Stream<meals3Record> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => meals3Record.fromSnapshot(s));

  static Future<meals3Record> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => meals3Record.fromSnapshot(s));

  static meals3Record fromSnapshot(DocumentSnapshot snapshot) => meals3Record._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static meals3Record getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      meals3Record._(
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

Map<String, dynamic> createmeals3RecordData({
  String? mealName,
  String? createdby,
  List<String>? tags,
  List<String>? related,
  List<String>? foodType,
  List<String>? dietType,
  List<String>? category,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'mealName': mealName,
      'createdby': createdby,
      'tags': tags,
      'related': related,
      'foodType': foodType,
      'dietType': dietType,
      'category': category,
    }.withoutNulls, // This utility is from flutter_flow_util.dart
  );

  return firestoreData;
}

class meals3RecordDocumentEquality implements Equality<meals3Record> {
  const meals3RecordDocumentEquality();

  @override
  bool equals(meals3Record? e1, meals3Record? e2) {
    const listEquality = ListEquality();
    return e1?.mealName == e2?.mealName &&
        e1?.createdby == e2?.createdby &&
        listEquality.equals(e1?.tags, e2?.tags) &&
        listEquality.equals(e1?.related, e2?.related) &&
        listEquality.equals(e1?.foodType, e2?.foodType) &&
        listEquality.equals(e1?.dietType, e2?.dietType) &&
        listEquality.equals(e1?.category, e2?.category);
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
