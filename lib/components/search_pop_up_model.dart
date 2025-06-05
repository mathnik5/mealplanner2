import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'search_pop_up_widget.dart' show SearchPopUpWidget;
import 'package:flutter/material.dart';

class SearchPopUpModel extends FlutterFlowModel<SearchPopUpWidget> {
  ///  Local state fields for this component.
  /// Items selected for adding to the daily menu
  List<String> addedToCart = [];
  void addToAddedToCart(String item) => addedToCart.add(item);
  void removeFromAddedToCart(String item) => addedToCart.remove(item);
  void removeAtIndexFromAddedToCart(int index) => addedToCart.removeAt(index);
  void insertAtIndexInAddedToCart(int index, String item) =>
      addedToCart.insert(index, item);
  void updateAddedToCartAtIndex(int index, Function(String) updateFn) =>
      addedToCart[index] = updateFn(addedToCart[index]);

  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for TextFieldBF widget.
  FocusNode? textFieldBFFocusNode;
  TextEditingController? textFieldBFTextController;
  String? Function(BuildContext, String?)? textFieldBFTextControllerValidator;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController1?.dispose();

    tabBarController?.dispose();
    textFieldBFFocusNode?.dispose();
    textFieldBFTextController?.dispose();
  }
}
