import 'package:collection/collection.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'search_pop_up_model.dart';
export 'search_pop_up_model.dart';

class SearchPopUpWidget extends StatefulWidget {
  final String mode; // Can be 'singleSlot' or 'fullDay'
  final String?
      activeCategory; // e.g. 'Lunch', for singleSlot mode and initial tab
  final DateTime? dayDate; // For the header in 'fullDay' mode
  final Map<String, List<String>>? initialSelections; // Pre-selected items

  const SearchPopUpWidget({
    super.key,
    required this.mode,
    this.activeCategory,
    this.dayDate,
    this.initialSelections,
  });

  @override
  State<SearchPopUpWidget> createState() => _SearchPopUpWidgetState();
}

class _SearchPopUpWidgetState extends State<SearchPopUpWidget>
    with TickerProviderStateMixin {
  late SearchPopUpModel _model;
  late TabController _tabController;
  final Map<String, List<String>> _selectedByCategory = {};
  final List<String> _categories = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];
  final animationsMap = <String, AnimationInfo>{};
  List<MyMealsRecord> _globallySelectedMeals = [];
  final List<String> _foodTypeOrder = const [
    'Staple',
    'Gravy',
    'Dry Subji',
    'Accompaniments',
    'Snack',
    'Starter',
    'Soups',
    'Salad',
    'Fruits',
    'Drinks',
    'Dessert'
  ];
  final Map<String, Map<String, bool>> _isAdding = {};
  final Map<String, Map<String, TextEditingController>> _textControllers = {};
  final Map<String, Map<String, FocusNode>> _focusNodes = {};
  final Map<String, Map<String, String>> _dietChoices = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchPopUpModel());
    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    for (var cat in _categories) {
      _selectedByCategory[cat] = widget.initialSelections?[cat] ?? [];
      _ensureCategoryInitialized(cat);
    }

    final initialIndex =
        _categories.indexOf(widget.activeCategory ?? 'Breakfast');
    _tabController = TabController(
      vsync: this,
      length: _categories.length,
      initialIndex: initialIndex > -1 ? initialIndex : 0,
    );
    _model.tabBarController = _tabController;
    _tabController.addListener(_handleTabSelection);

    animationsMap.addAll({
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          MoveEffect(
              curve: Curves.bounceOut,
              delay: 300.0.ms,
              duration: 400.0.ms,
              begin: const Offset(0.0, 100.0),
              end: const Offset(0.0, 0.0)),
          FadeEffect(
              curve: Curves.easeInOut,
              delay: 300.0.ms,
              duration: 400.0.ms,
              begin: 0.0,
              end: 1.0),
        ],
      ),
    });
    setupAnimations(
        animationsMap.values.where((anim) =>
            anim.trigger == AnimationTrigger.onActionTrigger ||
            !anim.applyInitialState),
        this);
  }

  void setStateIfMounted() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _model.textFieldFocusNode?.unfocus();
      setStateIfMounted();
    }
  }

  void _ensureCategoryInitialized(String categoryKey) {
    _isAdding.putIfAbsent(categoryKey, () => {});
    _textControllers.putIfAbsent(categoryKey, () => {});
    _focusNodes.putIfAbsent(categoryKey, () => {});
    _dietChoices.putIfAbsent(categoryKey, () => {});
  }

  void _ensureFoodTypeInitialized(String categoryKey, String foodType) {
    _ensureCategoryInitialized(categoryKey);
    _isAdding[categoryKey]!.putIfAbsent(foodType, () => false);
    _textControllers[categoryKey]!
        .putIfAbsent(foodType, () => TextEditingController());
    _focusNodes[categoryKey]!.putIfAbsent(foodType, () => FocusNode());
    _dietChoices[categoryKey]!.putIfAbsent(
        foodType, () => _buildAllowedDietOptions().firstOrNull ?? '');
  }

  bool isAdding(String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    return _isAdding[categoryKey]![foodType]!;
  }

  void setAdding(String categoryKey, String foodType, bool value) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    setState(() {
      _isAdding[categoryKey]![foodType] = value;
    });
  }

  TextEditingController getTextController(String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    return _textControllers[categoryKey]![foodType]!;
  }

  FocusNode getAddNewMealFocusNode(String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    return _focusNodes[categoryKey]![foodType]!;
  }

  String getDietChoice(String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    return _dietChoices[categoryKey]![foodType]!;
  }

  void setDietChoice(String categoryKey, String foodType, String value) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    setState(() {
      _dietChoices[categoryKey]![foodType] = value;
    });
  }

  void _unselectMeal(String mealName) {
    setState(() {
      for (var category in _selectedByCategory.keys) {
        _selectedByCategory[category]?.remove(mealName);
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _model.maybeDispose();
    for (var catKey in _textControllers.keys) {
      _textControllers[catKey]
          ?.forEach((_, controller) => controller.dispose());
    }
    for (var catKey in _focusNodes.keys) {
      _focusNodes[catKey]?.forEach((_, node) => node.dispose());
    }
    super.dispose();
  }

  bool _passesDietFilter(MyMealsRecord meal) {
    final wantVeg = FFAppState().userPrefVeg;
    final wantEgg = FFAppState().userPrefEgg;
    final wantNonVeg = FFAppState().userPrefNonVeg;
    if (!wantVeg && !wantEgg && !wantNonVeg) return true;
    final mealDietTypes = meal.dietType;
    if (mealDietTypes.isEmpty) return true;
    bool passes = false;
    if (wantVeg && mealDietTypes.contains('Veg')) passes = true;
    if (wantEgg && mealDietTypes.contains('Egg')) passes = true;
    if (wantNonVeg && mealDietTypes.contains('NonVeg')) passes = true;
    return passes;
  }

  List<MyMealsRecord> _getFilteredMealsForTabDisplay(
      List<MyMealsRecord> globallySelectedMeals, String tabCategoryName) {
    String searchText = _model.textController1?.text.toLowerCase().trim() ?? "";
    return globallySelectedMeals.where((meal) {
      if (!meal.category.contains(tabCategoryName)) return false;
      if (!_passesDietFilter(meal)) return false;
      if (searchText.isNotEmpty) {
        if (!meal.mealName.toLowerCase().contains(searchText)) return false;
      }
      return true;
    }).toList();
  }

  Widget _buildMealCard(MyMealsRecord mealRecord, String currentTabCategory) {
    final bool isSelectedInPopup = _selectedByCategory[currentTabCategory]
            ?.contains(mealRecord.mealName) ??
        false;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5.0, 5.0, 5.0, 5.0),
      child: InkWell(
        onTap: () async {
          // Make the function async
          if (!mounted) return;

          // This check correctly determines if the meal is selected anywhere in the popup
          final bool isSelectedInPopup = _selectedByCategory.values
              .expand((list) => list)
              .contains(mealRecord.mealName);

          if (isSelectedInPopup) {
            // This part is for un-selecting, which works globally.
            setState(() {
              _unselectMeal(mealRecord.mealName);
            });
          } else {
            // This part is for selecting a meal.

            // 1. Determine the REAL destination for this meal.
            // In 'singleSlot' mode, it's always the category we started with (e.g., 'Lunch').
            // In 'fullDay' mode, it's the category of the tab we're currently on.
            final String destinationCategory = widget.mode == 'singleSlot'
                ? widget.activeCategory!
                : currentTabCategory;

            // 2. Optimistically update the UI for instant feedback.
            setState(() {
              // Add the meal to the correct category list in our local state.
              _selectedByCategory[destinationCategory]
                  ?.add(mealRecord.mealName);
            });

            // 3. Prepare and perform the database update asynchronously.
            final mealCategories = mealRecord.category?.toList() ?? [];
            bool needsDbUpdate = false;
            Map<String, dynamic> updates = {};

            // Check if the DESTINATION category needs to be added to the meal's data.
            if (!mealCategories.contains(destinationCategory)) {
              mealCategories.add(destinationCategory);
              updates['category'] = mealCategories.toSet().toList();
              needsDbUpdate = true;
            }

            // Also check if it needs to be promoted to a "usual" meal.
            if (!mealRecord.isSelected) {
              updates['isSelected'] = true;
              needsDbUpdate = true;
            }

            // 4. If any updates are needed, send them to Firestore.
            if (needsDbUpdate) {
              try {
                print(
                    'Attempting to update ${mealRecord.mealName} with: $updates');
                await mealRecord.reference.update(updates);
                print('Update successful for ${mealRecord.mealName}');
              } catch (e) {
                print('!!! ERROR updating meal: $e');
                // If the database update fails, revert the UI change.
                setState(() {
                  _unselectMeal(mealRecord.mealName);
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Could not update meal. Please try again.')),
                  );
                }
              }
            }
          }
        },
        child: Material(
          color: Colors.transparent,
          elevation: 1.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          child: Container(
            decoration: BoxDecoration(
              color: isSelectedInPopup
                  ? FlutterFlowTheme.of(context).secondary
                  : FlutterFlowTheme.of(context).alternate,
              boxShadow: const [
                BoxShadow(
                    blurRadius: 4.0,
                    color: Color(0x33000000),
                    offset: Offset(0.0, 2.0))
              ],
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
              child: Text(
                mealRecord.mealName,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: isSelectedInPopup
                          ? Colors.white
                          : FlutterFlowTheme.of(context).primaryText,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _buildAllowedDietOptions() {
    final opts = <String>[];
    if (FFAppState().userPrefVeg) opts.add('Veg');
    if (FFAppState().userPrefEgg) opts.add('Egg');
    if (FFAppState().userPrefNonVeg) opts.add('NonVeg');
    return opts;
  }

  Widget _buildAddNewPill(String tabCategoryName, String foodTypeName,
      List<MyMealsRecord> allUserMealsForDuplicationCheck) {
    if (!isAdding(tabCategoryName, foodTypeName)) {
      return GestureDetector(
        onTap: () => setAdding(tabCategoryName, foodTypeName, true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: FlutterFlowTheme.of(context).primary),
          ),
          child:
              Icon(Icons.add, color: FlutterFlowTheme.of(context).primaryText),
        ),
      );
    } else {
      final controller = getTextController(tabCategoryName, foodTypeName);
      final focusNode = getAddNewMealFocusNode(tabCategoryName, foodTypeName);
      final dietOptions = _buildAllowedDietOptions();
      String currentDietSelection =
          getDietChoice(tabCategoryName, foodTypeName);
      if (!dietOptions.contains(currentDietSelection) &&
          dietOptions.isNotEmpty) {
        currentDietSelection = dietOptions.first;
        setDietChoice(tabCategoryName, foodTypeName, currentDietSelection);
      }
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        height: 48,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'New meal name',
                  hintStyle: FlutterFlowTheme.of(context).labelMedium,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(8.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
            ),
            if (dietOptions.length > 1) ...[
              const SizedBox(width: 8.0),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 2)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        currentDietSelection.isEmpty && dietOptions.isNotEmpty
                            ? dietOptions.first
                            : currentDietSelection,
                    items: dietOptions
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) =>
                        setDietChoice(tabCategoryName, foodTypeName, val!),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8.0),
            InkWell(
              onTap: () async {
                final newMealName = controller.text.trim();
                if (newMealName.isEmpty) return;

                // Normalize for case-insensitive lookup
                final newMealLower = newMealName.toLowerCase();

                // 1. Query by lowercase name
                final querySnapshot = await currentUserReference!
                    .collection('myMeals')
                    .where('mealNameLower', isEqualTo: newMealLower)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  // 2a. Found → update existing doc
                  final docRef = querySnapshot.docs.first.reference;
                  await docRef.update({
                    'category': FieldValue.arrayUnion([tabCategoryName]),
                    'isSelected': true,
                  });
                } else {
                  // 2b. Not found → create new doc
                  // Determine diet choice
                  String chosenDiet = (dietOptions.length == 1)
                      ? dietOptions.first
                      : getDietChoice(tabCategoryName, foodTypeName);
                  if (chosenDiet.isEmpty && dietOptions.isNotEmpty) {
                    chosenDiet = dietOptions.first;
                  }

                  final newDoc =
                      currentUserReference!.collection('myMeals').doc();
                  await newDoc.set({
                    'mealName': newMealName,
                    'mealNameLower': newMealLower, // ← new field
                    'category': [tabCategoryName],
                    'foodType': [foodTypeName],
                    'dietType':
                        chosenDiet.isNotEmpty ? [chosenDiet] : <String>[],
                    'isSelected': true,
                    'createdBy': 'user',
                    'tags': <String>[],
                    'related': <String>[],
                  });
                }

                // 3. UI cleanup
                controller.clear();
                setAdding(tabCategoryName, foodTypeName, false);
                if (mounted) {
                  setState(() {
                    _selectedByCategory[tabCategoryName]?.add(newMealName);
                  });
                }
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFoodTypeSection(
      String foodTypeName,
      List<MyMealsRecord> meals,
      String tabCategoryName,
      List<MyMealsRecord> allUserMealsForDuplicationCheck) {
    meals.sort(
        (a, b) => a.mealName.toLowerCase().compareTo(b.mealName.toLowerCase()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(
            foodTypeName,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily:
                    GoogleFonts.inter(fontWeight: FontWeight.w600).fontFamily),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ...meals
                .map((meal) => _buildMealCard(meal, tabCategoryName))
                .toList(),
            _buildAddNewPill(
                tabCategoryName, foodTypeName, allUserMealsForDuplicationCheck),
          ],
        ),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildMealTab(String tabCategoryName, List<MyMealsRecord> sourceMeals,
      List<MyMealsRecord> allUserMealsForDuplicationCheck) {
    final mealsForThisTab =
        _getFilteredMealsForTabDisplay(sourceMeals, tabCategoryName);
    Map<String, List<MyMealsRecord>> mealsByFoodType = {};
    for (var meal in mealsForThisTab) {
      (meal.foodType.isNotEmpty ? meal.foodType : ['Other']).forEach((ft) {
        mealsByFoodType.putIfAbsent(ft, () => []).add(meal);
      });
    }
    List<Widget> foodTypeSections = [];
    for (String foodTypeName in _foodTypeOrder) {
      if (mealsByFoodType.containsKey(foodTypeName)) {
        foodTypeSections.add(_buildFoodTypeSection(
            foodTypeName,
            mealsByFoodType[foodTypeName]!,
            tabCategoryName,
            allUserMealsForDuplicationCheck));
        mealsByFoodType.remove(foodTypeName);
      }
    }
    for (String foodTypeName in mealsByFoodType.keys.toList()..sort()) {
      foodTypeSections.add(_buildFoodTypeSection(
          foodTypeName,
          mealsByFoodType[foodTypeName]!,
          tabCategoryName,
          allUserMealsForDuplicationCheck));
    }
    return SingleChildScrollView(
      key: PageStorageKey<String>(tabCategoryName),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: foodTypeSections.isNotEmpty
            ? foodTypeSections
            : [
                if ((_model.textController1?.text.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                        child: Text(
                            'No meals found matching your search in "$tabCategoryName".',
                            style: FlutterFlowTheme.of(context).bodyMedium)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                        child: Text(
                            'No meals available for "$tabCategoryName". You can add new ones in each section.',
                            style: FlutterFlowTheme.of(context).bodyMedium,
                            textAlign: TextAlign.center)),
                  ),
              ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    Widget buildHeader() {
      if (widget.mode == 'fullDay') {
        return Column(
          children: [
            Text('Planning All Meals for',
                style: FlutterFlowTheme.of(context).headlineSmall),
            Text(DateFormat("EEEE, MMM d").format(widget.dayDate!),
                style: FlutterFlowTheme.of(context)
                    .headlineMedium
                    .override(color: FlutterFlowTheme.of(context).primary)),
            const SizedBox(height: 4),
            Text('Selected items will be auto-sorted by category',
                style: FlutterFlowTheme.of(context).bodySmall),
          ],
        );
      } else {
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: FlutterFlowTheme.of(context).headlineSmall,
            children: [
              const TextSpan(text: 'Adding Meals to your '),
              TextSpan(
                  text: widget.activeCategory?.toUpperCase() ?? 'PLAN',
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }
    }

    Widget buildBottomSummary() {
      if (widget.mode == 'fullDay') {
        final hasSelections =
            _selectedByCategory.values.any((list) => list.isNotEmpty);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Plan Summary:',
                style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 8.0),
            if (!hasSelections)
              Text('No items selected yet.',
                  style: FlutterFlowTheme.of(context).bodySmall),
            if (hasSelections)
              ..._categories.map((cat) {
                final items = _selectedByCategory[cat]!;
                if (items.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$cat: ',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Wrap(
                          spacing: 6.0,
                          runSpacing: 6.0,
                          children: items
                              .map((item) => Chip(
                                    label: Text(item,
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).alternate,
                                    deleteIcon:
                                        const Icon(Icons.close, size: 14),
                                    onDeleted: () => _unselectMeal(item),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      } else {
        final allSelectedForSlot =
            _selectedByCategory.values.expand((list) => list).toSet().toList();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items to Add to ${widget.activeCategory ?? 'Slot'}:',
                style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 8.0),
            if (allSelectedForSlot.isNotEmpty)
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: allSelectedForSlot
                    .map((item) => Chip(
                          label: Text(item,
                              style: FlutterFlowTheme.of(context).bodySmall),
                          backgroundColor:
                              FlutterFlowTheme.of(context).alternate,
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => _unselectMeal(item),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                        ))
                    .toList(),
              )
            else
              Text('No items selected yet.',
                  style: FlutterFlowTheme.of(context).bodySmall),
          ],
        );
      }
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 4.0),
        child: StreamBuilder<List<MyMealsRecord>>(
          stream: queryMyMealsRecord(parent: currentUserReference),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final allUserMeals = snapshot.data ?? [];
            _globallySelectedMeals = allUserMeals
                .where((meal) => meal.isSelected && _passesDietFilter(meal))
                .toList();

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 40.0, 0.0, 0.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: FlutterFlowIconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () => Navigator.pop(context)))
                        ]),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 770.0),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: buildHeader()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextFormField(
                                controller: _model.textController1,
                                focusNode: _model.textFieldFocusNode,
                                onChanged: (_) => setStateIfMounted(),
                                decoration: InputDecoration(
                                    hintText: 'Search meals...',
                                    hintStyle:
                                        FlutterFlowTheme.of(context).labelLarge,
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)))),
                          ),
                          const SizedBox(height: 8),
                          FlutterFlowButtonTabBar(
                              tabs:
                                  _categories.map((c) => Tab(text: c)).toList(),
                              controller: _tabController,
                              onTap: (i) {}),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: _categories
                                  .map((categoryName) => KeepAliveWidgetWrapper(
                                        builder: (context) => _buildMealTab(
                                            categoryName,
                                            _globallySelectedMeals,
                                            allUserMeals),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 770.0),
                    margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: const [
                        BoxShadow(
                            blurRadius: 12.0,
                            color: Color(0x1E000000),
                            offset: Offset(0.0, 5.0))
                      ],
                    ),
                    child: Column(
                      children: [
                        buildBottomSummary(),
                        const SizedBox(height: 16),
                        FFButtonWidget(
                          onPressed: () {
                            if (widget.mode == 'fullDay') {
                              Navigator.pop(context, _selectedByCategory);
                            } else {
                              final List<String> allSelectedNames =
                                  _selectedByCategory.values
                                      .expand((list) => list)
                                      .toSet()
                                      .toList();
                              Navigator.pop(context, allSelectedNames);
                            }
                          },
                          text: 'OK',
                          options: FFButtonOptions(
                              width: double.infinity,
                              height: 48.0,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(color: Colors.white),
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
