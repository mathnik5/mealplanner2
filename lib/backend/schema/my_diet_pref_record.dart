import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// User's Veg and Non veg preference
class MyDietPrefRecord extends FirestoreRecord {
  MyDietPrefRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "veg" field.
  bool? _veg;
  bool get veg => _veg ?? false;
  bool hasVeg() => _veg != null;

  // "nonVeg" field.
  bool? _nonVeg;
  bool get nonVeg => _nonVeg ?? false;
  bool hasNonVeg() => _nonVeg != null;

  // "egg" field.
  bool? _egg;
  bool get egg => _egg ?? false;
  bool hasEgg() => _egg != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _veg = snapshotData['veg'] as bool?;
    _nonVeg = snapshotData['nonVeg'] as bool?;
    _egg = snapshotData['egg'] as bool?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('myDietPref')
          : FirebaseFirestore.instance.collectionGroup('myDietPref');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('myDietPref').doc(id);

  static Stream<MyDietPrefRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MyDietPrefRecord.fromSnapshot(s));

  static Future<MyDietPrefRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MyDietPrefRecord.fromSnapshot(s));

  static MyDietPrefRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MyDietPrefRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MyDietPrefRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MyDietPrefRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MyDietPrefRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MyDietPrefRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMyDietPrefRecordData({
  bool? veg,
  bool? nonVeg,
  bool? egg,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'veg': veg,
      'nonVeg': nonVeg,
      'egg': egg,
    }.withoutNulls,
  );

  return firestoreData;
}

class MyDietPrefRecordDocumentEquality implements Equality<MyDietPrefRecord> {
  const MyDietPrefRecordDocumentEquality();

  @override
  bool equals(MyDietPrefRecord? e1, MyDietPrefRecord? e2) {
    return e1?.veg == e2?.veg && e1?.nonVeg == e2?.nonVeg && e1?.egg == e2?.egg;
  }

  @override
  int hash(MyDietPrefRecord? e) =>
      const ListEquality().hash([e?.veg, e?.nonVeg, e?.egg]);

  @override
  bool isValidKey(Object? o) => o is MyDietPrefRecord;
}
