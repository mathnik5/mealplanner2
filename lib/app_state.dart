import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  String selectedBreakfast = '';

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
    _safeInit(() {
      _selectedMeals =
          prefs.getStringList('ff_selectedMeals') ?? _selectedMeals;
    });
    _safeInit(() {
      _currentMealSelection =
          prefs.getString('ff_currentMealSelection') ?? _currentMealSelection;
    });
    _safeInit(() {
      _todaysDate = prefs.containsKey('ff_todaysDate')
          ? DateTime.fromMillisecondsSinceEpoch(prefs.getInt('ff_todaysDate')!)
          : _todaysDate;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _userPrefVeg = true;
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

  List<String> _selectedMeals = [];
  List<String> get selectedMeals => _selectedMeals;
  set selectedMeals(List<String> value) {
    _selectedMeals = value;
    prefs.setStringList('ff_selectedMeals', value);
  }

  void addToSelectedMeals(String value) {
    selectedMeals.add(value);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }

  void removeFromSelectedMeals(String value) {
    selectedMeals.remove(value);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }

  void removeAtIndexFromSelectedMeals(int index) {
    selectedMeals.removeAt(index);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }

  void updateSelectedMealsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    selectedMeals[index] = updateFn(_selectedMeals[index]);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }

  void insertAtIndexInSelectedMeals(int index, String value) {
    selectedMeals.insert(index, value);
    prefs.setStringList('ff_selectedMeals', _selectedMeals);
  }

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
    value != null
        ? prefs.setInt('ff_todaysDate', value.millisecondsSinceEpoch)
        : prefs.remove('ff_todaysDate');
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}
