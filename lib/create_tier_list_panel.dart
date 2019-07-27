import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tier_list_app/api_config.dart';

class CreateTierListPanel extends StatelessWidget {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  void validate(BuildContext context, String title, String description) async {
    try {
      await http
          .post(
            apiUrl + "tierlists",
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'title': title, 'description': description}),
          )
          .timeout(const Duration(seconds: 3));

      Navigator.pop(context);
    } on TimeoutException catch (e) {
      debugPrint("Timeout!");
      debugPrint(e.toString());
    } on SocketException catch (e) {
      debugPrint("SocketException!");
      debugPrint(e.toString());
    }
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
              controller: titleController,
              style: TextStyle(
                fontSize: 24,
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => validate(
          context,
          titleController.text,
          descriptionController.text,
        ),
        child: Icon(Icons.check),
        tooltip: "Valider",
      ),
    );
  }
}
