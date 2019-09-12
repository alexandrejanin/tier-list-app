import 'dart:math';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class LoadingImage extends StatefulWidget {
  final double width;
  final double height;
  final String url;
  final Widget placeholder;
  final double borderRadius;

  bool get validUrl => url != null && url.isNotEmpty;

  const LoadingImage({
    Key key,
    this.width,
    this.height,
    this.url,
    this.placeholder,
    this.borderRadius,
  }) : super(key: key);

  @override
  _LoadingImageState createState() => _LoadingImageState();
}

class _LoadingImageState extends State<LoadingImage> {
  bool loaded = false;
  NetworkImage image;

  @override
  void initState() {
    super.initState();
    if (widget.validUrl) {
      image = NetworkImage(widget.url);
      image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((i, b) {
        if (mounted) {
          setState(() {
            loaded = true;
          });
        }
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.validUrl) {
      return widget.placeholder;
    }
    return Stack(
      children: [
        if (!loaded)
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Padding(
              padding: EdgeInsets.all(min(widget.width, widget.height) / 3),
              child: CircularProgressIndicator(),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: FadeInImage(
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            image: image,
            placeholder: MemoryImage(kTransparentImage),
            fadeInDuration: const Duration(milliseconds: 100),
          ),
        ),
      ],
    );
  }
}
