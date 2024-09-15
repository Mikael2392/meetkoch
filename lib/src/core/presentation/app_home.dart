import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/Neuer_Auftrag/presentation/neuer_auftrag.dart';
import 'package:meetkoch/src/features/Home/presentation/home_screen.dart';
import 'package:meetkoch/src/features/Setting/presentation/setting_screen.dart';

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const SettingScreen(),
    const ArbeitsgeberAuftragListe(),
  ];
  @override
  Widget build(BuildContext context) {
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
              icon: Icon(Icons.ad_units_outlined), label: 'Mein Aufträger'),
        ],
      ),
      body: Center(
        child: screens[currentIndex],
      ),
    );
  }
}
