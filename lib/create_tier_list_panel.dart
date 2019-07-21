import 'package:flutter/material.dart';

class CreateTierListPanel extends StatelessWidget {
  void validate(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Créer une nouvelle Tier List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Title",
              ),
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: "Description",
              ),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => validate(context),
        child: Icon(Icons.check),
        tooltip: "Valider",
      ),
    );
  }
}
