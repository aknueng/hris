import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/components/login.dart';
import 'package:hris/components/lvrecord.dart';
import 'package:hris/components/medical.dart';
import 'package:hris/components/otrecord.dart';
import 'package:hris/models/md_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HRIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 6, 85, 222)),
        // brightness: Brightness.light,
        // primaryColor: Colors.blueAccent[700],
        // // font
        // fontFamily: 'Georgia',
      ),
      initialRoute: '/',
      routes: {
        '/ot': (context) => const OTRecordScreen(),
        '/lv': (context) => const LeaveScreen(),
        '/med': (context) => const MedicalScreen(),
        '/login': (context) => const LogInScreen(),
      },
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<MainMenu> oAryMenu = [
    MainMenu(FontAwesomeIcons.clock, 'ตรวจสอบโอที', 'OT CHECK', 'OT'),
    MainMenu(FontAwesomeIcons.personSkiing, 'วันลาพักร้อน', 'HOLIDAY', 'HOL'),
    MainMenu(
        FontAwesomeIcons.briefcaseMedical, 'ค่ารักษาพยาบาล', 'MEDICAL', 'MED'),
    MainMenu(FontAwesomeIcons.userSlash, 'ขาด ลา มาสาย', 'LEAV RECORD', 'LV'),
    MainMenu(FontAwesomeIcons.moneyBillTrendUp, 'สลิปเงินเดือน', 'E-PAY SLIP',
        'SLIP')
  ];

  void loadScreen(String selectedScreen) {
    if (selectedScreen == 'OT') {
      Navigator.pushNamed(context, '/ot');
    } else if (selectedScreen == 'HOL') {
    } else if (selectedScreen == 'MED') {
      Navigator.pushNamed(context, '/med');
    } else if (selectedScreen == 'LV') {
      Navigator.pushNamed(context, '/lv');
    } else if (selectedScreen == 'SLIP') {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styleBody = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('HRIS'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
      ),
      body: ListView.builder(
          itemCount: oAryMenu.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: theme.colorScheme.inversePrimary,
              margin: const EdgeInsets.all(5),
              child: ListTile(
                leading: Icon(
                  oAryMenu[index].mnIcon,
                  color: theme.colorScheme.surface,
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
          }),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'http://dcidmc.dci.daikin.co.jp/PICTURE/40865.jpg',
                  ),
                  backgroundColor: Colors.white,
                ),
                accountName: Text('Aukit Karoon'),
                accountEmail: Text('aukit14@gmail.com')),
            const Divider(),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                child: ListTile(
                  tileColor: Colors.blueAccent,
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const Icon(FontAwesomeIcons.rightFromBracket,
                      color: Colors.white),
                  title: const Text(
                    'LOG OUT',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    //Navigator.of(context).pop();
                    setState(() {});
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
