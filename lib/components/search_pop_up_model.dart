import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'search_pop_up_widget.dart' show SearchPopUpWidget;
import 'package:flutter/material.dart';

class SearchPopUpModel extends FlutterFlowModel<SearchPopUpWidget> {
  // State field(s) for the main TextField search bar.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;

  // State field(s) for TabBar widget (for meal categories like Breakfast, Lunch, etc.).
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  // tabBarPreviousIndex might not be needed if not used explicitly.
  // int get tabBarPreviousIndex =>
  //     tabBarController != null ? tabBarController!.previousIndex : 0;

  // --- Dynamic TextEditingControllers and FocusNodes for "Add New Meal" sections ---
  // Outer map key: categoryName (e.g., 'Breakfast', 'Lunch')
  // Inner map key: foodTypeName
  Map<String, Map<String, TextEditingController>> addNewMealTextControllers =
      {};
  Map<String, Map<String, FocusNode>> addNewMealFocusNodes = {};

  TextEditingController getAddNewMealTextController(
      String categoryName, String foodTypeName) {
    addNewMealTextControllers.putIfAbsent(categoryName, () => {});
    addNewMealTextControllers[categoryName]!
        .putIfAbsent(foodTypeName, () => TextEditingController());
    return addNewMealTextControllers[categoryName]![foodTypeName]!;
  }

  FocusNode getAddNewMealFocusNode(String categoryName, String foodTypeName) {
    addNewMealFocusNodes.putIfAbsent(categoryName, () => {});
    addNewMealFocusNodes[categoryName]!
        .putIfAbsent(foodTypeName, () => FocusNode());
    return addNewMealFocusNodes[categoryName]![foodTypeName]!;
  }
  // --- End of Dynamic Controllers ---

  // Removed specific controller for Breakfast "Add New" as it's now dynamic.
  /*
  // State field(s) for TextFieldBF widget.
  FocusNode? textFieldBFFocusNode;
  TextEditingController? textFieldBFTextController;
  String? Function(BuildContext, String?)? textFieldBFTextControllerValidator;
  */

  // Removed ChoiceChips fields as they are not used in the described UI.
  /*
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  */

  @override
  void initState(BuildContext context) {
    // Initialization for any direct fields if needed
  }

  @override
  void dispose() {
    // Dispose of main search bar controller and focus node
    textFieldFocusNode?.dispose();
    textController1?.dispose();

    // Dispose of TabBar controller
    tabBarController?.dispose();

    // Dispose of all dynamically created "Add New Meal" controllers and focus nodes
    for (final categoryControllers in addNewMealTextControllers.values) {
      for (final controller in categoryControllers.values) {
        controller.dispose();
      }
    }
    addNewMealTextControllers.clear();

    for (final categoryFocusNodes in addNewMealFocusNodes.values) {
      for (final focusNode in categoryFocusNodes.values) {
        focusNode.dispose();
      }
    }
    addNewMealFocusNodes.clear();

    // Removed disposal for textFieldBFFocusNode and textFieldBFTextController
    // Removed disposal for choiceChipsValueController
  }
}
