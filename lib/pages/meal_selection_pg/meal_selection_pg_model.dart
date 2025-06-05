import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'meal_selection_pg_widget.dart' show MealSelectionPgWidget;
import 'package:flutter/material.dart';

class MealSelectionPgModel extends FlutterFlowModel<MealSelectionPgWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in mealSelectionPg widget.
  SelectedMealsListRecord? userSelectionDBQuery;
  // State field(s) for TextFieldBF widget.
  FocusNode? textFieldBFFocusNode;
  TextEditingController? textFieldBFTextController;
  String? Function(BuildContext, String?)? textFieldBFTextControllerValidator;
  // State field(s) for TextFieldLunch widget.
  FocusNode? textFieldLunchFocusNode;
  TextEditingController? textFieldLunchTextController;
  String? Function(BuildContext, String?)?
      textFieldLunchTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldBFFocusNode?.dispose();
    textFieldBFTextController?.dispose();

    textFieldLunchFocusNode?.dispose();
    textFieldLunchTextController?.dispose();
  }
}
