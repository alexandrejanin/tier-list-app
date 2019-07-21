import 'package:flutter/material.dart';

class TierList {
  final String id;
  String title;
  String description;
  String imageSource;
  final List<Tier> tiers;

  TierList(this.title,
      {this.id, this.description, this.imageSource, this.tiers});

  TierList.fromJson(Map<String, dynamic> tierListMap)
      : id = tierListMap['id'],
        title = tierListMap['title'],
        description = tierListMap['description'],
        imageSource = tierListMap['imagesource'],
        tiers = List<Map<String, dynamic>>.from(tierListMap['tiers'])
            .map<Tier>((tierMap) => Tier.fromJson(tierMap))
            .toList();
}

class Tier {
  String title;
  String description;
  Color color;
  final List<Item> items;

  Tier(this.title, {this.description, this.color, this.items});

  Tier.fromJson(Map<String, dynamic> tierMap)
      : title = tierMap['title'],
        description = tierMap['description'],
        color = Color(int.parse(tierMap['color'].replaceAll("#", "0xFF"))),
        items = List<Map<String, dynamic>>.from(tierMap['items'])
            .map((Map<String, dynamic> itemMap) => Item.fromJson(itemMap))
            .toList();
}

class Item {
  String title;
  String description;
  String imageSource;

  Item(this.title, {this.description, this.imageSource});

  Item.fromJson(Map<String, dynamic> itemMap)
      : title = itemMap['title'],
        description = itemMap['description'],
        imageSource = itemMap['imageSource'];
}
