import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 图片请求需要带上请求头 否则概率403
class NeteaseCacheImage extends StatelessWidget {
  final String picUrl;
  Size? size;

  NeteaseCacheImage({
    super.key,
    required this.picUrl,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
        image: CachedNetworkImageProvider(
          picUrl,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Referer': 'https://music.163.com',
          },
        ),
        height: size?.height,
        width: size?.width,
        fit: BoxFit.cover,
        color: Colors.black.withOpacity(0.3),
        colorBlendMode: BlendMode.colorBurn,
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            'https://placehold.it/100x100',
            fit: BoxFit.cover,
          );
        });
  }
}
