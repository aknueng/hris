class MTrainingInfo {
  final String empcode;
  final String courseCode;
  final String courseName;
  final String courseNameEn;
  final String cost;
  final String scheduleStart;
  final String scheduleEnd;
  final String hours;
  final String scheduleDetail;
  final String trainerType;
  final String trainerCompany;
  final String location;
  final String locationType;
  final String certificate;
  final String preTestResult;
  final String postTestResult;
  final String evaluateResult;
  final String percentScore;
  final String examSetPointTotal;
  final String mark;

  MTrainingInfo({
    required this.empcode,
    required this.courseCode,
    required this.courseName,
    required this.courseNameEn,
    required this.cost,
    required this.scheduleStart,
    required this.scheduleEnd,
    required this.hours,
    required this.scheduleDetail,
    required this.trainerType,
    required this.trainerCompany,
    required this.location,
    required this.locationType,
    required this.certificate,
    required this.preTestResult,
    required this.postTestResult,
    required this.evaluateResult,
    required this.percentScore,
    required this.examSetPointTotal,
    required this.mark,
  });

  factory MTrainingInfo.fromJson(Map<String, dynamic> json) {
    return MTrainingInfo(
        empcode: json['empcode'].toString(),
        courseCode: json['courseCode'].toString(),
        courseName: json['courseName'].toString(),
        courseNameEn: json['courseNameEn'].toString(),
        cost: json['cost'].toString(),
        scheduleStart: json['scheduleStart'].toString(),
        scheduleEnd: json['scheduleEnd'].toString(),
        hours: json['hours'].toString(),
        scheduleDetail: json['scheduleDetail'].toString(),
        trainerType: json['trainerType'].toString(),
        trainerCompany: json['trainerCompany'].toString(),
        location: json['location'].toString(),
        locationType: json['locationType'].toString(),
        certificate: json['certificate'].toString(),
        preTestResult: json['preTestResult'].toString(),
        postTestResult: json['postTestResult'].toString(),
        evaluateResult: json['evaluateResult'].toString(),
        percentScore: json['percentScore'].toString(),
        examSetPointTotal: json['examSetPointTotal'].toString(),
        mark: json['mark'].toString());
  }
}
