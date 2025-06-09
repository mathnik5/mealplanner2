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
import 'package:provider/provider.dart';
import 'search_pop_up_model.dart';
export 'search_pop_up_model.dart';

class SearchPopUpWidget extends StatefulWidget {
  final List<String>?
      initiallySelectedMealNames; // To pre-select meals when opened from planner

  const SearchPopUpWidget({
    super.key,
    this.initiallySelectedMealNames,
  });

  @override
  State<SearchPopUpWidget> createState() => _SearchPopUpWidgetState();
}

class _SearchPopUpWidgetState extends State<SearchPopUpWidget>
    with TickerProviderStateMixin {
  late SearchPopUpModel _model;
  late TabController _tabController;

  // Map category (tab name) -> List of selected meal names for this popup session
  final Map<String, List<String>> _selectedByCategory = {};

  // Category names in the same order as the tabs - NOW 4 TABS
  final List<String> _categories = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];
  final animationsMap = <String, AnimationInfo>{};

  // To store the globally selected meals (isSelected == true) fetched once
  List<MyMealsRecord> _globallySelectedMeals = [];

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchPopUpModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Initialize _selectedByCategory for all popup categories
    for (var cat in _categories) {
      _selectedByCategory[cat] = [];
    }

    _tabController = TabController(
      vsync: this,
      length: _categories.length,
      initialIndex: 0,
    )..addListener(() {
        if (_tabController.indexIsChanging) {
          // If it is, unfocus the main search bar to prevent errors
          _model.textFieldFocusNode?.unfocus();

          if (mounted) {
            setState(() {
              // This listener is sufficient for rebuilding UI on tab change
            });
          }
        }
      });
    // Assign it to the model as well, if other parts of the FF code rely on it.
    _model.tabBarController = _tabController;

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 200.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          MoveEffect(
            curve: Curves.bounceOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: const Offset(0.0, 100.0),
            end: const Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
  }

  void _initializeSelections(List<MyMealsRecord> allGloballySelectedMeals) {
    if (widget.initiallySelectedMealNames != null &&
        widget.initiallySelectedMealNames!.isNotEmpty) {
      for (String mealName in widget.initiallySelectedMealNames!) {
        final mealRecord = allGloballySelectedMeals
            .firstWhereOrNull((meal) => meal.mealName == mealName);

        if (mealRecord != null) {
          // Determine which pop-up category this meal belongs to.
          // A meal might belong to multiple (e.g., Lunch and Dinner).
          // For simplicity, add to first matching tab. Or handle more complex logic if needed.
          for (String tabCategory in _categories) {
            if (mealRecord.category.contains(tabCategory)) {
              if (!_selectedByCategory[tabCategory]!.contains(mealName)) {
                _selectedByCategory[tabCategory]!.add(mealName);
              }
              // If a meal can be in "Lunch" and "Dinner" categories,
              // and we have separate tabs, it should be pre-selected in both if applicable.
            } else if (tabCategory == "Lunch" &&
                mealRecord.category.contains("LunchDinner")) {
              if (!_selectedByCategory[tabCategory]!.contains(mealName)) {
                _selectedByCategory[tabCategory]!.add(mealName);
              }
            } else if (tabCategory == "Dinner" &&
                mealRecord.category.contains("LunchDinner")) {
              if (!_selectedByCategory[tabCategory]!.contains(mealName)) {
                _selectedByCategory[tabCategory]!.add(mealName);
              }
            }
          }
        }
      }
      // Ensure UI reflects these initial selections
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.maybeDispose(); // Disposes controllers managed by the model
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
      // 1. Filter by Tab's Category
      bool categoryMatch = meal.category.contains(tabCategoryName);
      // Special handling for combined categories if MyMealsRecord still uses them
      // For pop-up, "Lunch" tab shows "Lunch" meals, "Dinner" tab shows "Dinner" meals.
      // If a meal is in MyMealsRecord category: ['Lunch', 'Dinner'], it could appear in both.

      if (!categoryMatch) return false;

      // 2. Filter by diet (already applied to globallySelectedMeals, but good for safety)
      if (!_passesDietFilter(meal)) return false;

      // 3. Filter by search text
      if (searchText.isNotEmpty) {
        if (!meal.mealName.toLowerCase().contains(searchText)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Widget _buildMealCard(MyMealsRecord mealRecord, String currentTabCategory) {
    // Check if selected for the *current pop-up session* under this tab
    final bool isSelectedInPopup = _selectedByCategory[currentTabCategory]
            ?.contains(mealRecord.mealName) ??
        false;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5.0, 5.0, 5.0, 5.0),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          if (mounted) {
            setState(() {
              if (isSelectedInPopup) {
                _selectedByCategory[currentTabCategory]
                    ?.remove(mealRecord.mealName);
              } else {
                _selectedByCategory[currentTabCategory]
                    ?.add(mealRecord.mealName);
              }
            });
          }
        },
        child: Material(
          color: Colors.transparent,
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isSelectedInPopup
                  ? FlutterFlowTheme.of(context)
                      .secondary // A distinct selection color for pop-up
                  : FlutterFlowTheme.of(context).alternate,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Color(0x33000000),
                  offset: Offset(0.0, 2.0),
                )
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
                          ? Colors.white // Text color for selected items
                          : FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _buildAllowedDietOptionsForNewMeal() {
    final opts = <String>[];
    if (FFAppState().userPrefVeg) opts.add('Veg');
    if (FFAppState().userPrefEgg) opts.add('Egg');
    if (FFAppState().userPrefNonVeg) opts.add('NonVeg');
    return opts;
  }

  Widget _buildAddNewPill(String tabCategoryName, String foodTypeName,
      List<MyMealsRecord> allUserMealsForDuplicationCheck) {
    // This state should ideally be managed in the model if it needs to persist across rebuilds
    // For simplicity here, using a local state variable managed by StatefulWidget if this were a sub-widget.
    // Since it's part of the main widget, we can use a map in _SearchPopUpWidgetState or in _model
    // Let's assume we add a simple local state management for the "isAdding" state per foodType
    // For robust state, use the model's dynamic controllers.

    // For managing the specific "add new" input text for this category/foodType
    final TextEditingController currentTextController =
        _model.getAddNewMealTextController(tabCategoryName, foodTypeName);
    final FocusNode currentFocusNode =
        _model.getAddNewMealFocusNode(tabCategoryName, foodTypeName);

    // Local state for diet choice for this specific add new instance
    // This needs to be managed more robustly if many "add new" sections are open.
    // For now, we'll assume only one "add new" section is "active" for input at a time,
    // or we'd need a map for these diet choices too.
    // String _currentNewMealDietChoice = _buildAllowedDietOptionsForNewMeal().firstOrNull ?? '';

    return Row(
      mainAxisSize: MainAxisSize.min, // To keep row compact
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: TextFormField(
              controller: currentTextController,
              focusNode: currentFocusNode,
              autofocus: false, // Set to true if you want immediate focus
              obscureText: false,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Add to $foodTypeName',
                hintStyle: FlutterFlowTheme.of(context).labelMedium,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).primary,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ),
        ),
        FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 20.0,
          borderWidth: 1.0,
          buttonSize: 40.0,
          fillColor: FlutterFlowTheme.of(context).primary,
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 20.0,
          ),
          onPressed: () async {
            final newMealName = currentTextController.text.trim();
            if (newMealName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please enter a meal name.'),
                  backgroundColor: FlutterFlowTheme.of(context).error,
                ),
              );
              return;
            }

            // Duplication Check: Against all meals in MyMealsRecord for the current tab's category
            final duplicate = allUserMealsForDuplicationCheck.any((meal) =>
                meal.mealName.toLowerCase() == newMealName.toLowerCase() &&
                meal.category.contains(tabCategoryName));

            if (duplicate) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('$newMealName already exists in $tabCategoryName.'),
                  backgroundColor: FlutterFlowTheme.of(context).error,
                ),
              );
              return;
            }

            List<String> newMealDietTypes =
                _buildAllowedDietOptionsForNewMeal();
            // If multiple diet options available, user should pick one.
            // For simplicity, if multiple are allowed by user preference, assign all.
            // Or, add a small dropdown here if necessary. (As per MealSelectionPg, dropdown appears if >1 option)
            // Here, let's assume the user's general prefs apply.

            final newMealRef =
                currentUserReference!.collection('myMeals').doc();
            await newMealRef.set(createMyMealsRecordData(
              mealName: newMealName,
              category: [tabCategoryName],
              foodType: [foodTypeName], // From subheading
              dietType: newMealDietTypes.isNotEmpty
                  ? newMealDietTypes
                  : [], // Assign based on user's active prefs
              isSelected:
                  true, // New meals added from planner pop-up are considered selected
              createdBy: 'user',
              tags: [],
              related: [],
            ));

            currentTextController.clear();
            if (mounted) {
              setState(() {
                // Add to current pop-up selection
                _selectedByCategory[tabCategoryName]?.add(newMealName);
                // The StreamBuilder will pick up the new meal for display.
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '$newMealName added to $tabCategoryName and selected.'),
                backgroundColor: FlutterFlowTheme.of(context).success,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMealTab(String tabCategoryName, List<MyMealsRecord> sourceMeals,
      List<MyMealsRecord> allUserMealsForDuplicationCheck) {
    final mealsForThisTab =
        _getFilteredMealsForTabDisplay(sourceMeals, tabCategoryName);

    // Group by foodType
    Map<String, List<MyMealsRecord>> mealsByFoodType = {};
    for (var meal in mealsForThisTab) {
      if (meal.foodType.isNotEmpty) {
        for (String ft in meal.foodType) {
          // Iterate as foodType is List<String>
          mealsByFoodType.putIfAbsent(ft, () => []).add(meal);
        }
      } else {
        mealsByFoodType
            .putIfAbsent('Other', () => [])
            .add(meal); // Default group
      }
    }
    final sortedFoodTypes = mealsByFoodType.keys.toList()..sort();

    return SingleChildScrollView(
      key: PageStorageKey<String>(tabCategoryName), // Preserve scroll position
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mealsForThisTab.isEmpty &&
              (_model.textController1?.text.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                    'No meals found matching your search in "$tabCategoryName".',
                    style: FlutterFlowTheme.of(context).bodyMedium),
              ),
            )
          else if (mealsForThisTab.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                  child: Text(
                'No meals available for "$tabCategoryName" that match your selections and diet preferences.',
                style: FlutterFlowTheme.of(context).bodyMedium,
                textAlign: TextAlign.center,
              )),
            ),
          for (String foodTypeName in sortedFoodTypes) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(
                foodTypeName,
                style: FlutterFlowTheme.of(context).titleMedium,
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: mealsByFoodType[foodTypeName]!
                  .map((meal) => _buildMealCard(meal, tabCategoryName))
                  .toList(),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: _buildAddNewPill(tabCategoryName, foodTypeName,
                  allUserMealsForDuplicationCheck),
            ),
            const Divider(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 4.0),
        child: StreamBuilder<List<MyMealsRecord>>(
          stream: queryMyMealsRecord(parent: currentUserReference),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final allUserMeals = snapshot.data ?? [];

            // Filter for globally selected meals (isSelected == true) ONCE
            // and also apply diet filter here.
            _globallySelectedMeals = allUserMeals
                .where((meal) => meal.isSelected && _passesDietFilter(meal))
                .toList();

            // Initialize selections after _globallySelectedMeals is fetched for the first time
            if (widget.initiallySelectedMealNames != null &&
                _selectedByCategory.values.every((list) => list.isEmpty)) {
              // Only initialize if not already populated, to avoid re-initializing on every rebuild
              _initializeSelections(_globallySelectedMeals);
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 60.0, 0.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 770.0),
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30.0,
                            borderWidth: 1.0,
                            buttonSize: 44.0,
                            fillColor: FlutterFlowTheme.of(context).accent4,
                            icon: Icon(
                              Icons.close_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 2.0, 16.0, 8.0),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 770.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12.0,
                            color: Color(0x1E000000),
                            offset: Offset(0.0, 5.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SizedBox(
                          height: 60.0,
                          child: Center(
                            child: TextFormField(
                              controller: _model.textController1,
                              focusNode: _model.textFieldFocusNode,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Search meals...',
                                hintStyle:
                                    FlutterFlowTheme.of(context).labelLarge,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 20,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: FlutterFlowTheme.of(context).bodyLarge,
                              onChanged: (_) => setState(
                                  () {}), // Rebuild on search text change
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      child: Container(
                        width: double.infinity, // Was double.infinity
                        constraints: const BoxConstraints(
                            maxWidth: 770.0), // Added to constrain width
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0), // Added horizontal margin
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(
                              12.0), // ensure rounding if container is smaller
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: const Alignment(0.0, 0),
                              child: FlutterFlowButtonTabBar(
                                useToggleButtonStyle: false,
                                isScrollable: true,
                                labelStyle:
                                    FlutterFlowTheme.of(context).titleSmall,
                                unselectedLabelStyle:
                                    FlutterFlowTheme.of(context).bodyMedium,
                                labelColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                unselectedLabelColor:
                                    FlutterFlowTheme.of(context).secondaryText,
                                backgroundColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                unselectedBackgroundColor:
                                    FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                borderColor:
                                    FlutterFlowTheme.of(context).alternate,
                                unselectedBorderColor:
                                    FlutterFlowTheme.of(context).alternate,
                                borderWidth: 1.0,
                                borderRadius: 8.0,
                                elevation: 0.0,
                                labelPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                buttonMargin: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 8.0),
                                tabs: _categories
                                    .map((c) => Tab(text: c))
                                    .toList(), // Use _categories for tab text
                                controller: _tabController,
                                onTap: (i) => setState(() {}),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: _categories.map((categoryName) {
                                  return KeepAliveWidgetWrapper(
                                    // To preserve state across tabs
                                    builder: (context) => _buildMealTab(
                                        categoryName,
                                        _globallySelectedMeals, // Pass the pre-filtered list of globally selected meals
                                        allUserMeals // Pass all user meals for duplication check reference
                                        ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['containerOnPageLoadAnimation2']!),
                  ),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                        maxWidth: 770.0), // Constrain width
                    margin: const EdgeInsets.fromLTRB(
                        16.0, 0, 16.0, 0), // Match horizontal margin
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal:
                            16.0), // Horizontal padding might be redundant due to margin
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Selected for Planner Slot',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                        const SizedBox(height: 8.0),
                        // Display selected items from _selectedByCategory
                        ..._categories.expand((cat) {
                          // Iterate through pop-up categories
                          final items = _selectedByCategory[cat]!;
                          if (items.isEmpty) return [const SizedBox.shrink()];
                          return [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$cat: ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontWeight: FontWeight.bold,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                          ),
                                    ),
                                    TextSpan(
                                      text: items.join(', '),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ];
                        }),
                        if (_selectedByCategory.values
                            .every((list) => list.isEmpty))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No items selected for this slot yet.',
                              style: FlutterFlowTheme.of(context).bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 12.0),
                        FFButtonWidget(
                          onPressed: () {
                            final List<String> allSelectedNamesForSlot = _categories
                                .expand((cat) => _selectedByCategory[cat]!)
                                .toSet() // Ensure uniqueness if a meal name could appear under multiple selection categories
                                .toList();
                            Navigator.pop(context, allSelectedNamesForSlot);
                          },
                          text: 'OK',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 48.0,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleSmallFamily,
                                  color: Colors.white,
                                ),
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
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
