import 'package:flutter/material.dart';

class TierList {
  String name;
  String description;
  String imageUrl;
  final List<Tier> tiers;

  TierList(this.name, {this.description, this.imageUrl, this.tiers});
}

class Tier {
  String name;
  String description;
  Color color;
  final List<TierListItem> items;

  Tier(this.name, {this.description, this.color, this.items});
}

class TierListItem {
  String name;
  String description;
  String imageUrl;

  TierListItem(this.name, {this.description, this.imageUrl});
}
