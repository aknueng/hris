class MSlipInfo {
  final String? docNo;
  final String? docType;
  final String? code;
  final String? reqDate;
  final String? approveBy;
  final String? approveDate;
  final String? issueBy;
  final String? issueDate;
  final String? expireDate;
  final String? docFile;
  final String? docStatus;
  final String? passcode;
  final String? remark;

  MSlipInfo({
    required this.docNo,
    required this.docType,
    required this.code,
    required this.reqDate,
    required this.approveBy,
    required this.approveDate,
    required this.issueBy,
    required this.issueDate,
    required this.expireDate,
    required this.docFile,
    required this.docStatus,
    required this.passcode,
    required this.remark,
  });

  factory MSlipInfo.fromJson(Map<String, dynamic> json) {
    return MSlipInfo(
        docNo: json['docNo'] as String,
        docType: json['docType'] as String,
        code: json['code'] as String,
        //reqDate: DateTime.parse(json['reqDate']),
        reqDate: json['reqDate'].toString(),
        approveBy: json['approveBy'] as String,
        //approveDate: DateTime.parse(json['approveDate']) ,
        approveDate: json['approveDate'].toString(),
        issueBy: json['issueBy'] as String,
        //issueDate: DateTime.parse(json['issueDate']),
        issueDate: json['issueDate'].toString(),
        //expireDate: DateTime.parse(json['expireDate']),
        expireDate: json['expireDate'].toString(),
        docFile: json['docFile'] as String,
        docStatus: json['docStatus'] as String,
        passcode: json['passcode'] as String,
        remark: json['remark'] as String);
  }
}
