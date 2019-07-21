import 'package:flutter/material.dart';
import 'package:tier_list_app/create_tier_list_panel.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.deepPurpleAccent,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  void createTierList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTierListPanel(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text("Test"),
            ),
            ListTile(
              title: Text(
                "Mon Compte",
              ),
            ),
            ListTile(
              title: Text(
                "Mes Amis",
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Tier Lists"),
      ),
      body: HomeFeed(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createTierList(context),
        child: Icon(Icons.add),
        tooltip: "Créer une nouvelle Tier List",
      ),
    );
  }
}
