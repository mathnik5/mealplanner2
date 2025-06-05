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

/// Landing Page: Select Diet Preference
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

    // On page load, check if the user already has any MyMealsRecord.
    // If not, copy ALL of `meals3` directly into MyMealsRecord (array fields only).
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // 1) Fetch ONE MyMealsRecord for the current user (if any exist).
      _model.myMealsFetch = await queryMyMealsRecordOnce(
        parent: currentUserReference,
        singleRecord: true,
      ).then((list) => list.firstOrNull);

      // 2) If no MyMealsRecord exists yet, do the “full copy” of meals3 → MyMealsRecord.
      if (_model.myMealsFetch == null) {
        // Fetch the entire 'meals3' collection 
        final allMeals3Snapshot =
            await FirebaseFirestore.instance.collection('meals3').get();

        for (final doc in allMeals3Snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Extract each List<String> (or default to empty list if missing):
          final List<String> categoryList =
              (data['category'] as List<dynamic>? ?? []).cast<String>();
          final List<String> dietList =
              (data['dietType'] as List<dynamic>? ?? []).cast<String>();
          final List<String> tagsList =
              (data['tags'] as List<dynamic>? ?? []).cast<String>();
          final List<String> relatedList =
              (data['related'] as List<dynamic>? ?? []).cast<String>();
          final List<String> foodTypeList =
              (data['foodType'] as List<dynamic>? ?? []).cast<String>();

          // Now create a new MyMealsRecord under the current user.
          // We pass all fields 
          await MyMealsRecord.createDoc(currentUserReference!).set(
            createMyMealsRecordData(
              mealName: data['mealName'] as String? ?? '',
              createdBy: data['createdby'] as String? ?? '',
              tags: tagsList,
              related: relatedList,
              foodType: foodTypeList,
              dietType: dietList,
              isSelected: false,
            ),
          );
        }
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
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard on tap outside
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
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineLarge.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                ),
                color: Colors.white,
                letterSpacing: 0.0,
                fontWeight:
                    FlutterFlowTheme.of(context).headlineLarge.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                shadows: [
                  Shadow(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    offset: const Offset(1.0, 1.0),
                    blurRadius: 1.0,
                  )
                ],
              ),
            ),
          ),
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Veg Switch
                Divider(
                  thickness: 2.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile.adaptive(
                    value: _model.vegSwitchValue ??= FFAppState().userPrefVeg,
                    onChanged: (newValue) async {
                      safeSetState(() => _model.vegSwitchValue = newValue);
                      FFAppState().userPrefVeg = newValue;
                      safeSetState(() {});
                    },
                    title: Text(
                      'Veg',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                                fontSize: 30.0,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontStyle,
                              ),
                    ),
                    tileColor: FlutterFlowTheme.of(context).secondaryBackground,
                    activeColor: FlutterFlowTheme.of(context).alternate,
                    activeTrackColor: FlutterFlowTheme.of(context).primary,
                    dense: false,
                    controlAffinity: ListTileControlAffinity.trailing,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),

                // Egg Switch
                Divider(
                  thickness: 2.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile.adaptive(
                    value: _model.eggSwitchValue ??= FFAppState().userPrefEgg,
                    onChanged: (newValue) async {
                      safeSetState(() => _model.eggSwitchValue = newValue);
                      FFAppState().userPrefEgg = newValue;
                      safeSetState(() {});
                    },
                    title: Text(
                      'Egg',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                                fontSize: 30.0,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontStyle,
                              ),
                    ),
                    tileColor: FlutterFlowTheme.of(context).secondaryBackground,
                    activeColor: FlutterFlowTheme.of(context).alternate,
                    activeTrackColor: FlutterFlowTheme.of(context).primary,
                    dense: false,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                ),

                // Non‐Veg Switch
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
                      safeSetState(() => _model.nonVegSwitchValue = newValue);
                      FFAppState().userPrefNonVeg = newValue;
                      safeSetState(() {});
                    },
                    title: Text(
                      'Non-Veg',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                                fontSize: 30.0,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontStyle,
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

                // Continue Button (save preferences and navigate)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                  child: StreamBuilder<List<MyDietPrefRecord>>(
                    stream: queryMyDietPrefRecord(
                      parent: currentUserReference,
                      singleRecord: true,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        );
                      }
                      List<MyDietPrefRecord> buttonMyDietPrefRecordList =
                          snapshot.data!;
                      final buttonMyDietPrefRecord =
                          buttonMyDietPrefRecordList.isNotEmpty
                              ? buttonMyDietPrefRecordList.first
                              : null;

                      return FFButtonWidget(
                        onPressed: () async {
                          // 1) Write or update MyDietPrefRecord with the three toggles
                          if (buttonMyDietPrefRecord != null) {
                            await buttonMyDietPrefRecord.reference
                                .update(createMyDietPrefRecordData(
                              veg: _model.vegSwitchValue,
                              nonVeg: _model.nonVegSwitchValue,
                              egg: _model.eggSwitchValue,
                            ));
                          } else {
                            await MyDietPrefRecord.createDoc(
                                    currentUserReference!)
                                .set(createMyDietPrefRecordData(
                              veg: _model.vegSwitchValue,
                              nonVeg: _model.nonVegSwitchValue,
                              egg: _model.eggSwitchValue,
                            ));
                          }

                          FFAppState().userPrefVeg = _model.vegSwitchValue!;
                          FFAppState().userPrefNonVeg =
                              _model.nonVegSwitchValue!;
                          FFAppState().userPrefEgg = _model.eggSwitchValue!;

                          // 2) Ensure a SelectedMealsListRecord exists
                          _model.selectedMealsFetch =
                              await querySelectedMealsListRecordOnce(
                            parent: currentUserReference,
                            singleRecord: true,
                          ).then((s) => s.firstOrNull);
                          if (_model.selectedMealsFetch == null) {
                            await SelectedMealsListRecord.createDoc(
                                    currentUserReference!)
                                .set(createSelectedMealsListRecordData());
                          }

                          // 3) Navigate to MealSelectionPg
                          context.pushNamed(MealSelectionPgWidget.routeName);

                          safeSetState(() {});
                        },
                        text: 'Continue',
                        options: FFButtonOptions(
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
                              fontWeight: FlutterFlowTheme.of(context)
                                  .headlineLarge
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .headlineLarge
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .fontStyle,
                            shadows: [
                              Shadow(
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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
