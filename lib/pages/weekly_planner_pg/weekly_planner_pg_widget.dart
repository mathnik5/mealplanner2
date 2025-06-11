import '/index.dart';
import '/components/search_pop_up_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:intl/intl.dart'; // Added this import
import 'package:cloud_firestore/cloud_firestore.dart'; // Added this import
import '/flutter_flow/flutter_flow_widgets.dart';

export 'weekly_planner_pg_model.dart';

class WeeklyPlannerPgWidget extends StatefulWidget {
  const WeeklyPlannerPgWidget({super.key});

  static String routeName = 'weeklyPlannerPg';
  static String routePath = '/weeklyPlannerPg';

  @override
  State<WeeklyPlannerPgWidget> createState() => _WeeklyPlannerPgWidgetState();
}

class _WeeklyPlannerPgWidgetState extends State<WeeklyPlannerPgWidget> {
  late WeeklyPlannerPgModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];
  late List<Map<String, List<String>>> selectedMeals;
  bool _isLoading = true;
  DateTime? todaysDate;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WeeklyPlannerPgModel());

    selectedMeals = List.generate(7, (_) {
      return {for (var meal in mealTypes) meal: <String>[]};
    });

    todaysDate = DateTime.now();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        FFAppState().todaysDate = DateTime.now();
        if (mounted) {
          safeSetState(() {});
        }
      } catch (e) {
        print("FFAppState not available: $e");
      }
      await _loadWeeklyPlan();
    });
  }

  Future<void> _loadWeeklyPlan() async {
    if (currentUserUid.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final DateTime startDate = todaysDate ?? DateTime.now();
    List<Map<String, List<String>>> loadedPlanData =
        List.generate(7, (_) => {for (var meal in mealTypes) meal: <String>[]});
    try {
      for (int i = 0; i < 7; i++) {
        final dayDate = startDate.add(Duration(days: i));
        final dateString = DateFormat('yyyy-MM-dd').format(dayDate);
        final planDocSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .collection('plannedDays')
            .doc(dateString)
            .get();
        if (planDocSnapshot.exists) {
          final data = planDocSnapshot.data() as Map<String, dynamic>;
          for (String mealTypeKey in mealTypes) {
            final mealData = data[mealTypeKey.toLowerCase()];
            if (mealData != null) {
              loadedPlanData[i][mealTypeKey] = List<String>.from(mealData);
            }
          }
        }
      }
    } catch (e) {
      print("Error loading weekly plan: $e");
    }
    if (mounted) {
      setState(() {
        selectedMeals = loadedPlanData;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDayPlan(int dayIndex) async {
    if (currentUserUid.isEmpty) return;
    final DateTime startDate = todaysDate ?? DateTime.now();
    final dayDate = startDate.add(Duration(days: dayIndex));
    final dateString = DateFormat('yyyy-MM-dd').format(dayDate);
    final planDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('plannedDays')
        .doc(dateString);

    Map<String, dynamic> dataToSave = {'date': Timestamp.fromDate(dayDate)};
    for (String mealTypeKey in mealTypes) {
      dataToSave[mealTypeKey.toLowerCase()] =
          selectedMeals[dayIndex][mealTypeKey];
    }
    try {
      await planDocRef.set(dataToSave, SetOptions(merge: true));
    } catch (e) {
      print("Error saving plan for $dateString: $e");
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _removeItemFromPlanner(
      int dayIndex, String mealTypeName, String itemText) async {
    setState(() {
      selectedMeals[dayIndex][mealTypeName]?.remove(itemText);
    });
    await _saveDayPlan(dayIndex);
  }

  Widget buildMealColumn(int dayIndex, String mealTypeName) {
    final items = selectedMeals[dayIndex][mealTypeName] ?? [];
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 5.0, 0.0),
      child: Material(
        color: Colors.transparent,
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 120.0, minHeight: 100.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealTypeName,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            GoogleFonts.inter(fontWeight: FontWeight.w600)
                                .fontFamily,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 12.0),
                if (items.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: items.map((itemText) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Chip(
                          label: Text(itemText,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText)),
                          backgroundColor:
                              FlutterFlowTheme.of(context).alternate,
                          deleteIcon: Icon(Icons.close,
                              size: 14,
                              color:
                                  FlutterFlowTheme.of(context).secondaryText),
                          onDeleted: () => _removeItemFromPlanner(
                              dayIndex, mealTypeName, itemText),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                        ),
                      );
                    }).toList(),
                  )
                else
                  SizedBox(
                    width: 80.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("No items",
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodySmall),
                    ),
                  ),
                const SizedBox(height: 12.0),
                // --- THIS IS THE "ADD ITEM" BUTTON (FOCUSED MODE) ---
                InkWell(
                  onTap: () async {
                    // This opens the pop-up in 'singleSlot' mode
                    final result = await showModalBottomSheet<dynamic>(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: SearchPopUpWidget(
                            mode: 'singleSlot',
                            activeCategory: mealTypeName,
                            initialSelections: {
                              mealTypeName:
                                  selectedMeals[dayIndex][mealTypeName] ?? []
                            },
                          ),
                        );
                      },
                    );

                    // Handles the 'List<String>' returned by singleSlot mode
                    if (result != null && result is List<String> && mounted) {
                      setState(() {
                        selectedMeals[dayIndex][mealTypeName] = result;
                      });
                      await _saveDayPlan(dayIndex);
                    }
                  },
                  child: Material(
                    color: Colors.transparent,
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: FaIcon(FontAwesomeIcons.penToSquare,
                                  size: 14.0)),
                          Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text('Add Item',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                          fontFamily: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500)
                                              .fontFamily,
                                          fontSize: 14.0))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime plannerStartDate = todaysDate ?? DateTime.now();
    try {
      context.watch<FFAppState>();
    } catch (e) {
      print("FFAppState not available: $e");
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Meal Calendar',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: GoogleFonts.interTight(fontWeight: FontWeight.w600)
                    .fontFamily,
                color: Colors.white,
                fontSize: 26.0),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () => context.pushNamed('ProfilePg'),
            )
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: FlutterFlowTheme.of(context).primary))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(7, (dayIndex) {
                      final dayDate =
                          plannerStartDate.add(Duration(days: dayIndex));
                      return Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            10.0, 10.0, 10.0, 7.0),
                        child: Material(
                          color: Colors.transparent,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  8.0, 12.0, 8.0, 12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat("EEEE, MMM d")
                                              .format(dayDate),
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                fontFamily: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold)
                                                    .fontFamily,
                                                fontSize: 18.0,
                                              ),
                                        ),

                                        const SizedBox(height: 12.0),
                                        // --- UPDATED: "Plan Full Day" button is now full-width at the bottom ---
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: mealTypes
                                          .map((meal) =>
                                              buildMealColumn(dayIndex, meal))
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        final result =
                                            await showModalBottomSheet<dynamic>(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          enableDrag: false,
                                          context: context,
                                          builder: (context) {
                                            return Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: SearchPopUpWidget(
                                                mode: 'fullDay',
                                                dayDate: dayDate,
                                                initialSelections:
                                                    selectedMeals[dayIndex],
                                              ),
                                            );
                                          },
                                        );
                                        if (result != null &&
                                            result
                                                is Map<String, List<String>> &&
                                            mounted) {
                                          setState(() {
                                            selectedMeals[dayIndex] = result;
                                          });
                                          await _saveDayPlan(dayIndex);
                                        }
                                      },
                                      text: 'Plan Full Day',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 40,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(color: Colors.white),
                                        elevation: 2,
                                        borderSide: const BorderSide(
                                            color: Colors.transparent,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
        ),
      ),
    );
  }
}
