// lib/app_state.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();
  static FFAppState get instance => _instance;

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _userPrefVeg = prefs.getBool('ff_userPrefVeg') ?? _userPrefVeg;
    });
    _safeInit(() {
      _userPrefNonVeg = prefs.getBool('ff_userPrefNonVeg') ?? _userPrefNonVeg;
    });
    _safeInit(() {
      _userPrefEgg = prefs.getBool('ff_userPrefEgg') ?? _userPrefEgg;
    });

    // --- Regarding _selectedMeals ---
    // This list (_selectedMeals) was persisted in SharedPreferences.
    // Consider if this is still needed, as the primary selection mechanism appears to be:
    // 1. MyMealsRecord.isSelected (in Firestore) for individual meal selection status.
    // 2. SelectedMealsListRecord (in Firestore) for storing the list of globally selected/favorite meal names.
    // 3. Pop-up selections are transient for that session (_selectedByCategory in SearchPopUpWidget).
    // If _selectedMeals in FFAppState is intended to be a global, quickly accessible cache
    // of favorite meal names, its synchronization with Firestore (SelectedMealsListRecord)
    // needs to be carefully managed. If it's redundant, it can be removed.
    // For now, it's commented out.
    /*
    _safeInit(() {
      _selectedMeals =
          prefs.getStringList('ff_selectedMeals') ?? _selectedMeals;
    });
    */

    _safeInit(() {
      _currentMealSelection =
          prefs.getString('ff_currentMealSelection') ?? _currentMealSelection;
    });
    _safeInit(() {
      _todaysDate = prefs.containsKey('ff_todaysDate')
          ? DateTime.fromMillisecondsSinceEpoch(prefs.getInt('ff_todaysDate')!)
          : _todaysDate; // Keeps initial null if not in prefs
    });
    _safeInit(() {
      _hasCompletedInitialSetup =
          prefs.getBool('ff_hasCompletedInitialSetup') ??
              _hasCompletedInitialSetup;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _userPrefVeg =
      true; // Defaulting to true as an example, adjust if needed
  bool get userPrefVeg => _userPrefVeg;
  set userPrefVeg(bool value) {
    _userPrefVeg = value;
    prefs.setBool('ff_userPrefVeg', value);
  }

  bool _userPrefNonVeg = false;
  bool get userPrefNonVeg => _userPrefNonVeg;
  set userPrefNonVeg(bool value) {
    _userPrefNonVeg = value;
    prefs.setBool('ff_userPrefNonVeg', value);
  }

  bool _userPrefEgg = false;
  bool get userPrefEgg => _userPrefEgg;
  set userPrefEgg(bool value) {
    _userPrefEgg = value;
    prefs.setBool('ff_userPrefEgg', value);
  }

  // --- _selectedMeals commented out ---
  /*
  List<String> _selectedMeals = [];
  List<String> get selectedMeals => _selectedMeals;
  set selectedMeals(List<String> value) {
    _selectedMeals = value;
    prefs.setStringList('ff_selectedMeals', value);
  }

  void addToSelectedMeals(String value) {
    _selectedMeals.add(value);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }

  void removeFromSelectedMeals(String value) {
    _selectedMeals.remove(value);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }

  void removeAtIndexFromSelectedMeals(int index) {
    _selectedMeals.removeAt(index);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }

  void updateSelectedMealsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    _selectedMeals[index] = updateFn(_selectedMeals[index]);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }

  void insertAtIndexInSelectedMeals(int index, String value) {
    _selectedMeals.insert(index, value);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }
  */

  // This field's purpose needs review. Is it related to the pop-up temporary selection,
  // or a general meal selection context?
  String _currentMealSelection = '';
  String get currentMealSelection => _currentMealSelection;
  set currentMealSelection(String value) {
    _currentMealSelection = value;
    prefs.setString('ff_currentMealSelection', value);
  }

  /// For identifying the date on which the app is open, for displaying the days
  /// on the calander.
  DateTime? _todaysDate;
  DateTime? get todaysDate => _todaysDate;
  set todaysDate(DateTime? value) {
    _todaysDate = value;
    if (value != null) {
      prefs.setInt('ff_todaysDate', value.millisecondsSinceEpoch);
    } else {
      prefs.remove('ff_todaysDate');
    }
  }

  // New flag to track if the user has completed the initial diet preference setup.
  bool _hasCompletedInitialSetup = false;
  bool get hasCompletedInitialSetup => _hasCompletedInitialSetup;
  set hasCompletedInitialSetup(bool value) {
    _hasCompletedInitialSetup = value;
    prefs.setBool('ff_hasCompletedInitialSetup', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {
    // Handle initialization error, if necessary
    // For example, log the error: print('Error initializing field: $_');
  }
}
