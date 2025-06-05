import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'select_diet_pref_pg_model.dart';
export 'select_diet_pref_pg_model.dart';

class SelectDietPrefPgWidget extends StatefulWidget {
  const SelectDietPrefPgWidget({Key? key}) : super(key: key);

  static String routeName = 'selectDietPrefPg';
  static String routePath = '/selectDietPrefPg';

  @override
  State<SelectDietPrefPgWidget> createState() => _SelectDietPrefPgWidgetState();
}

class _SelectDietPrefPgWidgetState extends State<SelectDietPrefPgWidget> {
  late SelectDietPrefPgModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelectDietPrefPgModel());

    // Initialize switch values from FFAppState if not already set by the model
    // The model itself might initialize them from FFAppState, good to ensure consistency.
    _model.vegSwitchValue ??= FFAppState().userPrefVeg;
    _model.eggSwitchValue ??= FFAppState().userPrefEgg;
    _model.nonVegSwitchValue ??= FFAppState().userPrefNonVeg;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Check if the user already has any MyMealsRecord.
      // If not, copy ALL of `meals3` directly into MyMealsRecord.
      _model.myMealsFetch = await queryMyMealsRecordOnce(
        parent: currentUserReference,
        singleRecord: true, // We only need to know if at least one exists
      ).then((list) => list.firstOrNull);

      if (!mounted) return;

      if (_model.myMealsFetch == null) {
        // User has no meals, so populate from meals3 master list
        final allMeals3Snapshot =
            await FirebaseFirestore.instance.collection('meals3').get();

        if (!mounted) return;

        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (final doc in allMeals3Snapshot.docs) {
          final data = doc.data(); // Data is already Map<String, dynamic>

          final List<String> categoryList =
              List<String>.from(data['category'] as List<dynamic>? ?? []);
          final List<String> dietList =
              List<String>.from(data['dietType'] as List<dynamic>? ?? []);
          final List<String> tagsList =
              List<String>.from(data['tags'] as List<dynamic>? ?? []);
          final List<String> relatedList =
              List<String>.from(data['related'] as List<dynamic>? ?? []);
          final List<String> foodTypeList =
              List<String>.from(data['foodType'] as List<dynamic>? ?? []);

          // Create a new MyMealsRecord under the current user
          // Note: MyMealsRecord.createDoc is not standard FlutterFlow for subcollections.
          // We use parent.collection('myMeals').doc() directly.
          final newMealDocRef =
              currentUserReference!.collection('myMeals').doc();

          batch.set(
            newMealDocRef,
            createMyMealsRecordData(
              mealName: data['mealName'] as String? ?? '',
              createdBy: data['createdby'] as String? ??
                  'system', // Mark as system-copied initially
              tags: tagsList,
              related: relatedList,
              foodType: foodTypeList,
              dietType: dietList,
              category: categoryList, // ensure this is copied correctly
              isSelected: false, // Default to not selected
            ),
          );
        }
        await batch.commit();
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<
        FFAppState>(); // To react to FFAppState changes if any are made directly

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Text(
              'Select Your Preference',
              style: FlutterFlowTheme.of(context).headlineLarge.override(
                font: GoogleFonts.interTight(
                  // Using GoogleFonts directly for clarity
                  fontWeight: FontWeight.w600, // Example weight
                  fontStyle: FontStyle.normal, // Example style
                ),
                color: Colors.white,
                fontSize: 26, // Explicit font size
                letterSpacing: 0.0,
                shadows: [
                  Shadow(
                    color: FlutterFlowTheme.of(context)
                        .secondaryText
                        .withOpacity(0.5),
                    offset: const Offset(1.0, 1.0),
                    blurRadius: 1.0,
                  )
                ],
              ),
            ),
          ),
          centerTitle: true, // Changed to true for better centering
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Divider(
                  thickness: 2.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile.adaptive(
                    value: _model.vegSwitchValue ??= FFAppState()
                        .userPrefVeg, // Ensure model value is primary
                    onChanged: (newValue) async {
                      setState(() => _model.vegSwitchValue = newValue);
                      // No need to update FFAppState here, will do it on "Continue"
                    },
                    title: Text(
                      'Veg',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600),
                                fontSize: 30.0,
                                letterSpacing: 0.0,
                              ),
                    ),
                    tileColor: FlutterFlowTheme.of(context).secondaryBackground,
                    activeColor: FlutterFlowTheme.of(context)
                        .alternate, // This is the switch color when "on"
                    activeTrackColor: FlutterFlowTheme.of(context).primary,
                    dense: false,
                    controlAffinity: ListTileControlAffinity.trailing,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
                Divider(
                  thickness: 2.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile.adaptive(
                    value: _model.eggSwitchValue ??= FFAppState().userPrefEgg,
                    onChanged: (newValue) async {
                      setState(() => _model.eggSwitchValue = newValue);
                    },
                    title: Text(
                      'Egg',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600),
                                fontSize: 30.0,
                                letterSpacing: 0.0,
                              ),
                    ),
                    tileColor: FlutterFlowTheme.of(context).secondaryBackground,
                    activeColor: FlutterFlowTheme.of(context).alternate,
                    activeTrackColor: FlutterFlowTheme.of(context).primary,
                    dense: false,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                ),
                Divider(
                  thickness: 2.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile.adaptive(
                    value: _model.nonVegSwitchValue ??=
                        FFAppState().userPrefNonVeg,
                    onChanged: (newValue) async {
                      setState(() => _model.nonVegSwitchValue = newValue);
                    },
                    title: Text(
                      'Non-Veg',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w600),
                                fontSize: 30.0,
                                letterSpacing: 0.0,
                              ),
                    ),
                    tileColor: FlutterFlowTheme.of(context).secondaryBackground,
                    activeColor: FlutterFlowTheme.of(context).alternate,
                    activeTrackColor: FlutterFlowTheme.of(context).primary,
                    dense: false,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                ),
                Divider(
                  thickness: 2.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                  child: StreamBuilder<List<MyDietPrefRecord>>(
                    stream: queryMyDietPrefRecord(
                      parent: currentUserReference,
                      singleRecord: true,
                    ),
                    builder: (context, snapshot) {
                      // This stream is mainly to check if a record exists for update vs create
                      // The actual values for saving come from _model.xxxSwitchValue
                      final buttonMyDietPrefRecord = snapshot.data?.firstOrNull;

                      return FFButtonWidget(
                        onPressed: () async {
                          // NEW: Validation - at least one preference must be selected
                          final bool isVegSelected =
                              _model.vegSwitchValue ?? false;
                          final bool isEggSelected =
                              _model.eggSwitchValue ?? false;
                          final bool isNonVegSelected =
                              _model.nonVegSwitchValue ?? false;

                          if (!isVegSelected &&
                              !isEggSelected &&
                              !isNonVegSelected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select at least one diet preference to continue.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return; // Stop processing
                          }

                          // Update FFAppState with the current model values
                          FFAppState().userPrefVeg = isVegSelected;
                          FFAppState().userPrefEgg = isEggSelected;
                          FFAppState().userPrefNonVeg = isNonVegSelected;

                          // Save/Update MyDietPrefRecord in Firestore
                          if (buttonMyDietPrefRecord != null) {
                            await buttonMyDietPrefRecord.reference
                                .update(createMyDietPrefRecordData(
                              veg: isVegSelected,
                              nonVeg: isNonVegSelected,
                              egg: isEggSelected,
                            ));
                          } else {
                            // MyDietPrefRecord.createDoc is not standard FlutterFlow for subcollections.
                            // Use parent.collection('myDietPref').doc()
                            await currentUserReference!
                                .collection('myDietPref')
                                .doc()
                                .set(createMyDietPrefRecordData(
                                  veg: isVegSelected,
                                  nonVeg: isNonVegSelected,
                                  egg: isEggSelected,
                                ));
                          }

                          // Ensure a SelectedMealsListRecord exists
                          _model.selectedMealsFetch =
                              await querySelectedMealsListRecordOnce(
                            parent: currentUserReference,
                            singleRecord: true,
                          ).then((s) => s.firstOrNull);

                          if (_model.selectedMealsFetch == null) {
                            // SelectedMealsListRecord.createDoc is not standard.
                            // Use parent.collection(...).doc()
                            await currentUserReference!
                                .collection('selectedMealsList')
                                .doc()
                                .set(createSelectedMealsListRecordData(
                                    mealsList: [])); // Initialize with empty list
                          }

                          // NEW: Set the initial setup completion flag
                          FFAppState().hasCompletedInitialSetup = true;

                          if (context.mounted) {
                            context.pushNamed(MealSelectionPgWidget.routeName);
                          }

                          // setState is called by FFAppState if it notifies listeners,
                          // or by createModel if it updates. If not, and UI depends on local model state
                          // that isn't driven by FFAppState for this view, you might need it.
                          // For this page, direct navigation happens, so immediate rebuild might not be critical.
                          // safeSetState(() {}); // Usually not needed if FFAppState handles UI updates or navigation occurs
                        },
                        text: 'Continue',
                        options: FFButtonOptions(
                          width:
                              200, // Added a fixed width for better appearance
                          height: 58.9,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
                            font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w600),
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            fontSize: 22, // Adjusted font size for button
                            letterSpacing: 0.0,
                            shadows: [
                              Shadow(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText
                                    .withOpacity(0.5),
                                offset: const Offset(1.0, 1.0),
                                blurRadius: 1.0,
                              )
                            ],
                          ),
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
