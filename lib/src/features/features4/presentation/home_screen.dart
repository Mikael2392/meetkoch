import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/features7/presentation/detailScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auftraege = [
      {
        "name": "Hotel Randolph",
        "city": "Köln,50674",
        "description": "BBQ Event mit Food Stationen",
        "image": "assets/hotel_randolph.png"
      },
      {
        "name": "Martha Craig",
        "city": "Berlin,10115",
        "description": "Wir Brauchen Ab 01.05 noch 1 Koch ..",
        "image": "assets/martha_craig.png"
      },
      // Weitere Einträge ...
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
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
                  builder: (context) => DetailScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
