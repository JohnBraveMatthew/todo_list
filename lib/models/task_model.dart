class Task {
  int id;
  String title;
  DateTime date;
  String priority;
  int status;

  Task({this.title, this.date, this.priority, this.status});
  Task.withId({this.id, this.title, this.date, this.priority, this.status});

  static const tblName = "task_table";
  static const colId = "id";
  static const colTitle = "title";
  static const colDate = "date";
  static const colPriority = "priority";
  static const colStatus = "status";

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colTitle: title,
      colPriority: priority,
      colDate: date.toIso8601String(),
      colStatus: status
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
        id: map[colId],
        title: map[colTitle],
        date: DateTime.parse(map[colDate]),
        priority: map[colPriority],
        status: map[colStatus]);
  }
}
