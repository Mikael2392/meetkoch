import 'package:flutter/material.dart';

class ListViewExercise extends StatelessWidget {
  const ListViewExercise({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {"name": "Döner Kebab", "price": 8},
      {"name": "Döner Teller", "price": 10},
      {"name": "Döner Box", "price": 7},
      {"name": "Döner Dürüm", "price": 8},
      {"name": "Vegetarischer Döner", "price": 7},
      {"name": "Döner mit Schafskäse", "price": 9},
      {"name": "Lahmacun Döner", "price": 9},
      {"name": "Hähnchen Döner", "price": 8},
      {"name": "Lamm Döner", "price": 12},
      {"name": "Döner Kebab", "price": 8},
      {"name": "Döner Teller", "price": 10},
      {"name": "Döner Box", "price": 7},
      {"name": "Döner Dürüm", "price": 8},
      {"name": "Vegetarischer Döner", "price": 7},
      {"name": "Döner mit Schafskäse", "price": 9},
      {"name": "Lahmacun Döner", "price": 9},
      {"name": "Hähnchen Döner", "price": 8},
      {"name": "Lamm Döner", "price": 12},
      {"name": "Falafel Döner", "price": 7},
      {"name": "Döner Salat", "price": 6},
      {"name": "Döner Combo", "price": 11}
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Product List"),
        ),
        body: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.blue),
              title: Text(products[index]["name"] as String),
              trailing: Text("\$${products[index]["price"]}"),
              tileColor: index % 2 == 0 ? Colors.grey[200] : Colors.white,
              dense: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${products[index]["name"]} tapped!"),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
