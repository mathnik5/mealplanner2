import '/index.dart';
import '/components/search_pop_up_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart'; // For currentUserReference, currentUserUid
import '/backend/backend.dart'; // For Firestore query functions if any were used directly (not in this version)
// import '/flutter_flow/custom_functions.dart' as functions; // Not used in this version
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore direct access
import 'package:intl/intl.dart'; // For DateFormat
import 'weekly_planner_pg_model.dart';

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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WeeklyPlannerPgModel());

    selectedMeals = List.generate(7, (_) {
      return {for (var meal in mealTypes) meal: <String>[]};
    });

    // Ensure FFAppState().todaysDate is set.
    // The original logic might be specific to FlutterFlow's state management nuances.
    // If FFAppState().todaysDate can be guaranteed to be set before this page,
    // some parts of this could be simplified.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // This sequence of setting to null, then to now, might be to force updates
      // in some FlutterFlow contexts. Or, it ensures 'todaysDate' always reflects the actual 'today'
      // when this page is loaded.
      if (mounted) {
        FFAppState().todaysDate = null;
        // safeSetState is part of FF_util, calling setState on this widget if mounted
        safeSetState(() {});
        FFAppState().todaysDate = getCurrentTimestamp;
        safeSetState(() {});
      }
      _loadWeeklyPlan(); // Load plan after today's date is confirmed/set
    });
  }

  Future<void> _loadWeeklyPlan() async {
    if (currentUserReference == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final DateTime startDate = FFAppState().todaysDate ?? DateTime.now();
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
            // Firestore field names are typically lowercase, e.g., 'breakfast'
            loadedPlanData[i][mealTypeKey] =
                List<String>.from(data[mealTypeKey.toLowerCase()] ?? []);
          }
        }
      }
    } catch (e) {
      print("Error loading weekly plan: $e");
      // Optionally show a snackbar or error message to the user
    }

    if (mounted) {
      setState(() {
        selectedMeals = loadedPlanData;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDayPlan(int dayIndex) async {
    if (currentUserReference == null) return;

    final DateTime startDate = FFAppState().todaysDate ?? DateTime.now();
    final dayDate = startDate.add(Duration(days: dayIndex));
    final dateString = DateFormat('yyyy-MM-dd').format(dayDate);

    final planDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('plannedDays')
        .doc(dateString);

    Map<String, dynamic> dataToSave = {
      'date': Timestamp.fromDate(dayDate), // Store the actual date for querying
    };
    for (String mealTypeKey in mealTypes) {
      dataToSave[mealTypeKey.toLowerCase()] =
          selectedMeals[dayIndex][mealTypeKey];
    }

    try {
      await planDocRef.set(dataToSave, SetOptions(merge: true));
      // Optionally show a success message, though it might be too frequent
      // print('Plan for $dateString saved.');
    } catch (e) {
      print("Error saving plan for $dateString: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error saving plan for $dateString. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget buildMealColumn(int dayIndex, String mealTypeName) {
    final items = selectedMeals[dayIndex][mealTypeName]!;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 5.0, 0.0),
      child: Material(
        color: Colors.transparent,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ConstrainedBox(
          // Ensures minimum width for better tap targets if empty
          constraints: const BoxConstraints(
              minWidth: 120.0, minHeight: 100.0), // Adjusted minWidth
          child: Container(
            padding: const EdgeInsets.all(8.0), // Increased padding
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // So column doesn't expand unnecessarily
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch children horizontally
              children: [
                Text(
                  mealTypeName,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            GoogleFonts.inter(fontWeight: FontWeight.w600)
                                .fontFamily,
                        fontSize: 16.0, // Slightly smaller for better fit
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 8.0),
                if (items.isNotEmpty)
                  Expanded(
                    // Allow list to take available space and scroll if needed
                    child: ListView.builder(
                      // Use ListView for scrollability if many items
                      shrinkWrap:
                          true, // Important if inside another scroll view or Expanded
                      itemCount: items.length,
                      itemBuilder: (context, itemIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '• ${items[itemIndex]}', // Added bullet point
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontSize: 14.0, // Slightly smaller
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodySmallFamily,
                                    ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                      child: Center(
                          child: Text("No items",
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall))), // Placeholder

                const SizedBox(height: 8.0),
                InkWell(
                  onTap: () async {
                    final result = await showModalBottomSheet<List<String>>(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag:
                          false, // Usually false for full screen type modals
                      context: context,
                      builder: (context) {
                        return Padding(
                          // Padding for keyboard
                          padding: MediaQuery.viewInsetsOf(context),
                          child: SearchPopUpWidget(
                            initiallySelectedMealNames: selectedMeals[dayIndex]
                                [mealTypeName],
                          ),
                        );
                      },
                    );

                    if (result != null && mounted) {
                      // Check mounted before setState
                      setState(() {
                        selectedMeals[dayIndex][mealTypeName] = result;
                      });
                      await _saveDayPlan(
                          dayIndex); // Save the updated plan for this day
                    }
                  },
                  child: Material(
                    // Added Material for elevation and consistent look
                    color: Colors.transparent,
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5.0), // Smaller radius
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0), // Adjusted padding
                      decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1)),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: FaIcon(FontAwesomeIcons.penToSquare,
                                size: 14.0),
                          ),
                          Text(
                            'Add Item',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500)
                                      .fontFamily,
                                  fontSize: 14.0, // Slightly smaller
                                ),
                          ),
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
    // FFAppState().todaysDate should be initialized in initState or by a previous page.
    // We read it here for building the UI.
    final DateTime plannerStartDate = FFAppState().todaysDate ?? DateTime.now();
    context.watch<FFAppState>(); // Watch for potential changes if needed

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading:
              false, // Consider adding a back button or profile button
          title: Text(
            'Meal Calendar',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily:
                      GoogleFonts.interTight(fontWeight: FontWeight.w600)
                          .fontFamily,
                  color: Colors.white,
                  fontSize: 26.0,
                ),
          ),
          actions: [
            // Example: Add a profile button
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                context.pushNamed(ProfilePgWidget.routeName);
              },
            )
          ],
          centerTitle: false, // Usually false if you have leading/actions
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: FlutterFlowTheme.of(context).primary))
              : SingleChildScrollView(
                  // Main vertical scroll for days
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
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
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Day card background
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  8.0, 8.0, 8.0, 12.0), // Adjusted padding
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            4.0,
                                            4.0,
                                            0.0,
                                            8.0), // Adjusted padding
                                    child: Text(
                                      DateFormat("EEEE, MMM d").format(
                                          dayDate), // More readable date format
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            fontFamily: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold)
                                                .fontFamily,
                                            fontSize: 18.0,
                                          ),
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    // Horizontal scroll for meal types within a day
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Align cards to top
                                      children: mealTypes
                                          .map((meal) =>
                                              buildMealColumn(dayIndex, meal))
                                          .toList(),
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
