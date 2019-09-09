import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tier_list_app/api_config.dart';

class CreateTierListPanel extends StatefulWidget {
  @override
  _CreateTierListPanelState createState() => _CreateTierListPanelState();
}

class _CreateTierListPanelState extends State<CreateTierListPanel> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageSourceController = TextEditingController();

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
              controller: titleController,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: "Description",
              ),
              controller: descriptionController,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: "Image Source",
              ),
              controller: imageSourceController,
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

  void validate(BuildContext context) async {
    try {
      final title = titleController.text.trim();
      final description = descriptionController.text.trim();
      final imageSource = imageSourceController.text.trim();

      if (title.length == 0) return;

      final body = {'title': title};

      if (description.length > 0) {
        body['description'] = description;
      }

      if (imageSource.length > 0) {
        body['imageSource'] = imageSource;
      }

      final res = await http
          .post(
            '$apiUrl/tierlists',
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 5));

      Navigator.pop(context);
    } on TimeoutException {
      debugPrint("Timeout on POST");
    }
  }
}
