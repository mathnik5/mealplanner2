

DateTime nextDate(DateTime? nextdate) {
  return (nextdate ?? DateTime.now()).add(const Duration(days: 1));
}
