import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/auth/firebase_auth/auth_util.dart';
import 'package:provider/provider.dart';
import '/backend/schema/my_meals_record.dart';
import '/backend/schema/selected_meals_list_record.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart' hide WeeklyPlannerPgWidget;
import '/index.dart';
import 'meal_selection_pg_model.dart';

export 'meal_selection_pg_model.dart';

class MealSelectionPgWidget extends StatefulWidget {
  const MealSelectionPgWidget({super.key}); // Constructor should be const

  static String routeName = 'mealSelectionPg';
  static String routePath = '/mealSelectionPg';

  @override
  _MealSelectionPgWidgetState createState() => _MealSelectionPgWidgetState();
}

class _MealSelectionPgWidgetState extends State<MealSelectionPgWidget>
    with TickerProviderStateMixin {
  late MealSelectionPgModel _model;
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _categories = ['Breakfast', 'LunchDinner', 'Snacks'];
  final Map<String, String> _categoryLabels = {
    'Breakfast': 'Breakfast',
    'LunchDinner': 'Lunch & Dinner',
    'Snacks': 'Snacks',
  };

  // State variables moved from Widget to State class
  final Map<String, Map<String, bool>> _isAdding = {};
  final Map<String, Map<String, TextEditingController>> _textControllers = {};
  final Map<String, Map<String, FocusNode>> _focusNodes = {}; // For FocusNodes
  final Map<String, Map<String, String>> _dietChoices = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MealSelectionPgModel());
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );

    // Initialize maps for each category to prevent null issues later
    for (var categoryKey in _categories) {
      _ensureCategoryInitialized(categoryKey);
    }
  }

  void _ensureCategoryInitialized(String categoryKey) {
    _isAdding.putIfAbsent(categoryKey, () => {});
    _textControllers.putIfAbsent(categoryKey, () => {});
    _focusNodes.putIfAbsent(categoryKey, () => {});
    _dietChoices.putIfAbsent(categoryKey, () => {});
  }

  void _ensureFoodTypeInitialized(String categoryKey, String foodType) {
    _ensureCategoryInitialized(categoryKey); // Ensures category map exists
    _isAdding[categoryKey]!.putIfAbsent(foodType, () => false);
    _textControllers[categoryKey]!
        .putIfAbsent(foodType, () => TextEditingController());
    _focusNodes[categoryKey]!.putIfAbsent(foodType, () => FocusNode());
    // Initialize diet choice with the first available option or empty
    _dietChoices[categoryKey]!.putIfAbsent(
        foodType, () => _buildAllowedDietOptions().firstOrNull ?? '');
  }

  // Helper methods now part of the State class
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

  List<String> _buildAllowedDietOptions() {
    final opts = <String>[];
    if (FFAppState().userPrefVeg) opts.add('Veg');
    if (FFAppState().userPrefEgg) opts.add('Egg');
    if (FFAppState().userPrefNonVeg) opts.add('NonVeg');
    return opts;
  }

  bool _passesDietFilter(MyMealsRecord m) {
    final wantVeg = FFAppState().userPrefVeg;
    final wantEgg = FFAppState().userPrefEgg;
    final wantNonVeg = FFAppState().userPrefNonVeg;

    if (!wantVeg && !wantEgg && !wantNonVeg) {
      return true; // Show if no user prefs
    }

    final docDiet = m.dietType;
    if (docDiet.isEmpty) return true;

    for (var d in docDiet) {
      if ((wantVeg && d == 'Veg') ||
          (wantEgg && d == 'Egg') ||
          (wantNonVeg && d == 'NonVeg')) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all dynamically created controllers and focus nodes
    for (var catKey in _textControllers.keys) {
      _textControllers[catKey]
          ?.forEach((_, controller) => controller.dispose());
    }
    for (var catKey in _focusNodes.keys) {
      _focusNodes[catKey]?.forEach((_, node) => node.dispose());
    }
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        title: Text(
          'Select Your Meals',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        elevation: 2.0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor:
              FlutterFlowTheme.of(context).secondaryText.withOpacity(0.7),
          indicatorColor: FlutterFlowTheme.of(context).secondary,
          tabs: _categories
              .map((catKey) => Tab(text: _categoryLabels[catKey] ?? catKey))
              .toList(),
        ),
      ),
      body: SafeArea(
        top: true, // Should be true if appBar is present
        child: StreamBuilder<List<MyMealsRecord>>(
          stream: queryMyMealsRecord(parent: currentUserReference),
          builder: (context, snapshot) {
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text("Error fetching meals: ${snapshot.error}"));
            }
            final allUserMeals = snapshot.data ?? [];
            final dietFilteredMeals =
                allUserMeals.where(_passesDietFilter).toList();

            final List<Widget> tabPages = _categories.map((categoryKey) {
              final List<MyMealsRecord> mealsForThisCategoryTab;
              if (categoryKey == 'LunchDinner') {
                mealsForThisCategoryTab = dietFilteredMeals.where((m) {
                  return m.category.contains('Lunch') ||
                      m.category.contains('Dinner');
                }).toList();
              } else {
                mealsForThisCategoryTab = dietFilteredMeals
                    .where((m) => m.category.contains(categoryKey))
                    .toList();
              }
              return _buildCategoryPage(categoryKey, mealsForThisCategoryTab);
            }).toList();

            return TabBarView(
              controller: _tabController,
              children: tabPages,
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0)
            .copyWith(
                bottom: MediaQuery.of(context).padding.bottom +
                    12.0), // Adjust for safe area
        child: Row(
          // Removed SafeArea here as padding is handled above
          children: [
            Expanded(
              child: FFButtonWidget(
                onPressed: () => Navigator.of(context).pop(),
                text: 'Back',
                options: FFButtonOptions(
                  height: 48.0,
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  textStyle: FlutterFlowTheme.of(context)
                      .titleSmall
                      .override(color: FlutterFlowTheme.of(context).primary),
                  borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).primary, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: FFButtonWidget(
                onPressed: () async {
                  final allSelectedMeals = await queryMyMealsRecordOnce(
                    parent: currentUserReference,
                    queryBuilder: (q) => q.where('isSelected', isEqualTo: true),
                  );
                  final selectedNames =
                      allSelectedMeals.map((rec) => rec.mealName).toList();

                  final existingList = (await querySelectedMealsListRecordOnce(
                    parent: currentUserReference,
                    singleRecord: true, // Assuming only one such list per user
                  ))
                      .firstOrNull;

                  if (existingList != null) {
                    await existingList.reference.update(
                      createSelectedMealsListRecordData(
                          mealsList: selectedNames),
                    );
                  } else {
                    final doc = SelectedMealsListRecord.createDoc(
                        currentUserReference!);
                    await doc.set(
                      createSelectedMealsListRecordData(
                          mealsList: selectedNames),
                    );
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selections Saved!')),
                    );
                  }
                },
                text: 'Save',
                options: FFButtonOptions(
                  height: 48.0,
                  color: FlutterFlowTheme.of(context).secondary,
                  textStyle: FlutterFlowTheme.of(context)
                      .titleSmall
                      .override(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: FFButtonWidget(
                onPressed: () async {
                  final allSelectedMeals = await queryMyMealsRecordOnce(
                    parent: currentUserReference,
                    queryBuilder: (q) => q.where('isSelected', isEqualTo: true),
                  );
                  final selectedNames =
                      allSelectedMeals.map((rec) => rec.mealName).toList();

                  final existingList = (await querySelectedMealsListRecordOnce(
                    parent: currentUserReference,
                    singleRecord: true,
                  ))
                      .firstOrNull;
                  if (existingList != null) {
                    await existingList.reference.update(
                      createSelectedMealsListRecordData(
                          mealsList: selectedNames),
                    );
                  } else {
                    final doc = SelectedMealsListRecord.createDoc(
                        currentUserReference!);
                    await doc.set(
                      createSelectedMealsListRecordData(
                          mealsList: selectedNames),
                    );
                  }
                  if (mounted) {
                    context.pushNamed(WeeklyPlannerPgWidget.routeName);
                  }
                },
                text: 'Next',
                options: FFButtonOptions(
                  height: 48.0,
                  color: FlutterFlowTheme.of(context)
                      .primary, // Changed color for distinction
                  textStyle: FlutterFlowTheme.of(context)
                      .titleSmall
                      .override(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPage(
    String categoryKey,
    List<MyMealsRecord>
        categoryMeals, // Meals already filtered for this tab's category & user's diet
  ) {
    final Map<String, List<MyMealsRecord>> mealsByFoodType = {};
    for (var m in categoryMeals) {
      if (m.foodType.isNotEmpty) {
        for (String ft in m.foodType) {
          // Meal can have multiple foodTypes as it's a list
          mealsByFoodType.putIfAbsent(ft, () => []).add(m);
        }
      } else {
        mealsByFoodType.putIfAbsent('Other', () => []).add(m);
      }
    }
    final List<String> sortedFoodTypes = mealsByFoodType.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Allow overscroll indication
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoryMeals.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No meals found for this category that match your diet preferences.",
                  textAlign: TextAlign.center,
                ),
              )),
            for (var ft in sortedFoodTypes) ...[
              Text(
                ft,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: GoogleFonts.inter(fontWeight: FontWeight.w600)
                          .fontFamily,
                    ),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ...(mealsByFoodType[ft]!
                        ..sort((a, b) {
                          if (a.isSelected && !b.isSelected) return -1;
                          if (!a.isSelected && b.isSelected) return 1;
                          return a.mealName
                              .toLowerCase()
                              .compareTo(b.mealName.toLowerCase());
                        }))
                      .map((m) => _buildMealPill(m)),
                  _buildAddNewPill(categoryKey, ft,
                      categoryMeals), // Pass categoryMeals for duplication check
                ],
              ),
              const SizedBox(height: 24.0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealPill(MyMealsRecord m) {
    final isSelected = m.isSelected;
    final isCreatedByUser = m.createdBy == 'user';

    return GestureDetector(
      onTap: () async {
        final newValue = !isSelected;
        await m.reference.update({'isSelected': newValue});
        // StreamBuilder will handle UI update
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).secondary
              : FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(20.0),
          border: isCreatedByUser
              ? Border.all(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 1.5) // User created border
              : null,
        ),
        child: Text(
          m.mealName,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : FlutterFlowTheme.of(context).primaryText),
        ),
      ),
    );
  }

  Widget _buildAddNewPill(String categoryKey, String foodType,
      List<MyMealsRecord> categoryMealsForDuplicationCheck) {
    if (!isAdding(categoryKey, foodType)) {
      return GestureDetector(
        onTap: () => setAdding(categoryKey, foodType, true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
      final controller = getTextController(categoryKey, foodType);
      final focusNode = getAddNewMealFocusNode(categoryKey, foodType);
      final dietOptions = _buildAllowedDietOptions();
      // Ensure current diet choice is valid or default
      String currentDietSelection = getDietChoice(categoryKey, foodType);
      if (!dietOptions.contains(currentDietSelection) &&
          dietOptions.isNotEmpty) {
        currentDietSelection = dietOptions.first;
        setDietChoice(
            categoryKey, foodType, currentDietSelection); // Update state
      }

      return Container(
        // Wrap in container for better layout control if needed
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Important for Wrap
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              // Allow TextField to take available space
              child: SizedBox(
                height: 48, // Consistent height
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'New meal name',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
            ),
            if (dietOptions.length > 1) ...[
              const SizedBox(width: 8.0),
              SizedBox(
                height: 48, // Consistent height
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
                        setDietChoice(categoryKey, foodType, val!),
                    alignment: AlignmentDirectional.centerStart,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8.0),
            InkWell(
              // Changed from GestureDetector for ink splash
              onTap: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;

                final duplicate = categoryMealsForDuplicationCheck.any(
                    (rec) => rec.mealName.toLowerCase() == text.toLowerCase());
                if (duplicate) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Item already exists in this category')),
                    );
                  }
                  return;
                }

                String chosenDietForNewMeal = (dietOptions.length == 1)
                    ? dietOptions.first
                    : getDietChoice(categoryKey, foodType);
                if (chosenDietForNewMeal.isEmpty && dietOptions.isNotEmpty) {
                  chosenDietForNewMeal = dietOptions
                      .first; // Default if not explicitly set but options exist
                }

                final newDocRef =
                    currentUserReference!.collection('myMeals').doc();
                await newDocRef.set(createMyMealsRecordData(
                  mealName: text,
                  createdBy: 'user',
                  tags: <String>[],
                  related: <String>[],
                  foodType: <String>[foodType],
                  dietType: chosenDietForNewMeal.isNotEmpty
                      ? <String>[chosenDietForNewMeal]
                      : <String>[],
                  category: (categoryKey == 'LunchDinner')
                      ? <String>['Lunch', 'Dinner']
                      : <String>[categoryKey],
                  isSelected: true,
                ));
                controller.clear();
                setAdding(
                    categoryKey, foodType, false); // This will trigger setState
              },
              child: Container(
                height: 48, // Consistent height
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
}
