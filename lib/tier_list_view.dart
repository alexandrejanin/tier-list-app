import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:tier_list_app/api_config.dart';
import 'package:tier_list_app/loading_image.dart';
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
  String tierListJson;
  String jsonBeforeEdit;

  bool get unsavedChanges => tierListJson != jsonBeforeEdit;

  @override
  void initState() {
    super.initState();
    jsonBeforeEdit = json.encode(widget.tierList.toJson());
    tierListJson = jsonBeforeEdit;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build');
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tierList.title),
          actions: _getActions(),
        ),
        floatingActionButton: _getActionButton(),
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
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) {
    if (!unsavedChanges) {
      return Future.value(true);
    }
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save changes?'),
        actions: [
          FlatButton(
            child: Text('No'),
            onPressed: () {
              widget.tierList.updateFromJson(json.decode(jsonBeforeEdit));
              return Navigator.pop(context, true);
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              _updateTierList();
              return Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _getActions() {
    List<Widget> actions = [];
    if (unsavedChanges) {
      actions.add(IconButton(
        icon: Icon(Icons.check),
        onPressed: _updateTierList,
      ));
    }
    return actions;
  }

  void _updateTierList() async {
    try {
      final body = json.encode({'tierList': widget.tierList.toJson()});
      final res = await http.put(
        '$apiUrl/tierlists/${widget.tierList.id}',
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint('tierlist update success: ${jsonDecode(res.body)['success']}');
      jsonBeforeEdit = json.encode(widget.tierList.toJson());
      tierListJson = jsonBeforeEdit;
    } on TimeoutException {
      debugPrint("Timeout on PUT");
    }
  }

  void _deleteTierList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete tier list"),
          content: Text("Are you sure you want to delete this tier list?"),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("Delete"),
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
      },
    );
  }

  FloatingActionButton _getActionButton() {
    return mode == Mode.Edit
        ? FloatingActionButton(
            tooltip: "Finish Editing",
            child: Icon(Icons.check),
            onPressed: () => setState(() => mode = Mode.View),
          )
        : FloatingActionButton(
            tooltip: "Edit Mode",
            child: Icon(Icons.edit),
            onPressed: () => setState(() => mode = Mode.Edit),
          );
  }
}

class TierRow extends StatefulWidget {
  final Tier tier;
  final Mode mode;

  const TierRow({Key key, this.tier, this.mode}) : super(key: key);

  @override
  _TierRowState createState() => _TierRowState();
}

class _TierRowState extends State<TierRow> {
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
            color: widget.tier.color,
            padding: const EdgeInsets.all(8),
            child: Text(
              widget.tier.title,
              style: TextStyle(
                fontSize: widget.tier.title.length > 2 ? 14 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Tier elements
          Expanded(
            child: Container(
              color: widget.tier.color.withOpacity(.25),
              padding: const EdgeInsets.all(6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  runSpacing: 6,
                  spacing: 6,
                  runAlignment: WrapAlignment.spaceEvenly,
                  children: _getTierItems(context),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _getTierItems(BuildContext context) {
    final items = widget.tier.items
        .map((item) => TierItem(item: item, mode: widget.mode))
        .cast<Widget>()
        .toList();

    if (widget.mode == Mode.Edit) {
      items.add(
        Container(
          width: 80,
          height: 80,
          child: OutlineButton(
            child: Icon(
              Icons.add,
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AddItemDialog(
                callback: (item) => widget.tier.items.add(item),
              ),
            ),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      items.add(Container(width: TierItem.width, height: TierItem.height));
    }

    return items;
  }
}

class TierItem extends StatefulWidget {
  static const width = 80.0;
  static const height = 80.0;

  final Mode mode;
  final Item item;

  const TierItem({Key key, this.item, this.mode}) : super(key: key);

  @override
  _TierItemState createState() => _TierItemState();
}

class _TierItemState extends State<TierItem> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item.title;
    urlController.text = widget.item.imageSource;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: LoadingImage(
        width: TierItem.width,
        height: TierItem.height,
        url: widget.item.imageSource,
        borderRadius: 10,
        placeholder: Container(
          width: TierItem.width,
          height: TierItem.height,
          child: Card(
            child: Center(
              child: Text(widget.item.title),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap() {
    if (widget.mode == Mode.Edit) {
      _showItemEditDialog(context);
    } else {
      _showItemInfoDialog(context);
    }
  }

  void _showItemEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            FlatButton(
              child: Text('Update'),
              onPressed: () {
                widget.item.title = nameController.text;
                widget.item.imageSource = urlController.text;
                Navigator.pop(context);
              },
            ),
          ],
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit item'),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextFormField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'Image Source',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showItemInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.pop(context);
                _showItemEditDialog(context);
              },
            )
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  widget.item.title,
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
              Image.network(widget.item.imageSource),
            ],
          ),
        );
      },
    );
  }
}

class AddItemDialog extends StatelessWidget {
  final Function(Item) callback;
  final nameController = TextEditingController();
  final urlController = TextEditingController();

  AddItemDialog({Key key, this.callback});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        FlatButton(
          child: Text('Add'),
          onPressed: () {
            if (nameController.text.length != 0) {
              callback(Item(
                nameController.text,
                imageSource: urlController.text,
              ));

              Navigator.pop(context);
            }
          },
        ),
      ],
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add new item'),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextFormField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'Image Source',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
