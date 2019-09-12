import 'package:flutter/material.dart';

class TierList {
  final String id;
  String title;
  String description;
  String imageSource;
  List<Tier> tiers;

  TierList(this.title,
      {this.id, this.description, this.imageSource, this.tiers});

  TierList.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        imageSource = json['imagesource'],
        tiers = List<Map<String, dynamic>>.from(json['tiers'])
            .map<Tier>((tierMap) => Tier.fromJson(tierMap))
            .toList();

  void updateFromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    imageSource = json['imagesource'];
    tiers = List<Map<String, dynamic>>.from(json['tiers'])
        .map<Tier>((tierMap) => Tier.fromJson(tierMap))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imageSource': imageSource,
        'tiers': tiers.map((tier) => tier.toJson()).toList(),
      };
}

class Tier {
  String title;
  String description;
  Color color;
  final List<Item> items;

  Tier(this.title, {this.description, this.color, this.items});

  Tier.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        color = Color(int.parse(json['color'].replaceFirst("#", "0xFF"))),
        items = List<Map<String, dynamic>>.from(json['items'])
            .map((Map<String, dynamic> itemMap) => Item.fromJson(itemMap))
            .toList();

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'color': color.value.toRadixString(16).replaceFirst('ff', '#'),
        'items': items.map((item) => item.toJson()).toList(),
      };
}

class Item {
  String title;
  String description;
  String imageSource;

  bool get hasImage => imageSource != null && imageSource.isNotEmpty;

  Item(this.title, {this.description, this.imageSource});

  Item.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        imageSource = json['imageSource'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'imageSource': imageSource,
      };
}
