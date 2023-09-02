// import 'package:http/testing.dart';

class MOtInfo {
  final String? otStart;
  final String? otEnd;
  final String? shift;
  final String? status;
  final String? strDate;
  final String? dateNow;
  final DateTime? otDate;
  final double? otRate1Min;
  final double? otRate15Min;
  final double? otRate2Min;
  final double? otRate3Min;
  final String? otRate1Str;
  final String? otRate15Str;
  final String? otRate2Str;
  final String? otRate3Str;
  MOtInfo({
    required this.otStart,
    required this.otEnd,
    required this.shift,
    required this.status,
    required this.strDate,
    required this.dateNow,
    required this.otDate,
    required this.otRate1Min,
    required this.otRate15Min,
    required this.otRate2Min,
    required this.otRate3Min,
    required this.otRate1Str,
    required this.otRate15Str,
    required this.otRate2Str,
    required this.otRate3Str,
  });

  factory MOtInfo.fromJson(Map<String, dynamic> json) {
    return MOtInfo(
        otStart: json['otStart'],
        otEnd: json['otEnd'],
        shift: json['shift'],
        status: json['status'],
        strDate: json['strDate'],
        dateNow: json['dateNow'],
        otDate: DateTime.parse(json['otDate']),
        otRate1Min: json['otRate1Min'],
        otRate15Min: json['otRate15Min'],
        otRate2Min: json['otRate2Min'],
        otRate3Min: json['otRate3Min'],
        otRate1Str: json['otRate1Str'],
        otRate15Str: json['otRate15Str'],
        otRate2Str: json['otRate2Str'],
        otRate3Str: json['otRate3Str']);
  }
}
