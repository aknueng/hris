class MAnnualInfo {
  final String yearAnnual;
  final String totalAnnual;
  final String fullTotal;
  final String getAnnual;
  final String useAnnual;
  final String remainAnnual;
  final String totalText;
  final String fullTotalText;
  final String useText;
  final String remainHr;

  MAnnualInfo({
    required this.yearAnnual,
    required this.totalAnnual,
    required this.fullTotal,
    required this.getAnnual,
    required this.useAnnual,
    required this.remainAnnual,
    required this.totalText,
    required this.fullTotalText,
    required this.useText,
    required this.remainHr,
  });

  factory MAnnualInfo.fromJson(Map<String, dynamic> json) {
    return MAnnualInfo(
        yearAnnual: json['year_annual'].toString(),
        totalAnnual: json['total_annual'].toString(),
        fullTotal: json['fullTotal'].toString(),
        getAnnual: json['get_annual'].toString(),
        useAnnual: json['use_annual'].toString(),
        remainAnnual: json['remain_annual'].toString(),
        totalText: json['totalText'].toString(),
        fullTotalText: json['fullTotalText'].toString(),
        useText: json['useText'].toString(),
        remainHr: json['remainHr'].toString());
  }

  // required this.year_annual,
  // required this.total_annual,
  // required this.fullTotal,
  // required this.get_annual,
  // required this.use_annual,
  // required this.remain_annual,
  // required this.totalText,
  // required this.fullTotalText,
  // required this.useText,
  // required this.remainHr,
}
