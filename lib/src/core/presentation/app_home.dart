import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/Neuer_Auftrag/presentation/neuer_auftrag.dart';
import 'package:meetkoch/src/features/Home/presentation/home_screen.dart';
import 'package:meetkoch/src/features/Setting/presentation/setting_screen.dart';

import 'package:meetkoch/src/features/auftrag_liste/presentation/auftrag_liste.dart';

class AppHome extends StatefulWidget {
  final String role; // This will help to decide between freelancer or employer

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

    // Screens for Freelancers
    freelancerScreens = [
      const HomeScreen(),
      const SettingScreen(),
      const AuftraegeListe(), // Freelancer-specific screen for managing jobs
    ];

    // Screens for Employers
    employerScreens = [
      const HomeScreen(),
      const SettingScreen(),
      const ArbeitsgeberAuftragListe(), // Employer-specific screen for assigning jobs
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Use different screens based on role
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
          NavigationDestination(icon: Icon(Icons.settings), label: 'Setting'),
          NavigationDestination(
              icon: Icon(Icons.ad_units_outlined), label: 'Mein Aufträge'),
        ],
      ),
      body: Center(
        child: screens[currentIndex],
      ),
    );
  }
}
