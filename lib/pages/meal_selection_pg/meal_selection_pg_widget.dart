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
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'meal_selection_pg_model.dart';

export 'meal_selection_pg_model.dart';

class MealSelectionPgWidget extends StatefulWidget {
  MealSelectionPgWidget({super.key});

  static String routeName = 'mealSelectionPg';
  static String routePath = '/mealSelectionPg';

  // Mutable maps for tracking state
  final Map<String, Map<String, bool>> _isAdding = {};
  final Map<String, Map<String, TextEditingController>> _textControllers = {};
  final Map<String, Map<String, String>> _dietChoices = {};

  @override
  _MealSelectionPgWidgetState createState() => _MealSelectionPgWidgetState();
}

class _MealSelectionPgWidgetState extends State<MealSelectionPgWidget>
    with TickerProviderStateMixin {
  late MealSelectionPgModel _model;
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Categories we will use
  final List<String> _categories = ['Breakfast', 'LunchDinner', 'Snacks'];

  // Map each internal key to a display label:
  final Map<String, String> _categoryLabels = {
    'Breakfast': 'Breakfast',
    'LunchDinner': 'Lunch & Dinner',
    'Snacks': 'Snacks',
  };

  @override
  void initState() {
    super.initState();
    // Initialize the model (assuming FlutterFlow pattern)
    _model = createModel(context, () => MealSelectionPgModel());
    // Initialize TabController
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );
  }

  void _ensureCategoryInitialized(String categoryKey) {
    if (!widget._isAdding.containsKey(categoryKey)) {
      widget._isAdding[categoryKey] = {};
    }
    if (!widget._textControllers.containsKey(categoryKey)) {
      widget._textControllers[categoryKey] = {};
    }
    if (!widget._dietChoices.containsKey(categoryKey)) {
      widget._dietChoices[categoryKey] = {};
    }
  }

  void _ensureFoodTypeInitialized(String categoryKey, String foodType) {
    _ensureCategoryInitialized(categoryKey);
    widget._isAdding[categoryKey]!.putIfAbsent(foodType, () => false);
    widget._textControllers[categoryKey]!.putIfAbsent(
      foodType,
      () => TextEditingController(),
    );
    widget._dietChoices[categoryKey]!.putIfAbsent(foodType, () => '');
  }

  void initAddState(String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
  }

  bool isAdding(String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    return widget._isAdding[categoryKey]![foodType]!;
  }

  void setAdding(String categoryKey, String foodType, bool value) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    widget._isAdding[categoryKey]![foodType] = value;
  }

  void initTextController(String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
  }

  TextEditingController? getTextController(
      String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    return widget._textControllers[categoryKey]![foodType];
  }

  void disposeTextControllers() {
    for (var catEntry in widget._textControllers.entries) {
      for (var ctrl in catEntry.value.values) {
        ctrl.dispose();
      }
    }
  }

  void initDietChoice(String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    // Optionally set a default here, e.g.:
    // widget._dietChoices[categoryKey]![foodType] = 'Veg';
  }

  String getDietChoice(String categoryKey, String foodType) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    return widget._dietChoices[categoryKey]![foodType]!;
  }

  void setDietChoice(String categoryKey, String foodType, String value) {
    _ensureFoodTypeInitialized(categoryKey, foodType);
    widget._dietChoices[categoryKey]![foodType] = value;
  }

  /// Given a MyMealsRecord and the user's FFAppState diet prefs, returns whether
  /// this meal should be shown at all. We include items whose `dietType` is empty
  /// (fail‐safe) or whose array contains any of the user’s allowed diet values.
  bool _passesDietFilter(MyMealsRecord m) {
    final wantVeg = FFAppState().userPrefVeg;
    final wantEgg = FFAppState().userPrefEgg;
    final wantNonVeg = FFAppState().userPrefNonVeg;

    // Build a list of allowed diet strings:
    final allowed = <String>[];
    if (wantVeg) allowed.add('Veg');
    if (wantEgg) allowed.add('Egg');
    if (wantNonVeg) allowed.add('NonVeg');

    final docDiet = m.dietType; // array of strings
    if (docDiet.isEmpty) {
      // Fail‐safe: show any meal without a dietType tagging
      return true;
    }
    // If any item in docDiet intersects allowed, show it
    for (var d in docDiet) {
      if (allowed.contains(d)) return true;
    }
    return false;
  }

  @override
  void dispose() {
    disposeTextControllers();
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,

      // ───────────── AppBar ─────────────
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        title: Text(
          'Select Your Meals',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily:
                    FlutterFlowTheme.of(context).headlineMedium.fontFamily,
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        elevation: 2.0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
          indicatorColor: FlutterFlowTheme.of(context).secondary,
          tabs: _categories
              .map((catKey) => Tab(text: _categoryLabels[catKey] ?? catKey))
              .toList(),
        ),
      ),

      // ───────────── Body: TabBarView with 3 category‐pages ─────────────
      body: SafeArea(
        top: true,
        child: StreamBuilder<List<MyMealsRecord>>(
          // Stream _all_ of the user’s MyMealsRecord subcollection
          stream: queryMyMealsRecord(
            parent: currentUserReference,
            // We’re not filtering by diet in Firestore query because Firestore
            // has no simple “array‐isEmpty OR array‐containsAny” predicate.
            // Instead, we filter client‐side in _passesDietFilter().
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final allMeals = snapshot.data!;

            // 1) FILTER BY DIET at the very first step:
            final dietFilteredMeals =
                allMeals.where((m) => _passesDietFilter(m)).toList();

            // 2) GROUP INTO 3 BUCKETS (Breakfast, Lunch/Dinner, Snacks)
            final breakfastMeals = dietFilteredMeals
                .where((m) => m.category.contains('Breakfast'))
                .toList();
            final lunchDinnerMeals = dietFilteredMeals.where((m) {
              return m.category.contains('Lunch') ||
                  m.category.contains('Dinner');
            }).toList();
            final snacksMeals = dietFilteredMeals
                .where((m) => m.category.contains('Snacks'))
                .toList();

            // 3) Build the list of three tab‐pages:
            final List<Widget> tabPages = [
              _buildCategoryPage('Breakfast', breakfastMeals),
              _buildCategoryPage('LunchDinner', lunchDinnerMeals),
              _buildCategoryPage('Snacks', snacksMeals),
            ];

            return TabBarView(
              controller: _tabController,
              children: tabPages,
            );
          },
        ),
      ),

      // ───────────── Sticky Bottom Bar: Back | Save | Next ─────────────
      bottomNavigationBar: Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: FFButtonWidget(
                  onPressed: () {
                    Navigator.of(context).pop(); // Back
                  },
                  text: 'Back',
                  options: FFButtonOptions(
                    height: 48.0,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    textStyle: FlutterFlowTheme.of(context)
                        .titleSmall
                        .override(color: FlutterFlowTheme.of(context).primary),
                    borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 1.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: FFButtonWidget(
                  onPressed: () async {
                    // Save: gather selected meals and write SelectedMealsListRecord
                    final allSelectedMeals = await queryMyMealsRecordOnce(
                      parent: currentUserReference,
                      queryBuilder: (q) =>
                          q.where('isSelected', isEqualTo: true),
                    );
                    final selected =
                        allSelectedMeals.map((rec) => rec.mealName).toList();

                    // Overwrite or create a single SelectedMealsListRecord under the user
                    final existing = (await querySelectedMealsListRecordOnce(
                      parent: currentUserReference,
                      singleRecord: true,
                      queryBuilder: (q) =>
                          q.where('userRef', isEqualTo: currentUserReference),
                    ))
                        .firstOrNull;

                    if (existing != null) {
                      await existing.reference.update(
                        createSelectedMealsListRecordData(
                          mealsList: await selected,
                        ),
                      );
                    } else {
                      final doc = SelectedMealsListRecord.createDoc(
                          currentUserReference!);
                      await doc.set(
                        createSelectedMealsListRecordData(
                          mealsList: await selected,
                        ),
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved selections')),
                    );
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
                    // Fetch ONE‐TIME list of selected meals:
                    final allSelectedMeals = await queryMyMealsRecordOnce(
                      parent: currentUserReference,
                      queryBuilder: (q) =>
                          q.where('isSelected', isEqualTo: true),
                    );
                    final selected =
                        allSelectedMeals.map((rec) => rec.mealName).toList();

                    // Now you can use `selected` (which is List<String>) in your create/update logic:
                    final existing = (await querySelectedMealsListRecordOnce(
                      parent: currentUserReference,
                      singleRecord: true,
                      queryBuilder: (q) =>
                          q.where('userRef', isEqualTo: currentUserReference),
                    ))
                        .firstOrNull;

                    if (existing != null) {
                      await existing.reference.update(
                        createSelectedMealsListRecordData(
                          mealsList: selected,
                        ),
                      );
                    } else {
                      final doc = SelectedMealsListRecord.createDoc(
                          currentUserReference!);
                      await doc.set(
                        createSelectedMealsListRecordData(
                          mealsList: selected,
                        ),
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved selections')),
                    );
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
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single category page (Breakfast, LunchDinner, or Snacks).
  /// [categoryKey] is one of "Breakfast", "LunchDinner", "Snacks".
  /// [meals] is the list of MyMealsRecord already filtered by diet.
  Widget _buildCategoryPage(
    String categoryKey,
    List<MyMealsRecord> meals,
  ) {
    // 1) Filter only those meals that belong to this category:
    final List<MyMealsRecord> categoryMeals;
    if (categoryKey == 'LunchDinner') {
      categoryMeals = meals.where((m) {
        return m.category.contains('Lunch') || m.category.contains('Dinner');
      }).toList();
    } else {
      categoryMeals =
          meals.where((m) => m.category.contains(categoryKey)).toList();
    }

    // 2) Group by distinct foodType values:
    final Map<String, List<MyMealsRecord>> mealsByFoodType = {};
    for (var m in categoryMeals) {
      for (var ft in m.foodType) {
        mealsByFoodType.putIfAbsent(ft, () => []).add(m);
      }
      // If a meal has empty foodType, group under "Other"
      if (m.foodType.isEmpty) {
        mealsByFoodType.putIfAbsent('Other', () => []).add(m);
      }
    }

    // Sort the foodType keys (alphabetically):
    final List<String> sortedFoodTypes = mealsByFoodType.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // For each foodType subheading:
            for (var ft in sortedFoodTypes) ...[
              Text(
                ft,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.inter(
                        fontWeight: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .fontWeight,
                      ),
                    ),
              ),
              const SizedBox(height: 8.0),

              // Wrap of pills for this foodType, sorted selected-first:
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  // 2a) Meals themselves:
                  for (var m in mealsByFoodType[ft]!
                    ..sort((a, b) {
                      // Selected meals first, then alphabetical
                      if (a.isSelected && !b.isSelected) return -1;
                      if (!a.isSelected && b.isSelected) return 1;
                      return a.mealName.compareTo(b.mealName);
                    }))
                    _buildMealPill(m),

                  // 2b) A “+” icon button at the end to add new meal under [ft]
                  _buildAddNewPill(categoryKey, ft),
                ],
              ),
              const SizedBox(height: 24.0),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a single “pill” for a meal. Tapping toggles isSelected in Firestore.
  Widget _buildMealPill(MyMealsRecord m) {
    final isSelected = m.isSelected;
    final isCreatedByUser = m.createdBy == 'user';

    return GestureDetector(
      onTap: () async {
        final newValue = !isSelected;
        // Immediately write to Firestore
        await m.reference.update({'isSelected': newValue});
        // No need to setState; the stream will rebuild automatically
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CEBD9) : const Color(0xFFE0E3E7),
          borderRadius: BorderRadius.circular(20.0),
          border: isCreatedByUser
              ? Border.all(color: Colors.blueAccent, width: 2.0)
              : null,
        ),
        child: Text(
          m.mealName,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMedium.fontFamily,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  /// Builds the “+” button for adding a new meal under [categoryKey] and [foodType].
  /// When tapped, it flips isAdding[categoryKey][foodType] to true and shows an inline input.
  Widget _buildAddNewPill(String categoryKey, String foodType) {
    // Track whether we are currently adding under this subheading:
    initAddState(categoryKey, foodType);
    final adding = isAdding(categoryKey, foodType);

    if (!adding) {
      // Show simple "+" icon
      return GestureDetector(
        onTap: () {
          setState(() {
            setAdding(categoryKey, foodType, true);
            initTextController(categoryKey, foodType);
            initDietChoice(categoryKey, foodType);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: FlutterFlowTheme.of(context).primary),
          ),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      );
    } else {
      // Show inline “TextField + optional Dropdown + arrow”
      final controller = getTextController(categoryKey, foodType)!;
      final focusNode = FocusNode();
      final dietOptions = _buildAllowedDietOptions();

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1) TextField for mealName
          SizedBox(
            width: 140.0,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'New meal',
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8.0),

          // 2) Diet Dropdown (only if user has >1 preference)
          if (dietOptions.length > 1) ...[
            DropdownButton<String>(
              value: getDietChoice(categoryKey, foodType),
              items: dietOptions
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  setDietChoice(categoryKey, foodType, val!);
                });
              },
            ),
            const SizedBox(width: 8.0),
          ],

          // 3) Arrow button to confirm
          GestureDetector(
            onTap: () async {
              final text = controller.text.trim();
              if (text.isEmpty) {
                // Ignore empty input
                return;
              }

              // Check duplication _within this category_ (regardless of foodType)
              final categoryMealsSnapshot = await queryMyMealsRecordOnce(
                parent: currentUserReference,
                queryBuilder: (q) => q.where(
                  'category',
                  arrayContains:
                      categoryKey == 'LunchDinner' ? 'Lunch' : categoryKey,
                ),
              );

              final duplicate = categoryMealsSnapshot.any(
                (rec) => rec.mealName.toLowerCase() == text.toLowerCase(),
              );
              if (duplicate) {
                // Show snackbar and bail
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item already exists in this category'),
                  ),
                );
                return;
              }

              // Build the new MyMealsRecord data
              final chosenDiet = dietOptions.isNotEmpty
                  ? getDietChoice(categoryKey, foodType)
                  : null;
              final dietList =
                  chosenDiet != null ? <String>[chosenDiet] : <String>[];
              final categoryList = (categoryKey == 'LunchDinner')
                  ? <String>['Lunch', 'Dinner']
                  : <String>[categoryKey];

              // Write new document:
              final newDocRef = MyMealsRecord.createDoc(currentUserReference!);
              await newDocRef.set(createMyMealsRecordData(
                mealName: text,
                createdBy: 'user',
                tags: <String>[],
                related: <String>[],
                foodType: <String>[foodType],
                dietType: dietList,
                category: categoryList,
                isSelected: true,
              ));

              // Close the input row and reset
              setState(() {
                setAdding(categoryKey, foodType, false);
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      );
    }
  }

  /// Returns a list of diet strings allowed by the user’s FFAppState preferences.
  /// E.g. ["Veg", "Egg"] if userPrefVeg & userPrefEgg are true; otherwise smaller.
  /// If none of the three prefs are true, returns the empty list.
  List<String> _buildAllowedDietOptions() {
    final opts = <String>[];
    if (FFAppState().userPrefVeg) opts.add('Veg');
    if (FFAppState().userPrefEgg) opts.add('Egg');
    if (FFAppState().userPrefNonVeg) opts.add('NonVeg');
    return opts;
  }
}
