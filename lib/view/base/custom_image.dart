import 'package:cached_network_image/cached_network_image.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  final bool? isLowImage;
  const CustomImage(
      {Key? key,
      required this.image,
      this.height,
      this.width,
      this.fit = BoxFit.cover,
      this.isNotification = false,
      this.placeholder = '',
      this.isLowImage = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: isLowImage! ? 300 : null,
      memCacheHeight: isLowImage! ? 300 : null,
      maxHeightDiskCache: isLowImage! ? 200 : null,
      maxWidthDiskCache: isLowImage! ? 200 : null,
      placeholder: (context, url) => Image.asset(
          placeholder.isNotEmpty
              ? placeholder
              : isNotification
                  ? Images.notificationPlaceholder
                  : Images.placeholder,
          height: height,
          width: width,
          fit: fit),
      errorWidget: (context, url, error) => Image.asset(
          placeholder.isNotEmpty
              ? placeholder
              : isNotification
                  ? Images.notificationPlaceholder
                  : Images.placeholder,
          height: height,
          width: width,
          fit: fit),
    );
  }
}
