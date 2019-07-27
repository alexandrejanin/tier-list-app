import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tier_list_app/api_config.dart' as apiConfig;
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
      var response = await http
          .get(apiConfig.apiUrl + "tierlists")
          .timeout(const Duration(seconds: 3));
      debugPrint(response.body);

      var responseData = json.decode(response.body);

      if (responseData['success']) {
        _homeTierLists = List<Map<String, dynamic>>.from(responseData['result'])
            .map((tierListMap) => TierList.fromJson(tierListMap))
            .toList();
      }
      debugPrint("Loading successful");
    } on TimeoutException catch (e) {
      debugPrint("Timeout!");
      debugPrint(e.toString());
    } on SocketException catch (e) {
      debugPrint("SocketException!");
      debugPrint(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
      debugPrint("Loading finished");
    }
  }

  List<TierList> defaultTierLists() {
    return [
      TierList(
        "Films de Tarantino",
        imageSource:
            "https://www.quentintarantinofanclub.com/upload/img/09201722195344-book-quentin-tarantino-a-retrospective.jpg",
      ),
      TierList(
        "Films du MCU",
        imageSource:
            "https://ksassets.timeincuk.net/wp/uploads/sites/55/2019/04/Payoff_1-Sht_Online_v6_Domestic_Sm-1-e1552570783683.jpg",
      ),
      TierList(
        "Films ayant gagné un Oscar du meilleur film",
        imageSource:
            "https://www.goldderby.com/wp-content/uploads/2017/12/Oscar-statuette-trophy-atmo.png",
      ),
      TierList(
        "Morceaux de Dans la légende",
        imageSource:
            "https://images.genius.com/adf6cea1deac12e134b2b241b9e16f8e.1000x1000x1.jpg",
      ),
    ];
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
        actions: <Widget>[
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
                  title: "Tendances",
                  tierLists: _homeTierLists,
                ),
                HomeRow(
                  title: "Mes Tier Lists",
                  tierLists: defaultTierLists(),
                ),
                HomeRow(
                  title: "Tier Lists de mes amis",
                  tierLists: defaultTierLists(),
                ),
                HomeRow(
                  title: "Tier Lists que j'aime",
                  tierLists: defaultTierLists(),
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) => TierListTile(
              tierList: tierLists[i % tierLists.length],
            ),
          ),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: tierList.imageSource != null
                  ? Image(
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      image: NetworkImage(tierList.imageSource),
                    )
                  : Container(width: size, height: size),
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
