import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Für JSON-Konvertierung
import 'package:meetkoch/src/features/Detail/presentation/detailScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> auftraege = [];

  @override
  void initState() {
    super.initState();
    _loadAuftraegeFromPreferences(); // Lade Aufträge beim Start
  }

  // Methode, um die Aufträge aus SharedPreferences zu laden
  Future<void> _loadAuftraegeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? auftraegeString = prefs.getString('auftraege');
    if (auftraegeString != null) {
      setState(() {
        auftraege = List<Map<String, String>>.from(json
            .decode(auftraegeString)
            .map((item) => Map<String, String>.from(item)));
      });
    }
  }

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
      backgroundColor: const Color(0xFF4B2F3E),
      body: ListView.separated(
        itemCount: auftraege.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey[300],
          thickness: 1,
          height: 1,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(auftraege[index]["image"] as String),
            ),
            title: Text(auftraege[index]["name"] as String),
            tileColor: const Color.fromARGB(255, 206, 157, 183),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(auftraege[index]["city"] as String),
                Text(auftraege[index]["description"] as String,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuftragDetailScreen(
                    auftrag:
                        auftraege[index], // Übergabe des ausgewählten Auftrags
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
