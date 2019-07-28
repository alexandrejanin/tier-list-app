import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tier_list_app/api_config.dart';
import 'package:tier_list_app/tier_list.dart';

enum Mode { View, Edit }

class TierListView extends StatefulWidget {
  final TierList tierList;

  const TierListView({Key key, this.tierList}) : super(key: key);

  @override
  _TierListViewState createState() => _TierListViewState();
}

class _TierListViewState extends State<TierListView> {
  Mode mode = Mode.View;

  void updateTierList(BuildContext context) async {
    try {
      final res = await http.put(
        '$apiUrl/tierlists/${widget.tierList.id}',
        body: json.encode({'tierList': widget.tierList}),
      );
      debugPrint(res.body);
    } on TimeoutException {
      debugPrint("Timeout on PUT");
    }
  }

  void deleteTierList(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: new Text("Delete tier list"),
            content:
                new Text("Are you sure you want to delete this tier list?"),
            actions: [
              new FlatButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              new FlatButton(
                child: new Text("Delete"),
                onPressed: () async {
                  try {
                    final res = await http
                        .delete('$apiUrl/tierlists/${widget.tierList.id}')
                        .timeout(const Duration(seconds: 5));
                    debugPrint(res.body);
                    Navigator.pop(context);
                  } on TimeoutException {
                    debugPrint("Timeout on DELETE");
                  } finally {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }

  FloatingActionButton getActionButton() {
    switch (mode) {
      case Mode.View:
        return FloatingActionButton(
          tooltip: "Edit Mode",
          child: Icon(Icons.edit),
          onPressed: () => setState(() {
            mode = Mode.Edit;
          }),
        );
      case Mode.Edit:
        return FloatingActionButton(
          tooltip: "Finish Editing",
          child: Icon(Icons.check),
          onPressed: () => setState(() {
            mode = Mode.View;
          }),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tierList.title),
        actions: mode == Mode.Edit
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteTierList(context),
                ),
              ]
            : [],
      ),
      floatingActionButton: getActionButton(),
      body: widget.tierList.tiers != null && widget.tierList.tiers.isNotEmpty
          ? ListView(
              children: widget.tierList.tiers
                  .map((tier) => TierRow(
                        tier: tier,
                        mode: mode,
                      ))
                  .toList(),
            )
          : Center(
              child: Text("Tier List empty!"),
            ),
    );
  }
}

class TierRow extends StatelessWidget {
  final Tier tier;
  final Mode mode;

  const TierRow({Key key, this.tier, this.mode}) : super(key: key);

  List<Widget> getTierItems(BuildContext context) {
    final items = <Widget>[];

    if (tier.items != null) {
      tier.items.forEach((item) => items.add(TierItem(item: item)));
    }

    if (mode == Mode.Edit) {
      items.add(AddItemButton());
    }

    if (tier.items == null || tier.items.isEmpty) {
      items.add(Container(width: TierItem.width, height: TierItem.height));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tier name header
          Container(
            width: 60,
            alignment: Alignment.center,
            color: tier.color,
            padding: const EdgeInsets.all(8),
            child: Text(
              tier.title,
              style: TextStyle(
                fontSize: tier.title.length > 2 ? 14 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tier elements
          Expanded(
            child: Container(
              color: tier.color.withOpacity(.25),
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  runAlignment: WrapAlignment.spaceEvenly,
                  spacing: 8,
                  runSpacing: 8,
                  children: getTierItems(context),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TierItem extends StatelessWidget {
  static const width = 80.0;
  static const height = 80.0;
  final Item item;

  const TierItem({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
        },
        onLongPress: () {
          HapticFeedback.lightImpact();
        },
        child: Image(
          width: width,
          height: height,
          fit: BoxFit.cover,
          image: NetworkImage(
            item.imageSource != null ? item.imageSource : "",
          ),
        ),
      ),
    );
  }
}

class AddItemButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      child: OutlineButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: () {},
      ),
    );
  }
}
