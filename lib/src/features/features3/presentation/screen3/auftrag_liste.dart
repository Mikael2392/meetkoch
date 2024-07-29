import 'package:flutter/material.dart';

class AuftraegeListe extends StatelessWidget {
  const AuftraegeListe({super.key});

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
      {
        "name": "Hotel Randolph",
        "city": "Köln,50674",
        "description": "BBQ Event mit Food Stationen",
        "image": "assets/hotel_randolph.png"
      },
      {
        "name": "Tabitha Potter",
        "city": "Düsseldorf,xxxx",
        "description":
            "Wir Suchen am 08.12: 5 koch/Küchenhilfe au der Messe 15:00-22:30...",
        "image": "assets/tabitha_potter.png"
      },
      {
        "name": "Restaurant Jakobsen",
        "city": "Köln,50115",
        "description": "Wir Brauchen Ab 01.05 noch 1 Koch ..",
        "image": "assets/restaurant_jakobsen.png"
      },
      {
        "name": "Andrew Parker",
        "city": "Berlin,10115",
        "description": "Wir Brauchen Ab 01.05 noch 1 Koch ..",
        "image": "assets/andrew_parker.png"
      },
      {
        "name": "Maisy Humphrey",
        "city": "Köln,50674",
        "description": "BBQ Event mit Food Stationen",
        "image": "assets/maisy_humphrey.png"
      },
      {
        "name": "Kieron Dotson",
        "city": "Berlin,10115",
        "description": "Wir Brauchen Ab 01.05 noch 1 Koch ..",
        "image": "assets/kieron_dotson.png"
      },
      {
        "name": "Martha Craig",
        "city": "Berlin,10115",
        "description": "Wir Brauchen Ab 01.05 noch 1 Koch ..",
        "image": "assets/martha_craig.png"
      },
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: auftraege.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(auftraege[index]["image"] as String),
            ),
            title: Text(auftraege[index]["name"] as String),
            tileColor: Color.fromARGB(255, 204, 154, 180),
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
          );
        },
      ),
    );
  }
}
