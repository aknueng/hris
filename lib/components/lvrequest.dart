import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/models/md_account.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LVRequestScreen extends StatefulWidget {
  const LVRequestScreen({super.key, this.restorationId});

  final String? restorationId;

  @override
  State<LVRequestScreen> createState() => _LVRequestScreenState();
}

class _LVRequestScreenState extends State<LVRequestScreen>
    with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  static int initDate = 0;
  static int limitDate = 45;

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          // initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          initialDate: (initDate == 0)
              ? DateTime.now()
              : DateTime.now().add(Duration(days: initDate)),
          firstDate: (initDate == 0)
              ? DateTime.now()
              : DateTime.now().add(Duration(days: initDate)),
          lastDate: (limitDate == 0)
              ? DateTime.now()
              : DateTime.now().add(Duration(days: limitDate)),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        selectDate = newSelectedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(() async {
      if (oAccount == null || oAccount!.code == '') {
        Navigator.pushNamed(context, '/login');
      }
    });
  }

  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  String? selType;
  String? selTypeDay;
  String? selReason;

  DateTime selectDate = DateTime(1900, 1, 1);
  DateFormat formatDMY = DateFormat("dd/MMMM/yyyy");
  DateFormat formatYMD = DateFormat("yyyyMMdd");

  Future getValidateAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      oAccount = MAccount(
          code: prefs.getString('code') ?? '',
          name: prefs.getString('name') ?? '',
          surn: prefs.getString('surn') ?? '',
          shortName: prefs.getString('shortName') ?? '',
          fullName: prefs.getString('fullName') ?? '',
          tName: prefs.getString('tName') ?? '',
          tSurn: prefs.getString('tSurn') ?? '',
          joinDate: DateTime.parse(
              prefs.getString('joinDate') ?? DateTime.now().toString()),
          tFullName: prefs.getString('tFullName') ?? '',
          posit: prefs.getString('posit') ?? '',
          token: prefs.getString('token') ?? '',
          logInDate: DateTime.parse(
              prefs.getString('logInDate') ?? DateTime.now().toString()));
    });
  }

  List<DropdownMenuItem<String>> oAryLVDay = [
    const DropdownMenuItem<String>(value: 'ALL', child: Text('ลาทั้งวัน')),
    const DropdownMenuItem<String>(
        value: 'HALF1', child: Text('ลาครึ่งวันเช้า')),
    const DropdownMenuItem<String>(
        value: 'HALF2', child: Text('ลาครึ่งวันบ่าย')),
  ];

  List<DropdownMenuItem<String>> oAryLVDayA = [
    const DropdownMenuItem<String>(value: 'ALL', child: Text('ลาทั้งวัน')),
  ];

  List<DropdownMenuItem<String>> oAryReasonAnnu = [
    const DropdownMenuItem<String>(value: 'ANNU01', child: Text('ลาพักร้อน')),
    const DropdownMenuItem<String>(
        value: 'ANNU02', child: Text('เหตุจากระบบตั้งครรภ์(หญิงมีครรภ์)')),
    const DropdownMenuItem<String>(
        value: 'ANNU03', child: Text('ประสบอุบัติเหตุ(ปฏิบัติงานได้)')),
    const DropdownMenuItem<String>(
        value: 'ANNU04',
        child: Text('สงสัยติดเชื้อหรือเข้าข่ายอาจติดเชื้อ (Covid-19)')),
  ];

  List<DropdownMenuItem<String>> oAryReasonSick = [
    const DropdownMenuItem<String>(value: '', child: Text('เลือกเหตุผล')),
    const DropdownMenuItem<String>(
        value: 'SICK01', child: Text('ไม่สบาย มีไข้')),
    const DropdownMenuItem<String>(
        value: 'SICK02', child: Text('ท้องเสีย ปวดท้อง')),
    const DropdownMenuItem<String>(
        value: 'SICK03', child: Text('ประสบอุบัติเหตุ')),
    const DropdownMenuItem<String>(
        value: 'SICK04', child: Text('กล้ามเนื้ออักเสบ')),
    const DropdownMenuItem<String>(value: 'SICK05', child: Text('ผ่าตัด')),
    const DropdownMenuItem<String>(
        value: 'SICK06', child: Text('ป่วยตามโรคประจำตัว')),
  ];

  List<DropdownMenuItem<String>> oAryReasonOTH = [
    const DropdownMenuItem<String>(value: 'MARR', child: Text('ลาแต่งงาน')),
    const DropdownMenuItem<String>(
        value: 'CARE', child: Text('ลาเพื่อดูแลภรรยาคลอดบุตร')),
    const DropdownMenuItem<String>(value: 'STER', child: Text('ลาทำหมัน')),
    const DropdownMenuItem<String>(value: 'FUNE', child: Text('ลางานศพ')),
  ];

  List<DropdownMenuItem<String>> oAryReasonPers = [
    const DropdownMenuItem<String>(value: '', child: Text('เลือกเหตุผล')),
    const DropdownMenuItem<String>(
        value: 'PERS01', child: Text('ติดต่อหน่วยงานราชการ')),
    const DropdownMenuItem<String>(
        value: 'PERS02', child: Text('ทำธุระส่วนตัว')),
    const DropdownMenuItem<String>(
        value: 'PERS03', child: Text('ดูแลคนในครอบครัว')),
    const DropdownMenuItem<String>(value: 'PERS04', child: Text('รถเสีย')),
    const DropdownMenuItem<String>(
        value: 'PERS05', child: Text('กลับต่างจังหวัด')),
    const DropdownMenuItem<String>(
        value: 'PERS06', child: Text('ปัญหาการจราจร')),
  ];

  List<DropdownMenuItem<String>> oAryLVType = [
    const DropdownMenuItem<String>(value: '', child: Text('เลือกประเภทการลา')),
    const DropdownMenuItem<String>(
        value: 'ANNU', child: Text('ลาพักร้อน (ANNU)')),
    const DropdownMenuItem<String>(value: 'PERS', child: Text('ลากิจ (PERS)')),
    const DropdownMenuItem<String>(value: 'SICK', child: Text('ลาป่วย (SICK)')),
    const DropdownMenuItem<String>(
        value: 'MARR', child: Text('ลาแต่งงาน (MARR)')),
    const DropdownMenuItem<String>(
        value: 'CARE', child: Text('ลาเพื่อดูแลภรรยาคลอดบุตร (CARE)')),
    const DropdownMenuItem<String>(
        value: 'STER', child: Text('ลาทำหมัน (STER)')),
    const DropdownMenuItem<String>(
        value: 'FUNE', child: Text('ลางานศพ (FUNE)')),
  ];

  List<DropdownMenuItem> loadReason() {
    if (selType == "ANNU") {
      return oAryReasonAnnu;
    } else if (selType == "PERS") {
      return oAryReasonPers;
    } else if (selType == "SICK") {
      return oAryReasonSick;
    } else if (selType == "") {
      return oAryReasonAnnu;
    } else {
      return oAryReasonOTH;
    }
  }

//======== Record Leave Data ============
  Future requestLV(DateTime paramLVDate, String paramLVType, String paramLVFrom,
      String paramLVTo, String paramReason) async {
    // print('>> ${formatYMD.format(paramLVDate)} $paramLVType $paramLVFrom $paramLVTo $paramReason');
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/reqlv'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'EmpCode': oAccount!.code,
          'CDate': formatYMD.format(paramLVDate),
          'LvType': paramLVType,
          'LvFrom': paramLVFrom,
          'LvTo': paramLVTo,
          'LVReason': paramReason
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (context.mounted) {
        Navigator.pushNamed(context, '/lv');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกการลาเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(30),
          ),
        );
      }
    }
  }

  //======== Check Leave Data ============
  Future<bool> checkLV(DateTime paramLVDate, String paramLVType,
      String paramLVFrom, String paramLVTo, String paramReason) async {
    // print('>> ${formatYMD.format(paramLVDate)} $paramLVType $paramLVFrom $paramLVTo $paramReason');
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/checkLV'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'EmpCode': oAccount!.code,
          'CDate': formatYMD.format(paramLVDate),
          'LvType': paramLVType,
          'LvFrom': paramLVFrom,
          'LvTo': paramLVTo,
          'LVReason': paramReason
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      setState(() {
        selectDate = DateTime(1900, 1, 1);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('วันลาพักร้อนเกิน'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(30),
          ),
        );
      }

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('ร้องขอวันลา (Leave Request)'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface,
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Container(
              padding:
                  const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
              margin:
                  const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: (selType == '' || selType == null)
                          ? Colors.red[900]!
                          : Colors.yellow[600]!,
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      style: BorderStyle.solid),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 1,
                        color: (selType == '' || selType == null)
                            ? Colors.red.withOpacity(0.1)
                            : Colors.yellow.withOpacity(0.1),
                        spreadRadius: 0)
                  ]),
              child: DropdownButton(
                isExpanded: true,
                items: oAryLVType,
                value: selType ?? '',
                onChanged: (value) {
                  setState(() {
                    selectDate = DateTime(1900, 1, 1);

                    if (value != '') {
                      selType = value;
                      selTypeDay = 'ALL';

                      if (value == 'ANNU') {
                        initDate = 3;
                        limitDate = 45;
                        selReason = 'ANNU01';
                      } else if (value == 'PERS') {
                        initDate = 3;
                        limitDate = 45;
                        selReason = '';
                      } else if (value == 'SICK') {
                        initDate = 0;
                        limitDate = 0;
                        selReason = '';
                      } else if (value == 'MARR') {
                        initDate = 3;
                        limitDate = 45;
                        selReason = value;
                      } else {
                        initDate = 0;
                        limitDate = 45;
                        selReason = value;
                      }
                    } else {
                      initDate = 0;
                      // selReason = '';
                    }
                  });
                },
              ),
            ),
            const Divider(),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
              margin:
                  const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: (selectDate.year < 2000)
                          ? Colors.red[900]!
                          : Colors.yellow[600]!,
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      style: BorderStyle.solid),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 1,
                        color: (selectDate.year < 2000)
                            ? Colors.red.withOpacity(0.1)
                            : Colors.yellow.withOpacity(0.1),
                        spreadRadius: 0)
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      const Text('ลางานวันที่ : '),
                      (selectDate.year > 2000)
                          ? Text(formatDMY.format(selectDate))
                          : const Text('-')
                    ],
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        _restorableDatePickerRouteFuture.present();
                      },
                      icon: const Icon(Icons.date_range),
                      label: const Text('เลือกวันที่ต้องการลางาน')),
                ],
              ),
            ),
            const Divider(),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
              margin:
                  const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: (selTypeDay == '' || selTypeDay == null)
                          ? Colors.red[900]!
                          : Colors.yellow[600]!,
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      style: BorderStyle.solid),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 1,
                        color: (selTypeDay == '' || selTypeDay == null)
                            ? Colors.red.withOpacity(0.1)
                            : Colors.yellow.withOpacity(0.1),
                        spreadRadius: 0)
                  ]),
              child: DropdownButton(
                isExpanded: true,
                items: (selType == "ANNU" || selType == "PERS")
                    ? oAryLVDay
                    : oAryLVDayA,
                value: selTypeDay ?? 'ALL',
                onChanged: (value) {
                  setState(() {
                    selTypeDay = value;
                  });
                },
              ),
            ),
            const Divider(),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
              margin:
                  const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: (selReason == '' || selReason == null)
                          ? Colors.red[900]!
                          : Colors.yellow[600]!,
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      style: BorderStyle.solid),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 1,
                        color: (selReason == '' || selReason == null)
                            ? Colors.red.withOpacity(0.1)
                            : Colors.yellow.withOpacity(0.1),
                        spreadRadius: 0)
                  ]),
              child: DropdownButton(
                isExpanded: true,
                items: loadReason(),
                value: selReason,
                onChanged: (value) {
                  setState(() {
                    selReason = value;
                    // print('$selReason | $value');
                  });
                },
              ),
            ),
            const Divider(),
            ((selectDate.year > 2000) &&
                    (selType != '' && selType != null) &&
                    (selTypeDay != '' && selTypeDay != null) &&
                    (selReason != '' && selReason != null))
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        // primary: Colors.green,
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.normal),
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 35, right: 35)),
                    onPressed: () async {
                      if ((selectDate.year > 2000) &&
                          (selType != '' && selType != null) &&
                          (selTypeDay != '' && selTypeDay != null) &&
                          (selReason != '' && selReason != null)) {
                        String strFrom = "", strTo = "";
                        if (selTypeDay == "ALL") {
                          strFrom = "08:00";
                          strTo = "17:45";
                        } else if (selTypeDay == "HALF1") {
                          strFrom = "08:00";
                          strTo = "12:00";
                        } else if (selTypeDay == "HALF2") {
                          strFrom = "13:00";
                          strTo = "17:45";
                        }

                        String strReason = "";
                        if (selReason == "ANNU01") {
                          strReason = 'ลาพักร้อน';
                        } else if (selReason == "ANNU02") {
                          strReason = 'เหตุจากระบบตั้งครรภ์(หญิงมีครรภ์)';
                        } else if (selReason == "ANNU03") {
                          strReason = 'ประสบอุบัติเหตุ(ปฏิบัติงานได้)';
                        } else if (selReason == "ANNU04") {
                          strReason =
                              'สงสัยติดเชื้อหรือเข้าข่ายอาจติดเชื้อ (Covid-19)';
                        } else if (selReason == "SICK01") {
                          strReason = 'ไม่สบาย มีไข้';
                        } else if (selReason == "SICK02") {
                          strReason = 'ท้องเสีย ปวดท้อง';
                        } else if (selReason == "SICK03") {
                          strReason = 'ประสบอุบัติเหตุ';
                        } else if (selReason == "SICK04") {
                          strReason = 'กล้ามเนื้ออักเสบ';
                        } else if (selReason == "SICK05") {
                          strReason = 'ผ่าตัด';
                        } else if (selReason == "SICK06") {
                          strReason = 'ป่วยตามโรคประจำตัว';
                        } else if (selReason == "MARR") {
                          strReason = 'ลาแต่งงาน';
                        } else if (selReason == "CARE") {
                          strReason = 'ลาเพื่อดูแลภรรยาคลอดบุตร';
                        } else if (selReason == "STER") {
                          strReason = 'ลาทำหมัน';
                        } else if (selReason == "FUNE") {
                          strReason = 'ลางานศพ';
                        } else if (selReason == "PERS01") {
                          strReason = 'ติดต่อหน่วยงานราชการ';
                        } else if (selReason == "PERS02") {
                          strReason = 'ทำธุระส่วนตัว';
                        } else if (selReason == "PERS03") {
                          strReason = 'ดูแลคนในครอบครัว';
                        } else if (selReason == "PERS04") {
                          strReason = 'รถเสีย';
                        } else if (selReason == "PERS05") {
                          strReason = 'กลับต่างจังหวัด';
                        } else if (selReason == "PERS06") {
                          strReason = 'ปัญหาการจราจร';
                        }

                        // print('----------------------------------------------');
                        // print(
                        //     '$selectDate, $selType, $strFrom, $strTo, $strReason');
                        // print('----------------------------------------------');
                        if (selType == "ANNU") {
                          if (await checkLV(selectDate, selType!, strFrom,
                              strTo, strReason)) {
                            requestLV(selectDate, selType!, strFrom, strTo,
                                strReason);
                          }
                        } else {
                          requestLV(
                              selectDate, selType!, strFrom, strTo, strReason);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('กรุณากรอกข้อมูลให้ครบ'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(30),
                          ),
                        );
                      }
                    },
                    icon: const Icon(FontAwesomeIcons.circleCheck),
                    label: const Text('บันทึกการลางาน'))
                : const Text('')
          ],
        ));
  }
}
