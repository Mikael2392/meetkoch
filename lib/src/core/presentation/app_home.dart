import 'package:flutter/material.dart';
// Fix #2/#3: Import ohne Leerzeichen im Dateinamen
import 'package:meetkoch/src/features/Neuer_Auftrag/presentation/ArbeitsgeberAuftragListe.dart'
    as employer_auftrag;
import 'package:meetkoch/src/features/Home/presentation/home_screen.dart';
import 'package:meetkoch/src/features/Setting/presentation/setting_screen.dart';
import 'package:meetkoch/src/features/auftrag_liste/presentation/auftrag_liste.dart'
    as freelancer_auftrag;

class AppHome extends StatefulWidget {
  final String role;

  const AppHome({super.key, required this.role});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  int currentIndex = 0;

  late final List<Widget> freelancerScreens;
  late final List<Widget> employerScreens;

  @override
  void initState() {
    super.initState();

    freelancerScreens = [
      const HomeScreen(),
      const SettingScreen(),
      const freelancer_auftrag.AuftraegeListe(),
    ];

    employerScreens = [
      const HomeScreen(),
      const SettingScreen(),
      const employer_auftrag.ArbeitsgeberAuftragListe(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens =
        widget.role == 'freelancer' ? freelancerScreens : employerScreens;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 121, 76, 100),
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.settings), label: 'Einstellungen'),
          NavigationDestination(
              icon: Icon(Icons.ad_units_outlined), label: 'Meine Aufträge'),
        ],
      ),
      body: Center(
        child: screens[currentIndex],
      ),
    );
  }
}
