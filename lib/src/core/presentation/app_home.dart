import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/features4/presentation/screen4/home_screen.dart';
import 'package:meetkoch/src/features/features5/presentation/setting_screen.dart';
import 'package:meetkoch/src/features/features6/presentation/pp_screen.dart';
import 'package:meetkoch/src/features/features3/presentation/auftrag_screen.dart';

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
    const PPScreen(),
    const AuftragScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        indicatorColor: Color.fromARGB(255, 121, 76, 100),
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Setting'),
          NavigationDestination(icon: Icon(Icons.person), label: 'pppp'),
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
