// import 'package:http/testing.dart';

class MOtInfo {
  final String? otStart;
  final String? otEnd;
  final String? shift;
  final String? status;
  final String? strDate;
  final String? dateNow;
  final String? otDate;
  final String? otRate1Min;
  final String? otRate15Min;
  final String? otRate2Min;
  final String? otRate3Min;
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
        otDate:  json['otDate'].toString(),
        otRate1Min: json['otRate1Min'].toString(),
        otRate15Min: json['otRate15Min'].toString(),
        otRate2Min: json['otRate2Min'].toString(),
        otRate3Min: json['otRate3Min'].toString(),
        otRate1Str: json['otRate1Str'],
        otRate15Str: json['otRate15Str'],
        otRate2Str: json['otRate2Str'],
        otRate3Str: json['otRate3Str']);
  }
}

class MOtReq {
  final String empCode;
  final String empShortName;
  final String otDate;
  final String otType;
  final String otJob;
  final String empWType;

  MOtReq({
    required this.empCode,
    required this.empShortName,
    required this.otDate,
    required this.otType,
    required this.otJob,
    required this.empWType,
  });
}

class MOTJob {
  final String dataValue;
  final String dataDisplay;
  MOTJob({required this.dataValue, required this.dataDisplay});

  factory MOTJob.fromJsom(Map<String, dynamic> json) {
    return MOTJob(
        dataValue: json['dataValue'], dataDisplay: json['dataDisplay']);
  }

  Map<String, dynamic> toJson() => {
        "dataValue": dataValue,
        "dataDisplay": dataDisplay,
      };
}
