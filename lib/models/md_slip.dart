class MSlipInfo {
  final String? docNo;
  final String? docType;
  final String? code;
  final DateTime? reqDate;
  final String? approveBy;
  final DateTime? approveDate;
  final String? issueBy;
  final DateTime? issueDate;
  final DateTime? expireDate;
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
        docNo: json['docNo'],
        docType: json['docType'],
        code: json['code'],
        reqDate: DateTime.parse(json['reqDate']),
        // reqDate: json['reqDate'].toString(),
        approveBy: json['approveBy'],
        approveDate: DateTime.parse(json['approveDate']) ,
        // approveDate: json['approveDate'].toString(),
        issueBy: json['issueBy'],
        issueDate: DateTime.parse(json['issueDate']),
        // issueDate: json['issueDate'].toString(),
        expireDate: DateTime.parse(json['expireDate']),
        // expireDate: json['expireDate'].toString(),
        docFile: json['docFile'],
        docStatus: json['docStatus'],
        passcode: json['passcode'],
        remark: json['remark']);
  }
}
