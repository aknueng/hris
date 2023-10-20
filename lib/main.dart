import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/components/annual.dart';
import 'package:hris/components/changepassword.dart';
import 'package:hris/components/dcix_chat.dart';
import 'package:hris/components/dcix_voice.dart';
import 'package:hris/components/login.dart';
import 'package:hris/components/lvrecord.dart';
import 'package:hris/components/lvrequest.dart';
import 'package:hris/components/medical.dart';
import 'package:hris/components/otrecord.dart';
import 'package:hris/components/profile.dart';
import 'package:hris/components/slip.dart';
import 'package:hris/components/slippreview.dart';
import 'package:hris/components/trainning.dart';
import 'package:hris/components/userlist.dart';
import 'package:hris/lang/lang_th.dart';
import 'package:hris/models/md_account.dart';
import 'package:hris/models/md_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: LangTH.titleMain,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        // brightness: Brightness.light,
        // primaryColor: Colors.blueAccent[700],
        // // font
        // fontFamily: 'Georgia',
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/ot',
          page: () => const OTRecordScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/lv',
          page: () => const LeaveScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/annual',
          page: () => const AnnualScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/med',
          page: () => const MedicalScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/login',
          page: () => const LogInScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/slip',
          page: () => const SlipScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/train',
          page: () => const TrainingScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/lvreq',
          page: () => const LVRequestScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/pdf',
          page: () => const PDFPreview(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/chgpwd',
          page: () => const ChangePasswordScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/voice',
          page: () => const AIVoiceScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/chat',
          page: () => const AIChatScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/user',
          page: () => const UserListScreen(),
          transition: Transition.cupertino,
        ),
      ],
      // routes: {
      //   '/ot': (context) => const OTRecordScreen(),
      //   '/lv': (context) => const LeaveScreen(),
      //   '/annual': (context) => const AnnualScreen(),
      //   '/med': (context) => const MedicalScreen(),
      //   '/login': (context) => const LogInScreen(),
      //   '/slip': (context) => const SlipScreen(),
      //   '/train': (context) => const TrainingScreen(),
      //   '/lvreq': (context) => const LVRequestScreen(),
      //   '/pdf': (context) => const PDFPreview(),
      //   '/chgpwd': (context) => const ChangePasswordScreen(),
      //   '/profile': (context) => const ProfileScreen(),
      //   '/voice': (context) => const AIVoiceScreen(),
      //   '/chat': (context) => const AIChatScreen(),
      //   '/user': (context) => const UserListScreen(),
      // },
      home: const MainPage(),
      navigatorKey: NavigationService.navigatorKey,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  String nameEmp = '', positEmp = '', telephoneEmp = '';
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(() async {
      //if (oAccount!.code == '' || oAccount!.code == null) {
      if (oAccount == null ||
          oAccount!.code == '' ||
          oAccount!.code.isEmpty ||
          oAccount!.token == '' ||
          oAccount!.token.isEmpty) {
        // Navigator.pushNamed(context, '/login');
        Get.offAllNamed('/login');
      } else {
        setState(() {
          isInit = true;
        });
      }
    });
  }

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
          role: prefs.getString('role') ?? '',
          telephone: prefs.getString('telephone') ?? '',
          logInDate: DateTime.parse(
              prefs.getString('logInDate') ?? DateTime.now().toString()));

      nameEmp = oAccount!.fullName;
      positEmp = oAccount!.posit;
      telephoneEmp = oAccount!.telephone;
    });
  }

  List<MainMenu> oAryMenu = [
    MainMenu(FontAwesomeIcons.clock, Colors.orange, 'รายการทำโอที', 'OVERTIME',
        'OT'),
    MainMenu(FontAwesomeIcons.personSkiing, Colors.purple, 'วันลาพักร้อน',
        'ANNUAL', 'ANN'),
    MainMenu(FontAwesomeIcons.briefcaseMedical, Colors.amber, 'ค่ารักษาพยาบาล',
        'MEDICAL', 'MED'),
    MainMenu(FontAwesomeIcons.userSlash, Colors.red, 'ขาด ลา มาสาย',
        'LEAVE RECORD', 'LV'),
    MainMenu(FontAwesomeIcons.moneyBillTrendUp, Colors.green, 'สลิปเงินเดือน',
        'E-PAY SLIP', 'SLIP'),
    MainMenu(FontAwesomeIcons.bookTanakh, Colors.blue, 'ฝึกอบรม', 'TRAINING',
        'TRAIN')
  ];

  void loadScreen(String selectedScreen) {
    if (selectedScreen == 'OT') {
      // Navigator.pushNamed(context, '/ot');
      Get.offAllNamed('/ot');
    } else if (selectedScreen == 'ANN') {
      // Navigator.pushNamed(context, '/annual');
      Get.offAllNamed('/annual');
    } else if (selectedScreen == 'MED') {
      // Navigator.pushNamed(context, '/med');
      Get.offAllNamed('/med');
    } else if (selectedScreen == 'LV') {
      // Navigator.pushNamed(context, '/lv');
      Get.offAllNamed('/lv');
    } else if (selectedScreen == 'SLIP') {
      // Navigator.pushNamed(context, '/slip');
      Get.offAllNamed('/slip');
    } else if (selectedScreen == 'TRAIN') {
      // Navigator.pushNamed(context, '/train');
      Get.offAllNamed('/train');
    } else if (selectedScreen == 'LVREQ') {
      // Navigator.pushNamed(context, '/lvreq');
      Get.offAllNamed('/lvreq');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styleBody = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return WillPopScope(
      child: Scaffold(
        appBar: (isInit)
            ? AppBar(
                title: Text(LangTH.titleMain),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.surface,
              )
            : AppBar(),
        body: (isInit)
            ? ListView.builder(
                padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                itemCount: oAryMenu.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 10,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    margin: const EdgeInsets.all(7),
                    child: ListTile(
                      leading: Container(
                        height: 60,
                        width: 60,
                        color: oAryMenu[index].mColor,
                        child: Icon(
                          oAryMenu[index].mnIcon,
                          color: theme.colorScheme.surface,
                        ),
                      ),
                      title: Text(
                        oAryMenu[index].mnTitle,
                        style: styleBody,
                      ),
                      subtitle: Text(
                        oAryMenu[index].mnSubTitle,
                        style: styleBody,
                      ),
                      onTap: () {
                        loadScreen(oAryMenu[index].mnSceen);
                      },
                    ),
                  );
                })
            : const CircularProgressIndicator(),
        drawer: (isInit)
            ? SafeArea(
                child: Drawer(
                  backgroundColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      UserAccountsDrawerHeader(
                        currentAccountPicture: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://www.dci.co.th/PublishService/Picture/${oAccount!.code}.JPG',
                          ),
                          backgroundColor: Colors.white,
                        ),
                        accountName: Text(nameEmp),
                        accountEmail: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Position : $positEmp'),
                            Text('Telephone : $telephoneEmp')
                          ],
                        ),
                      ),
                      //const Divider(),
                      TextButton.icon(
                          onPressed: () {
                            // Navigator.pushNamed(context, '/profile');
                            Get.offAllNamed('/profile');
                          },
                          icon: const Icon(FontAwesomeIcons.user),
                          label: const Text('แก้ไขข้อมูลส่วนตัว (Profile)')),
                      TextButton.icon(
                          onPressed: () {
                            // Navigator.pushNamed(context, '/chgpwd');
                            Get.offAllNamed('/chgpwd');
                          },
                          icon: const Icon(Icons.key),
                          label: const Text('เปลี่ยนรหัสผ่าน')),
                      (oAccount!.role == "ADMIN")
                          ? TextButton.icon(
                              onPressed: () {
                                // Navigator.pushNamed(context, '/voice');
                                Get.offAllNamed('/voice');
                              },
                              icon: const Icon(FontAwesomeIcons.headset),
                              label: const Text('DCI X (Voice)'))
                          : const Text(''),
                      (oAccount!.role == "ADMIN")
                          ? TextButton.icon(
                              onPressed: () {
                                // Navigator.pushNamed(context, '/chat');
                                Get.offAllNamed('/chat');
                              },
                              icon: const Icon(FontAwesomeIcons.comments),
                              label: const Text('DCI X (Chat)'))
                          : const Text(''),
                      (oAccount!.role == "ADMIN")
                          ? TextButton.icon(
                              onPressed: () {
                                // Navigator.pushNamed(context, '/user');
                                Get.offAllNamed('/user');
                              },
                              icon: const Icon(FontAwesomeIcons.users),
                              label: const Text('User Control'))
                          : const Text(''),
                      Expanded(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Card(
                          child: ListTile(
                            tileColor: Colors.blueAccent,
                            titleAlignment: ListTileTitleAlignment.center,
                            leading: const Icon(
                                FontAwesomeIcons.rightFromBracket,
                                color: Colors.white),
                            title: const Text(
                              'LOG OUT',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () async {
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove('code');
                              prefs.remove('name');
                              prefs.remove('surn');
                              prefs.remove('shortName');
                              prefs.remove('fullName');
                              prefs.remove('tName');
                              prefs.remove('tSurn');
                              prefs.remove('joinDate');
                              prefs.remove('tFullName');
                              prefs.remove('posit');
                              prefs.remove('token');
                              prefs.remove('role');
                              prefs.remove('telephone');
                              prefs.remove('logInDate');
                              setState(() {
                                oAccount = MAccount(
                                    code: '',
                                    name: '',
                                    surn: '',
                                    shortName: '',
                                    fullName: '',
                                    tName: '',
                                    tSurn: '',
                                    joinDate: DateTime.now(),
                                    tFullName: '',
                                    posit: '',
                                    token: '',
                                    role: '',
                                    telephone: '',
                                    logInDate: DateTime.now());
                              });

                              if (context.mounted) {
                                // Navigator.pushNamed(context, '/login');
                                Get.offAllNamed('/login');
                              }
                            },
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
              )
            : null,
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
