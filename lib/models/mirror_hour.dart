class MirrorHour {
  final String time;
  final String message;
  bool isEnabled;

  MirrorHour({
    required this.time,
    required this.message,
    this.isEnabled = false,
  });
}
