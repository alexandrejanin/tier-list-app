import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tier_list_app/api_config.dart';
import 'package:tier_list_app/loading_image.dart';
import 'package:tier_list_app/tier_list.dart';
import 'package:tier_list_app/tier_list_view.dart';
import 'package:tier_list_app/create_tier_list_panel.dart';

class HomeFeed extends StatefulWidget {
  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  bool _loading = false;
  List<TierList> _homeTierLists = [];

  @override
  void initState() {
    super.initState();
    getTierLists();
  }

  void createTierList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTierListPanel(),
      ),
    );
  }

  void getTierLists() async {
    setState(() {
      _loading = true;
    });

    try {
      final res = await http
          .get('$apiUrl/tierlists')
          .timeout(const Duration(seconds: 5));

      var responseData = json.decode(res.body);

      if (responseData['success']) {
        _homeTierLists = List<Map<String, dynamic>>.from(responseData['result'])
            .map((tierListMap) => TierList.fromJson(tierListMap))
            .toList();
      }
      debugPrint("${_homeTierLists.length} tierlists loaded");
    } on TimeoutException {
      debugPrint("Timeout on GET");
    } finally {
      setState(() {
        _loading = false;
      });
      debugPrint("Loading finished");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(child: Text("Test")),
            ListTile(title: Text("Mon Compte")),
            ListTile(title: Text("Mes Amis")),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Tier Lists"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: getTierLists,
          )
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                HomeRow(
                  title: "Mes Tier Lists",
                  tierLists: _homeTierLists,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createTierList(context),
        child: Icon(Icons.add),
        tooltip: "Créer une nouvelle Tier List",
      ),
    );
  }
}

class HomeRow extends StatelessWidget {
  final Random random = Random();
  final List<TierList> tierLists;
  final String title;

  HomeRow({this.title, this.tierLists});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(fontSize: 24),
          ),
        ),
        Container(
          height: TierListTile.size + 50,
          child: this.tierLists.length > 0
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) => TierListTile(
                        tierList: tierLists[i % tierLists.length],
                      ))
              : Center(child: Text("No tier lists found")),
        ),
      ],
    );
  }
}

class TierListTile extends StatelessWidget {
  final TierList tierList;
  static const size = 180.0;

  TierListTile({this.tierList});

  void openTierList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TierListView(tierList: tierList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => openTierList(context),
        child: Column(
          children: [
            LoadingImage(
              width: size,
              height: size,
              url: tierList.imageSource,
              borderRadius: 20,
              placeholder: Icon(
                Icons.view_list,
                size: size,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 8.0),
              width: size,
              alignment: Alignment.center,
              child: Text(
                tierList.title,
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
