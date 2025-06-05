import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SelectedMealsListRecord extends FirestoreRecord {
  SelectedMealsListRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "mealsList" field.
  List<String>? _mealsList;
  List<String> get mealsList => _mealsList ?? const [];
  bool hasMealsList() => _mealsList != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _mealsList = getDataList(snapshotData['mealsList']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('selectedMealsList')
          : FirebaseFirestore.instance.collectionGroup('selectedMealsList');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('selectedMealsList').doc(id);

  static Stream<SelectedMealsListRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SelectedMealsListRecord.fromSnapshot(s));

  static Future<SelectedMealsListRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => SelectedMealsListRecord.fromSnapshot(s));

  static SelectedMealsListRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SelectedMealsListRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SelectedMealsListRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SelectedMealsListRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SelectedMealsListRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SelectedMealsListRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSelectedMealsListRecordData({
  List<String>? mealsList,
}) {
  final firestoreData = mapToFirestore({
    'mealsList': mealsList,
  }.withoutNulls);

  return firestoreData;
}

class SelectedMealsListRecordDocumentEquality
    implements Equality<SelectedMealsListRecord> {
  const SelectedMealsListRecordDocumentEquality();

  @override
  bool equals(SelectedMealsListRecord? e1, SelectedMealsListRecord? e2) {
    const listEquality = ListEquality();
    return listEquality.equals(e1?.mealsList, e2?.mealsList);
  }

  @override
  int hash(SelectedMealsListRecord? e) =>
      const ListEquality().hash([e?.mealsList]);

  @override
  bool isValidKey(Object? o) => o is SelectedMealsListRecord;
}
