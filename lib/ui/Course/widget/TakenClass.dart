class TakenClass {
  final String docId;
  final String time;
  final String date;
  final int attendanceWeight;
  final int classDuration;
  final int presentCount;
  final int absentCount;
  final int lateCount;

  TakenClass({
    required this.docId,
    required this.time,
    required this.date,
    required this.attendanceWeight,
    required this.classDuration,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
  });
}