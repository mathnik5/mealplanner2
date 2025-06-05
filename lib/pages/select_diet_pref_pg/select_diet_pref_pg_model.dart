import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'select_diet_pref_pg_widget.dart' show SelectDietPrefPgWidget;
import 'package:flutter/material.dart';

class SelectDietPrefPgModel extends FlutterFlowModel<SelectDietPrefPgWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in selectDietPrefPg widget.
  MyMealsRecord? myMealsFetch;
  // Stores action output result for [Firestore Query - Query a collection] action in selectDietPrefPg widget.
  List<meals3Record>? meals3Fetch;
  // State field(s) for VegSwitch widget.
  bool? vegSwitchValue;
  // State field(s) for EggSwitch widget.
  bool? eggSwitchValue;
  // State field(s) for NonVegSwitch widget.
  bool? nonVegSwitchValue;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  SelectedMealsListRecord? selectedMealsFetch;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
