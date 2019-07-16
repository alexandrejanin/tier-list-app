import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tier_list_app/tier_list.dart';
import 'package:tier_list_app/tier_list_view.dart';

class HomeFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        HomeRow(
          title: "Tendances",
          tierLists: [
            TierList(
              "Films du MCU",
              imageUrl:
                  "https://ksassets.timeincuk.net/wp/uploads/sites/55/2019/04/Payoff_1-Sht_Online_v6_Domestic_Sm-1-e1552570783683.jpg",
              description: "Films du Marvel Cinematic Universe",
              tiers: [
                Tier(
                  "S",
                  color: Colors.cyanAccent,
                  items: [
                    TierListItem(
                      "Dr. Strange",
                      imageUrl:
                          "https://images-na.ssl-images-amazon.com/images/I/51TlojgQWuL.jpg",
                    ),
                    TierListItem(
                      "Dr. Strange",
                      imageUrl:
                          "https://images-na.ssl-images-amazon.com/images/I/51TlojgQWuL.jpg",
                    ),
                    TierListItem(
                      "Dr. Strange",
                      imageUrl:
                          "https://images-na.ssl-images-amazon.com/images/I/51TlojgQWuL.jpg",
                    ),
                    TierListItem(
                      "Dr. Strange",
                      imageUrl:
                          "https://images-na.ssl-images-amazon.com/images/I/51TlojgQWuL.jpg",
                    ),
                    TierListItem(
                      "Dr. Strange",
                      imageUrl:
                          "https://images-na.ssl-images-amazon.com/images/I/51TlojgQWuL.jpg",
                    ),
                    TierListItem(
                      "Endgame",
                      imageUrl:
                          "https://ksassets.timeincuk.net/wp/uploads/sites/55/2019/04/Payoff_1-Sht_Online_v6_Domestic_Sm-1-e1552570783683.jpg",
                    ),
                  ],
                ),
                Tier(
                  "A",
                  color: Colors.green,
                  items: [
                    TierListItem(
                      "Spiderman: Far From Home",
                      imageUrl:
                          "https://vignette.wikia.nocookie.net/marvelcinematicuniverse/images/3/35/Official_FFH_US_Poster.jpg",
                    ),
                  ],
                ),
                Tier(
                  "B",
                  color: Colors.lightGreenAccent,
                ),
                Tier(
                  "Long nom de tier!",
                  color: Colors.yellow,
                ),
                Tier(
                  "D+",
                  color: Colors.orange,
                ),
                Tier(
                  "D",
                  color: Colors.orange,
                ),
                Tier(
                  "D-",
                  color: Colors.orange,
                ),
              ],
            ),
            TierList(
              "Morceaux de Dans la légende",
              imageUrl:
                  "https://images.genius.com/adf6cea1deac12e134b2b241b9e16f8e.1000x1000x1.jpg",
              description: "Morceaux de l'album Dans la Légende de PNL",
              tiers: [],
            ),
          ],
        ),
        HomeRow(
          title: "Mes Tier Lists",
          tierLists: [
            TierList(
              "Films de Tarantino",
              imageUrl:
                  "https://www.quentintarantinofanclub.com/upload/img/09201722195344-book-quentin-tarantino-a-retrospective.jpg",
            ),
            TierList(
              "Films du MCU",
              imageUrl:
                  "https://ksassets.timeincuk.net/wp/uploads/sites/55/2019/04/Payoff_1-Sht_Online_v6_Domestic_Sm-1-e1552570783683.jpg",
            ),
            TierList(
              "Films ayant gagné un Oscar du meilleur film",
              imageUrl:
                  "https://www.goldderby.com/wp-content/uploads/2017/12/Oscar-statuette-trophy-atmo.png",
            ),
            TierList(
              "Morceaux de Dans la légende",
              imageUrl:
                  "https://images.genius.com/adf6cea1deac12e134b2b241b9e16f8e.1000x1000x1.jpg",
            ),
          ],
        ),
        HomeRow(
          title: "Tier Lists de mes amis",
          tierLists: [
            TierList(
              "Films de Tarantino",
              imageUrl:
                  "https://www.quentintarantinofanclub.com/upload/img/09201722195344-book-quentin-tarantino-a-retrospective.jpg",
            ),
            TierList(
              "Films du MCU",
              imageUrl:
                  "https://ksassets.timeincuk.net/wp/uploads/sites/55/2019/04/Payoff_1-Sht_Online_v6_Domestic_Sm-1-e1552570783683.jpg",
            ),
            TierList(
              "Films ayant gagné un Oscar du meilleur film",
              imageUrl:
                  "https://www.goldderby.com/wp-content/uploads/2017/12/Oscar-statuette-trophy-atmo.png",
            ),
            TierList(
              "Morceaux de Dans la légende",
              imageUrl:
                  "https://images.genius.com/adf6cea1deac12e134b2b241b9e16f8e.1000x1000x1.jpg",
            ),
          ],
        ),
      ],
    );
  }
}

class HomeRow extends StatelessWidget {
  final random = Random();
  final tierLists;
  final title;

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
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ),
        Container(
          height: HomeTierList.size + 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) => HomeTierList(
              tierList: tierLists[i % tierLists.length],
            ),
          ),
        ),
      ],
    );
  }
}

class HomeTierList extends StatelessWidget {
  final TierList tierList;
  static const size = 180.0;

  HomeTierList({this.tierList});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TierListView(
              tierList: tierList,
            ),
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                width: size,
                height: size,
                fit: BoxFit.cover,
                image: NetworkImage(
                  tierList.imageUrl,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 8.0),
              width: size,
              alignment: Alignment.center,
              child: Text(
                tierList.name,
                style: TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
