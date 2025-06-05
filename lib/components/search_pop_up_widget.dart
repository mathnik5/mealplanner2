import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_button_tabbar.dart';
// import '/flutter_flow/flutter_flow_choice_chips.dart'; // Not used in current logic, can be re-added if needed
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
// import '/flutter_flow/form_field_controller.dart'; // Not used by ChoiceChips if removed
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'search_pop_up_model.dart';
export 'search_pop_up_model.dart';

class SearchPopUpWidget extends StatefulWidget {
  const SearchPopUpWidget({super.key});

  @override
  State<SearchPopUpWidget> createState() => _SearchPopUpWidgetState();
}

class _SearchPopUpWidgetState extends State<SearchPopUpWidget>
    with TickerProviderStateMixin {
  late SearchPopUpModel _model;

  // Map category→List of selected meal names for this popup session
  final Map<String, List<String>> _selectedByCategory = {
    'Breakfast': [],
    'Lunch': [],
    'Snacks': [],
    'Dinner': [],
  };

  // Category names in the same order as the tabs
  final List<String> _categories = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  final animationsMap = <String, AnimationInfo>{};

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

    _model.tabBarController = TabController(
      vsync: this,
      length: _categories.length,
      initialIndex: 0,
    )..addListener(() {
        setState(() {
          // _currentTabIndex is not explicitly used but good to keep if needed later
          // _currentTabIndex = _model.tabBarController?.index ?? 0;
        });
      });

    _model.textFieldBFTextController ??= TextEditingController();
    _model.textFieldBFFocusNode ??= FocusNode();

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

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  /// Helper function to determine if a meal passes the current diet preferences
  bool _passesDietFilter(MyMealsRecord meal) {
    final wantVeg = FFAppState().userPrefVeg;
    final wantEgg = FFAppState().userPrefEgg;
    final wantNonVeg = FFAppState().userPrefNonVeg;

    // If no preferences are set by the user, show all meals (or consider this case based on requirements)
    if (!wantVeg && !wantEgg && !wantNonVeg) {
      return true; // Or false, depending on desired behavior when no prefs are set
    }

    final mealDietTypes = meal.dietType; // This is List<String>

    // If the meal has no diet tags, show it (fail-safe or per requirement)
    if (mealDietTypes.isEmpty) {
      return true;
    }

    bool passes = false;
    if (wantVeg && mealDietTypes.contains('Veg')) passes = true;
    if (wantEgg && mealDietTypes.contains('Egg')) passes = true;
    if (wantNonVeg && mealDietTypes.contains('NonVeg')) passes = true;

    return passes;
  }

  /// Filters a list of meals based on category, diet preferences, and search text.
  List<MyMealsRecord> _getFilteredMealsForTab(
      List<MyMealsRecord> allMeals, String categoryName) {
    String searchText = _model.textController1.text.toLowerCase().trim();

    return allMeals.where((meal) {
      // Filter by category
      bool categoryMatch = false;
      if (categoryName == 'Lunch' || categoryName == 'Dinner') {
        // For a combined "Lunch/Dinner" tab, or if they are separate tabs:
        categoryMatch =
            meal.category.contains('Lunch') || meal.category.contains('Dinner');
      } else {
        categoryMatch = meal.category.contains(categoryName);
      }
      if (!categoryMatch) return false;

      // Filter by diet
      if (!_passesDietFilter(meal)) return false;

      // Filter by search text (if any)
      if (searchText.isNotEmpty) {
        if (!meal.mealName.toLowerCase().contains(searchText)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Builds a single tappable “pill” for a MyMealsRecord
  Widget _buildMealCard(MyMealsRecord mealRecord, String categoryKey) {
    final alreadyAdded =
        _selectedByCategory[categoryKey]!.contains(mealRecord.mealName);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5.0, 5.0, 5.0, 5.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          setState(() {
            if (alreadyAdded) {
              _selectedByCategory[categoryKey]!.remove(mealRecord.mealName);
            } else {
              _selectedByCategory[categoryKey]!.add(mealRecord.mealName);
            }
          });
        },
        child: Material(
          color: Colors.transparent,
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: alreadyAdded
                  ? const Color(0xFF4CEBD9) // Theme primary or accent
                  : const Color(0xFFE0E3E7), // Theme light grey
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Color(0x33000000),
                  offset: Offset(0.0, 2.0),
                )
              ],
              borderRadius: BorderRadius.circular(7.0),
              shape: BoxShape.rectangle,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  8.0, 4.0, 8.0, 4.0), // Adjusted padding
              child: Text(
                mealRecord.mealName,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .fontFamily, // Ensuring font family is applied
                      letterSpacing: 0.0,
                      color: alreadyAdded // Ensuring text color contrast
                          ? FlutterFlowTheme.of(context)
                              .primaryText // Or white if background is dark
                          : FlutterFlowTheme.of(context).primaryText,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the content for a generic meal tab.
  Widget _buildMealTab(List<MyMealsRecord> allUserMeals, String categoryName) {
    final filteredMeals = _getFilteredMealsForTab(allUserMeals, categoryName);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            height: 1.0,
            thickness: 1.0,
            color: FlutterFlowTheme.of(context).alternate,
          ),
          if (filteredMeals.isEmpty && _model.textController1.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                  child: Text(
                      'No meals found matching your search in "$categoryName".',
                      style: FlutterFlowTheme.of(context).bodyMedium)),
            )
          else if (filteredMeals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                  child: Text(
                'No meals available for "$categoryName" with current diet preferences.',
                style: FlutterFlowTheme.of(context).bodyMedium,
                textAlign: TextAlign.center,
              )),
            ),
          // Wrap of meal items
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5.0, 5.0, 0.0, 0.0),
            child: Wrap(
              spacing: 0.0,
              runSpacing: 0.0,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              direction: Axis.horizontal,
              runAlignment: WrapAlignment.start,
              verticalDirection: VerticalDirection.down,
              clipBehavior: Clip.none,
              children: List.generate(filteredMeals.length, (index) {
                return _buildMealCard(filteredMeals[index], categoryName);
              }),
            ),
          ),

          // "Add new Meal Item" text field + arrow
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 8.0), // Added padding around the Add New section
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        15.0, 10.0, 8.0, 10.0), // Adjusted padding
                    child: SizedBox(
                      // width: 200.0, // Width is managed by Expanded
                      child: TextFormField(
                        controller: categoryName == 'Breakfast'
                            ? _model
                                .textFieldBFTextController // Use specific controller for BF or a generic one
                            : TextEditingController(), // Temporary, manage controllers better if many tabs
                        focusNode: categoryName == 'Breakfast'
                            ? _model.textFieldBFFocusNode
                            : FocusNode(),
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontFamily,
                                    letterSpacing: 0.0,
                                  ),
                          hintText: 'Add new meal to $categoryName',
                          hintStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontFamily,
                                    letterSpacing: 0.0,
                                  ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF716666),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              // Use theme primary color for focused border
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontFamily,
                              letterSpacing: 0.0,
                            ),
                        cursorColor: FlutterFlowTheme.of(context).primaryText,
                        // validator: _model.textFieldBFTextControllerValidator.asValidator(context), // Add validator if needed
                      ),
                    ),
                  ),
                ),
                Padding(
                  // Consistent padding for the button
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
                  child: IconButton(
                    icon: Icon(
                      Icons
                          .add_circle_outline, // Changed to a more common add icon
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 30.0,
                    ),
                    onPressed: () async {
                      final newMealName = (categoryName == 'Breakfast'
                              ? _model.textFieldBFTextController.text
                              : (ModalRoute.of(context)?.settings.arguments
                                          as TextEditingController?)
                                      ?.text ??
                                  "" // This part needs robust controller handling if scaling
                          )
                          .trim();

                      if (newMealName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a meal name.'),
                            backgroundColor: FlutterFlowTheme.of(context).error,
                          ),
                        );
                        return;
                      }

                      // Determine dietType for the new meal based on FFAppState
                      List<String> newMealDietTypes = [];
                      if (FFAppState().userPrefVeg) newMealDietTypes.add('Veg');
                      if (FFAppState().userPrefEgg) newMealDietTypes.add('Egg');
                      if (FFAppState().userPrefNonVeg)
                        newMealDietTypes.add('NonVeg');

                      // FFAppState().addToSelectedMeals(newMealName); // This line seems to manage a different list. Review FFAppState().selectedMeals usage.

                      await MyMealsRecord.createDoc(currentUserReference!)
                          .set(createMyMealsRecordData(
                        mealName: newMealName,
                        category: [
                          categoryName
                        ], // Use the current tab's category
                        dietType: newMealDietTypes,
                        isSelected:
                            false, // Newly added items from popup are not "globally selected" by default
                        createdBy: 'user', // Mark as user-created
                        tags: [], // Default empty, can be expanded later
                        related: [], // Default empty
                      ));

                      // Clear the text field after adding
                      if (categoryName == 'Breakfast') {
                        _model.textFieldBFTextController?.clear();
                      } else {
                        // Clear other controllers if they are defined and used
                      }

                      // Optionally add to local selection for this popup session
                      setState(() {
                        _selectedByCategory[categoryName]!.add(newMealName);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$newMealName added to $categoryName and selected.'),
                          backgroundColor: FlutterFlowTheme.of(context).success,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>(); // Ensure FFAppState is available

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 4.0,
        ),
        child: StreamBuilder<List<MyMealsRecord>>(
          // Fetch ALL MyMealsRecord for the current user. Filtering will be done client-side.
          stream: queryMyMealsRecord(
            parent: currentUserReference,
            // No queryBuilder here means fetch all.
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error fetching meals: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Handle case where user has no meals at all.
              // You might want a different UI here, or let the tabs show "No meals available".
              // For now, we pass an empty list to the tabs.
            }

            final allUserMeals = snapshot.data ?? []; // Use empty list if null

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
                      decoration: const BoxDecoration(),
                      child: Padding(
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
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 2.0, 16.0, 8.0), // Added horizontal padding
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
                        padding: const EdgeInsets.all(4.0), // Reduced padding
                        child: SizedBox(
                          height: 60.0, // Reduced height
                          child: Center(
                            // Center the TextFormField
                            child: TextFormField(
                              controller: _model.textController1,
                              focusNode: _model.textFieldFocusNode,
                              autofocus: false, // Usually true for search
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Search meals...',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelLarge, // Adjusted style for better fit
                                enabledBorder: InputBorder.none, // Cleaner look
                                focusedBorder: InputBorder.none, // Cleaner look
                                prefixIcon: Icon(
                                  // Added search icon
                                  Icons.search,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 20, // Adjusted size
                                ),
                                contentPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        // Adjusted padding
                                        0.0,
                                        0.0,
                                        0.0,
                                        0.0),
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge, // Adjusted style
                              onChanged: (_) => setState(
                                  () {}), // Rebuild UI on search text change
                              validator: _model.textController1Validator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                        topLeft: Radius.circular(12.0), // Added top radius
                        topRight: Radius.circular(12.0), // Added top radius
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: const Alignment(0.0, 0),
                              child: FlutterFlowButtonTabBar(
                                useToggleButtonStyle:
                                    false, // Keep as true if you prefer toggle style
                                isScrollable: true,
                                labelStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontFamily),
                                unselectedLabelStyle:
                                    FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontFamily),
                                labelColor: FlutterFlowTheme.of(context)
                                    .primaryText, // Or .primary for selected
                                unselectedLabelColor:
                                    FlutterFlowTheme.of(context).secondaryText,
                                backgroundColor: // Transparent or subtle background
                                    FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                unselectedBackgroundColor:
                                    FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                borderColor: FlutterFlowTheme.of(context)
                                    .alternate, // Or primary for selected
                                unselectedBorderColor:
                                    FlutterFlowTheme.of(context).alternate,
                                borderWidth: 1.0, // Subtle border
                                borderRadius: 8.0, // Consistent rounding
                                elevation: 0.0,
                                labelPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                buttonMargin: // Added margin for spacing
                                    const EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 8.0),
                                tabs: _categories
                                    .map((c) => Tab(text: c))
                                    .toList(),
                                controller: _model.tabBarController,
                                onTap: (i) {
                                  setState(
                                      () {}); // Ensure UI rebuilds if tab changes affect filtered list
                                },
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _model.tabBarController,
                                children: _categories.map((categoryName) {
                                  return KeepAliveWidgetWrapper(
                                    // Keep state of tabs
                                    builder: (context) => _buildMealTab(
                                        allUserMeals, categoryName),
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
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // "Suggest a random meal" button - No changes needed here for data model
                        // FFButtonWidget(...),
                        // const SizedBox(height: 12.0),

                        Center(
                          child: Text(
                            'Selected Items for Planner', // Clarified title
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontFamily),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // Display selected items
                        ..._categories.map((cat) {
                          final items = _selectedByCategory[cat]!;
                          if (items.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0), // Reduced padding
                            child: Center(
                              // Center the text
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
                                                        .bodyMedium
                                                        .fontFamily,
                                                fontWeight: FontWeight.bold,
                                                color: FlutterFlowTheme.of(
                                                        context)
                                                    .primaryText // Ensure text color
                                                )),
                                    TextSpan(
                                      text: items.join(', '),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontFamily,
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .secondaryText // Ensure text color
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        if (_selectedByCategory.values
                            .every((list) => list.isEmpty))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No items selected yet.',
                              style: FlutterFlowTheme.of(context).bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 12.0),
                        FFButtonWidget(
                          onPressed: () {
                            final allSelectedNames = _categories
                                .expand((cat) => _selectedByCategory[cat]!)
                                .toSet() // Use toSet to avoid duplicates if a meal name could be in multiple selected lists
                                .toList();
                            Navigator.pop(context, allSelectedNames);
                          },
                          text: 'OK',
                          options: FFButtonOptions(
                            width: double.infinity, // Make button full width
                            height: 48.0, // Standard height
                            color: FlutterFlowTheme.of(context)
                                .primary, // Use theme primary color
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontFamily,
                                  color: Colors
                                      .white, // Ensure text is white on primary color
                                ),
                            elevation: 2.0, // Subtle elevation
                            borderRadius: BorderRadius.circular(
                                8.0), // Consistent rounding
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
