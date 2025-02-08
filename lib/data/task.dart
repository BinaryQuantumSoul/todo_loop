class Task {
  int? id;
  int? position;
  String title;
  List<bool> days;
  Duration? time;
  bool isNew;
  bool isChecked;
  int showedCounter;
  int doneCounter;

  Task({
    this.id,
    this.position,
    required this.title,
    required this.days,
    this.time,
    this.isNew = true,
    this.isChecked = false,
    this.showedCounter = 0,
    this.doneCounter = 0,
  });

  static int _encodeDays(List<bool> days) {
    return days.fold(0, (a, b) => (a << 1) | (b ? 1 : 0));
  }

  static List<bool> _decodeDays(int code) {
    return List.generate(7, (i) => code & (1 << (6 - i)) != 0);
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (position != null) 'position': position,
        'title': title,
        'time': time?.inMinutes,
        'days': _encodeDays(days),
        'isNew': isNew ? 1 : 0,
        'isChecked': isChecked ? 1 : 0,
        'showedCounter': showedCounter,
        'doneCounter': doneCounter,
      };

  static Task fromMap(Map<String, dynamic> json) => Task(
        id: json['id'],
        position: json['position'],
        title: json['title'] as String,
        time: json['time'] != null ? Duration(minutes: json['time']) : null,
        days: _decodeDays(json['days']),
        isNew: json['isNew'] == 1,
        isChecked: json['isChecked'] == 1,
        showedCounter: json['showedCounter'],
        doneCounter: json['doneCounter'],
      );

  bool isActive(DateTime dateTime) => days[dateTime.weekday - 1];
}
