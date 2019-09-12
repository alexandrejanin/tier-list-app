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
  String jsonBeforeEdit;

  bool get unsavedChanges =>
      json.encode(widget.tierList.toJson()) != jsonBeforeEdit;

  @override
  void initState() {
    super.initState();
    jsonBeforeEdit = json.encode(widget.tierList.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Text(widget.tierList.title),
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => TierListInfoDialog(widget.tierList),
                ),
              ),
            ],
          ),
          actions: unsavedChanges
              ? [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: _updateTierList,
                  )
                ]
              : null,
        ),
        floatingActionButton: _getActionButton(),
        body: widget.tierList.tiers == null || widget.tierList.tiers.isEmpty
            ? Center(
                child: Text("Tier List empty!"),
              )
            : ListView(
                children: [
                  for (var tier in widget.tierList.tiers)
                    TierRow(tier: tier, mode: mode)
                ],
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
      builder: (_) => AlertDialog(
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

  void _updateTierList() async {
    try {
      final body = json.encode({'tierList': widget.tierList.toJson()});
      final res = await http.put(
        '$apiUrl/tierlists/${widget.tierList.id}',
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint('tierlist update success: ${jsonDecode(res.body)['success']}');
      setState(() {
        jsonBeforeEdit = json.encode(widget.tierList.toJson());
      });
    } on TimeoutException {
      debugPrint("Timeout on PUT");
    }
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

class TierListInfoDialog extends StatelessWidget {
  final TierList tierList;

  const TierListInfoDialog(this.tierList, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Text(tierList.title),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Navigator.pop(context);
              return showDialog(
                context: context,
                builder: (_) => DeleteTierListDialog(tierList),
              );
            },
          ),
        ],
      ),
      content: Text(tierList.description ?? ""),
    );
  }
}

class DeleteTierListDialog extends StatelessWidget {
  final TierList tierList;

  const DeleteTierListDialog(this.tierList, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              await http
                  .delete('$apiUrl/tierlists/${tierList.id}')
                  .timeout(const Duration(seconds: 5));
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
              builder: (_) => AddItemDialog(widget.tier),
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

class TierItem extends StatelessWidget {
  static const width = 80.0;
  static const height = 80.0;

  final Mode mode;
  final Item item;

  const TierItem({Key key, this.item, this.mode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) =>
            mode == Mode.Edit ? ItemEditDialog(item) : ItemInfoDialog(item),
      ),
      child: LoadingImage(
        width: TierItem.width,
        height: TierItem.height,
        url: item.imageSource,
        borderRadius: 10,
        placeholder: Container(
          width: TierItem.width,
          height: TierItem.height,
          child: Card(
            child: Center(
              child: Text(item.title),
            ),
          ),
        ),
      ),
    );
  }
}

class ItemInfoDialog extends StatelessWidget {
  final Item item;

  const ItemInfoDialog(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => ItemEditDialog(item),
            );
          },
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
          ),
          if (item.hasImage) Image.network(item.imageSource),
        ],
      ),
    );
  }
}

class ItemEditDialog extends StatefulWidget {
  final Item item;

  const ItemEditDialog(this.item, {Key key}) : super(key: key);

  @override
  _ItemEditDialogState createState() => _ItemEditDialogState();
}

class _ItemEditDialogState extends State<ItemEditDialog> {
  TextEditingController titleController;
  TextEditingController imageSourceController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.item.title);
    imageSourceController =
        TextEditingController(text: widget.item.imageSource);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        FlatButton(
          child: Text('Update'),
          onPressed: () {
            widget.item.title = titleController.text;
            widget.item.imageSource = imageSourceController.text;
            Navigator.pop(context);
          },
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Edit item'),
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextFormField(
            controller: imageSourceController,
            decoration: InputDecoration(
              labelText: 'Image Source',
            ),
          ),
        ],
      ),
    );
  }
}

class AddItemDialog extends StatelessWidget {
  final Tier tier;
  final nameController = TextEditingController();
  final urlController = TextEditingController();

  AddItemDialog(this.tier, {Key key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        FlatButton(
          child: Text('Add'),
          onPressed: () {
            if (nameController.text.length != 0) {
              tier.items.add(Item(
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
