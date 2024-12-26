class MirrorHour {
  final String time;
  final String message;
  bool isEnabled;

  MirrorHour({
    required this.time,
    required this.message,
    this.isEnabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'message': message,
      'isEnabled': isEnabled,
    };
  }

  factory MirrorHour.fromJson(Map<String, dynamic> json) {
    return MirrorHour(
      time: json['time'] as String,
      message: json['message'] as String,
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }
}