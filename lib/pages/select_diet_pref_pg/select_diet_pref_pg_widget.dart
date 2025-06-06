// lib/pages/select_diet_pref_pg/select_diet_pref_pg_widget.dart
import 'package:firebase_auth/firebase_auth.dart';

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
  const SelectDietPrefPgWidget({super.key});

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

    _model.vegSwitchValue ??= FFAppState().userPrefVeg;
    _model.eggSwitchValue ??= FFAppState().userPrefEgg;
    _model.nonVegSwitchValue ??= FFAppState().userPrefNonVeg;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.myMealsFetch = await queryMyMealsRecordOnce(
        parent: currentUserReference,
        singleRecord: true,
      ).then((list) => list.firstOrNull);

      if (!mounted) return;

      if (_model.myMealsFetch == null) {
        try {
          final allMeals3Snapshot =
              await FirebaseFirestore.instance.collection('meals3').get();

          if (!mounted) return;

          // Helper function to safely convert a field to a List<String>
          List<String> _safelyCastToList(dynamic fieldData) {
            if (fieldData == null) return [];
            if (fieldData is List) {
              return List<String>.from(
                  fieldData.map((item) => item.toString()));
            }
            if (fieldData is String) {
              return [
                fieldData
              ]; // The CORE of the fix: wrap a String in a List
            }
            return [];
          }

          WriteBatch batch = FirebaseFirestore.instance.batch();

          for (final doc in allMeals3Snapshot.docs) {
            final data = doc.data();

            // Use the new safe casting function for all list fields
            final List<String> categoryList =
                _safelyCastToList(data['category']);
            final List<String> dietList = _safelyCastToList(data['dietType']);
            final List<String> tagsList = _safelyCastToList(data['tags']);
            final List<String> relatedList = _safelyCastToList(data['related']);
            final List<String> foodTypeList =
                _safelyCastToList(data['foodType']);

            final newMealDocRef =
                currentUserReference!.collection('myMeals').doc();

            batch.set(
              newMealDocRef,
              createMyMealsRecordData(
                mealName: data['mealName'] as String? ?? '',
                createdBy: data['createdby'] as String? ?? 'system',
                tags: tagsList,
                related: relatedList,
                foodType: foodTypeList,
                dietType: dietList,
                category: categoryList,
                isSelected: false,
              ),
            );
          }
          await batch.commit();
        } catch (e, s) {
          print("Error during initial meal copy: $e");
          print("Stack Trace: $s");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error setting up account: $e')),
            );
          }
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
                    fontFamily: 'Inter Tight',
                    color: Colors.white,
                    fontSize: 26,
                  ),
            ),
          ),
          centerTitle: true,
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
                    value: _model.vegSwitchValue ??= FFAppState().userPrefVeg,
                    onChanged: (newValue) async {
                      setState(() => _model.vegSwitchValue = newValue);
                    },
                    title: Text(
                      'Veg',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Inter Tight',
                                fontSize: 30.0,
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
                                fontFamily: 'Inter Tight',
                                fontSize: 30.0,
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
                                fontFamily: 'Inter Tight',
                                fontSize: 30.0,
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
                      final buttonMyDietPrefRecord = snapshot.data?.firstOrNull;

                      return FFButtonWidget(
                        onPressed: () async {
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
                            return;
                          }

                          FFAppState().userPrefVeg = isVegSelected;
                          FFAppState().userPrefEgg = isEggSelected;
                          FFAppState().userPrefNonVeg = isNonVegSelected;

                          if (buttonMyDietPrefRecord != null) {
                            await buttonMyDietPrefRecord.reference
                                .update(createMyDietPrefRecordData(
                              veg: isVegSelected,
                              nonVeg: isNonVegSelected,
                              egg: isEggSelected,
                            ));
                          } else {
                            await MyDietPrefRecord.createDoc(
                                    currentUserReference!)
                                .set(createMyDietPrefRecordData(
                              veg: isVegSelected,
                              nonVeg: isNonVegSelected,
                              egg: isEggSelected,
                            ));
                          }

                          _model.selectedMealsFetch =
                              await querySelectedMealsListRecordOnce(
                            parent: currentUserReference,
                            singleRecord: true,
                          ).then((s) => s.firstOrNull);

                          if (_model.selectedMealsFetch == null) {
                            await SelectedMealsListRecord.createDoc(
                                    currentUserReference!)
                                .set(createSelectedMealsListRecordData(
                                    mealsList: []));
                          }

                          FFAppState().hasCompletedInitialSetup = true;

                          if (context.mounted) {
                            context.pushNamed(MealSelectionPgWidget.routeName);
                          }
                        },
                        text: 'Continue',
                        options: FFButtonOptions(
                          width: 200,
                          height: 58.9,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
                                fontFamily: 'Inter Tight',
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                fontSize: 22,
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
