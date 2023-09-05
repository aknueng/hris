import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/models/md_account.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LVRequestScreen extends StatefulWidget {
  const LVRequestScreen({super.key});

  @override
  State<LVRequestScreen> createState() => _LVRequestScreenState();
}

class _LVRequestScreenState extends State<LVRequestScreen> {
  //Future<List<MOtInfo>>? oAryOT;
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;

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
        value: 'HALF2', child: Text('ลาครึ่งวันเช้า')),
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

  String? selDate;
  String? selType;
  String? selTypeDay;
  String? selReason;

  DateTime selectDate = DateTime.now();
  DateFormat formatYMD = DateFormat("yyyyMMdd");

  void fnShowDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(DateTime.now().year),
            lastDate:
                DateTime(DateTime.now().add(const Duration(days: 20)).year))
        .then((value) {
      setState(() {
        selectDate = value!;
      });
    });
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
            DropdownButton(
              items: oAryLVType,
              value: selType ?? '',
              onChanged: (value) {
                setState(() {
                  if (value != '') {
                    selType = value;
                    selTypeDay = 'ALL';
                  }
                });
              },
            ),
            Text(formatYMD.format(selectDate)),
            ElevatedButton.icon(
                onPressed: () {
                  fnShowDatePicker;
                },
                icon: const Icon(Icons.date_range),
                label: const Text('datet')),
            DropdownButton(
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
            DropdownButton(
              items: loadReason(),
              value: selReason,
              onChanged: (value) {
                setState(() {
                  selReason = value;
                });
              },
            ),
          ],
        ));
  }

  List<DropdownMenuItem> loadReason() {
    if (selType == "ANNU") {
      setState(() {
        selReason = 'ANNU01';
      });
      return oAryReasonAnnu;
    } else if (selType == "PERS") {
      setState(() {
        selReason = '';
      });
      return oAryReasonPers;
    } else if (selType == "SICK") {
      setState(() {
        selReason = '';
      });
      return oAryReasonSick;
    } else if (selType == "") {
      setState(() {
        selReason = '';
      });
      return oAryReasonAnnu;
    } else {
      setState(() {
        selReason = selType;
      });
      return oAryReasonOTH;
    }
  }
}
