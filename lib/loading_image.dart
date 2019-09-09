import 'dart:math';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class LoadingImage extends StatelessWidget {
  final double width;
  final double height;
  final String url;
  final Widget placeholder;
  final double borderRadius;

  const LoadingImage({
    Key key,
    this.width,
    this.height,
    this.url,
    this.placeholder,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return url == null || url.length == 0
        ? placeholder
        : Stack(
            children: [
              SizedBox(
                width: width,
                height: height,
                child: Padding(
                  padding: EdgeInsets.all(min(width, height) / 3),
                  child: CircularProgressIndicator(),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: FadeInImage(
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  image: NetworkImage(url),
                  placeholder: MemoryImage(kTransparentImage),
                  fadeInDuration: const Duration(milliseconds: 100),
                ),
              ),
            ],
          );
  }
}
