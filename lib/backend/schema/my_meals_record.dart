import 'dart:async';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart'; // For utility like .withoutNulls in createMyMealsRecordData

class MyMealsRecord extends FirestoreRecord {
  MyMealsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "mealName" field.
  String? _mealName;
  String get mealName => _mealName ?? '';
  bool hasMealName() => _mealName != null;

  // "createdBy" field.
  String? _createdBy;
  String get createdBy => _createdBy ?? '';
  bool hasCreatedBy() => _createdBy != null;

  // "tags" field. (List<String>)
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  // "related" field. (List<String>)
  List<String>? _related;
  List<String> get related => _related ?? const [];
  bool hasRelated() => _related != null;

  // "foodType" field. (List<String>)
  List<String>? _foodType;
  List<String> get foodType => _foodType ?? const [];
  bool hasFoodType() => _foodType != null;

  // "dietType" field. (List<String>)
  List<String>? _dietType;
  List<String> get dietType => _dietType ?? const [];
  bool hasDietType() => _dietType != null;

  // "category" field. (List<String>)
  List<String>? _category;
  List<String> get category => _category ?? const [];
  bool hasCategory() => _category != null;

  // "isSelected" field. (Boolean)
  bool? _isSelected;
  bool get isSelected => _isSelected ?? false;
  bool hasIsSelected() => _isSelected != null;

  void _initializeFields() {
    _mealName = snapshotData['mealName'] as String?;
    _createdBy = snapshotData['createdBy'] as String?;
    _tags = getDataList(snapshotData['tags']);
    _related = getDataList(snapshotData['related']);
    _foodType = getDataList(snapshotData['foodType']);
    _dietType = getDataList(snapshotData['dietType']);
    _category = getDataList(snapshotData['category']);
    _isSelected = snapshotData['isSelected'] as bool?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection(
              'myMeals') // Assuming 'myMeals' is the correct subcollection name
          : FirebaseFirestore.instance.collectionGroup('myMeals');
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
  bool operator ==(other) =>
      other is MyMealsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

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
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'mealName': mealName,
      'createdBy': createdBy,
      'tags': tags,
      'related': related,
      'foodType': foodType,
      'dietType': dietType,
      'category': category,
      'isSelected': isSelected,
    }.withoutNulls,
  );

  return firestoreData;
}

class MyMealsRecordDocumentEquality implements Equality<MyMealsRecord> {
  const MyMealsRecordDocumentEquality();

  @override
  bool equals(MyMealsRecord? e1, MyMealsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.mealName == e2?.mealName &&
        e1?.createdBy == e2?.createdBy &&
        listEquality.equals(e1?.tags, e2?.tags) &&
        listEquality.equals(e1?.related, e2?.related) &&
        listEquality.equals(e1?.foodType, e2?.foodType) &&
        listEquality.equals(e1?.dietType, e2?.dietType) &&
        listEquality.equals(e1?.category, e2?.category) &&
        e1?.isSelected == e2?.isSelected;
  }

  @override
  int hash(MyMealsRecord? e) => const ListEquality().hash([
        e?.mealName,
        e?.createdBy,
        e?.tags,
        e?.related,
        e?.foodType,
        e?.dietType,
        e?.category,
        e?.isSelected
      ]);

  @override
  bool isValidKey(Object? o) => o is MyMealsRecord;
}
