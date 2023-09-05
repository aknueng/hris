class MLVInfo {
  final String code;
  final String cDate;
  final String type;
  final String lvFrom;
  final String lvTo;
  final String times;
  final String lvNo;
  final String reason;
  final String lvStatus;
  final String reqSTATUS;
  MLVInfo({
    required this.code,
    required this.cDate,
    required this.type,
    required this.lvFrom,
    required this.lvTo,
    required this.times,
    required this.lvNo,
    required this.reason,
    required this.lvStatus,
    required this.reqSTATUS,
  });

  factory MLVInfo.fromJson(Map<String, dynamic> json) {
    return MLVInfo(
        code: json['code'],
        cDate: json['cDate'],
        type: json['type'],
        lvFrom: json['lvFrom'],
        lvTo: json['lvTo'],
        times: json['times'],
        lvNo: json['lvNo'],
        reason: json['reason'],
        lvStatus: json['lvStatus'],
        reqSTATUS: json['reQ_STATUS']);
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'cDate': cDate,
        'type': type,
        'lvFrom': lvFrom,
        'lvTo': lvTo,
        'times': times,
        'lvNo': lvNo,
        'reason': reason,
        'lvStatus': lvStatus,
        'reQ_STATUS': reqSTATUS,
      };
}

class MLVReq {
  final String empCode;
  final String cDate;
  final String lvType;
  final String lvFrom;
  final String lvTo;
  final String lvReason;

  MLVReq({
    required this.empCode,
    required this.cDate,
    required this.lvType,
    required this.lvFrom,
    required this.lvTo,
    required this.lvReason,
  });

  factory MLVReq.fromJson(Map<String, dynamic> json) {
    return MLVReq(
        empCode: json['empCode'].toString(),
        cDate: json['cDate'].toString(),
        lvType: json['lvType'].toString(),
        lvFrom: json['lvFrom'].toString(),
        lvTo: json['lvTo'].toString(),
        lvReason: json['lvReason'].toString());
  }
}
