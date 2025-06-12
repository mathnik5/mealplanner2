import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:meal_planner/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart' hide WeeklyPlannerPgWidget;
import '/index.dart';

// We no longer need the separate model file for this widget.
// import 'meal_selection_pg_model.dart';
// export 'meal_selection_pg_model.dart';

class MealSelectionPgWidget extends StatefulWidget {
  const MealSelectionPgWidget({super.key});

  static String routeName = 'mealSelectionPg';
  static String routePath = '/mealSelectionPg';

  @override
  _MealSelectionPgWidgetState createState() => _MealSelectionPgWidgetState();
}

class _MealSelectionPgWidgetState extends State<MealSelectionPgWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // The fixed order for displaying food type categories.
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

  final List<String> _categories = ['Breakfast', 'LunchDinner', 'Snacks'];
  final Map<String, String> _categoryLabels = {
    'Breakfast': 'Breakfast',
    'LunchDinner': 'Lunch & Dinner',
    'Snacks': 'Snacks'
  };

  // State variables for managing dynamic "Add New" inputs.
  final Map<String, Map<String, bool>> _isAdding = {};
  final Map<String, Map<String, TextEditingController>> _textControllers = {};
  final Map<String, Map<String, FocusNode>> _focusNodes = {};
  final Map<String, Map<String, String>> _dietChoices = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    for (var categoryKey in _categories) {
      _ensureCategoryInitialized(categoryKey);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var catKey in _textControllers.keys) {
      _textControllers[catKey]
          ?.forEach((_, controller) => controller.dispose());
    }
    for (var catKey in _focusNodes.keys) {
      _focusNodes[catKey]?.forEach((_, node) => node.dispose());
    }
    super.dispose();
  }

  // --- Helper methods for managing dynamic state ---

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

    if (!wantVeg && !wantEgg && !wantNonVeg) return true;

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
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        title: Text('Select Your Usual Meals',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.w600)),
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
        top: true,
        child: StreamBuilder<List<MyMealsRecord>>(
          stream: queryMyMealsRecord(parent: currentUserReference),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary)));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text("Error fetching meals: ${snapshot.error}"));
            }

            final allUserMeals = snapshot.data ?? [];
            if (allUserMeals.isEmpty) {
              return const Center(
                  child: Text("Your meal collection is empty."));
            }

            final dietFilteredMeals =
                allUserMeals.where((meal) => _passesDietFilter(meal)).toList();

            final List<Widget> tabPages = _categories.map((categoryKey) {
              final List<MyMealsRecord> mealsForThisCategoryTab;
              if (categoryKey == 'LunchDinner') {
                mealsForThisCategoryTab = dietFilteredMeals
                    .where((m) =>
                        m.category.contains('Lunch') ||
                        m.category.contains('Dinner'))
                    .toList();
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
            .copyWith(bottom: MediaQuery.of(context).padding.bottom + 12.0),
        child: Row(
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
                  if (mounted) {
                    context.pushNamed(WeeklyPlannerPgWidget.routeName);
                  }
                },
                text: 'Next',
                options: FFButtonOptions(
                    height: 48.0,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context)
                        .titleSmall
                        .override(color: Colors.white),
                    borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPage(
      String categoryKey, List<MyMealsRecord> categoryMeals) {
    final Map<String, List<MyMealsRecord>> mealsByFoodType = {};
    for (var m in categoryMeals) {
      (m.foodType.isNotEmpty ? m.foodType : ['Other']).forEach((ft) {
        mealsByFoodType.putIfAbsent(ft, () => []).add(m);
      });
    }

    List<Widget> foodTypeSections = [];
    for (String foodTypeName in _foodTypeOrder) {
      if (mealsByFoodType.containsKey(foodTypeName)) {
        foodTypeSections.add(_buildFoodTypeSection(foodTypeName,
            mealsByFoodType[foodTypeName]!, categoryKey, categoryMeals));
        mealsByFoodType.remove(foodTypeName);
      }
    }
    for (String foodTypeName in mealsByFoodType.keys) {
      foodTypeSections.add(_buildFoodTypeSection(foodTypeName,
          mealsByFoodType[foodTypeName]!, categoryKey, categoryMeals));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: foodTypeSections.isNotEmpty
            ? foodTypeSections
            : [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                        "No meals found for this category that match your diet preferences.",
                        textAlign: TextAlign.center),
                  ),
                )
              ],
      ),
    );
  }

  Widget _buildFoodTypeSection(
      String foodTypeName,
      List<MyMealsRecord> meals,
      String categoryKey,
      List<MyMealsRecord> categoryMealsForDuplicationCheck) {
    meals.sort((a, b) {
      return a.mealName.toLowerCase().compareTo(b.mealName.toLowerCase());
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(foodTypeName,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily:
                    GoogleFonts.inter(fontWeight: FontWeight.w600).fontFamily)),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ...meals.map((m) => _buildMealPill(m)),
            _buildAddNewPill(
                categoryKey, foodTypeName, categoryMealsForDuplicationCheck),
          ],
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildMealPill(MyMealsRecord m) {
    final isSelected = m.isSelected;
    final isCreatedByUser = m.createdBy == 'user';

    return GestureDetector(
      onTap: () async {
        final newValue = !isSelected;
        await m.reference.update({'isSelected': newValue});
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
                  color: FlutterFlowTheme.of(context).primary, width: 1.5)
              : null,
        ),
        child: Text(
          m.mealName,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
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
      final controller = getTextController(categoryKey, foodType);
      final focusNode = getAddNewMealFocusNode(categoryKey, foodType);
      final dietOptions = _buildAllowedDietOptions();

      String currentDietSelection = getDietChoice(categoryKey, foodType);
      if (!dietOptions.contains(currentDietSelection) &&
          dietOptions.isNotEmpty) {
        currentDietSelection = dietOptions.first;
        setDietChoice(categoryKey, foodType, currentDietSelection);
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
                textAlignVertical:
                    TextAlignVertical.center, // Center text vertically
                decoration: InputDecoration(
                  hintText: 'New meal name',
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
            ),
            if (dietOptions.length > 1) ...[
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate, width: 2),
                ),
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
              onTap: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                final duplicate = categoryMealsForDuplicationCheck.any(
                    (rec) => rec.mealName.toLowerCase() == text.toLowerCase());
                if (duplicate) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Item already exists in this category')));
                  }
                  return;
                }
                String chosenDietForNewMeal = (dietOptions.length == 1)
                    ? dietOptions.first
                    : getDietChoice(categoryKey, foodType);
                if (chosenDietForNewMeal.isEmpty && dietOptions.isNotEmpty) {
                  chosenDietForNewMeal = dietOptions.first;
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
                setAdding(categoryKey, foodType, false);
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(8.0)),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }
}
