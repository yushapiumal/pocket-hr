import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/helpers/custom_blur_hash.dart';

class GlassBoxFull extends StatelessWidget {
  final double width, height;
  final Widget child;
  final String background;

  const GlassBoxFull(
      {Key? key,
      required this.background,
      required this.width,
      required this.height,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0.0),
      child: Container(
        width: width,
        height: height,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7.0,
                sigmaY: 7.0,
              ),
              child: Container(width: width, height: height, child: Text(" ")),
            ),
            Opacity(
                opacity: 0.50,
                child: OctoImage(
                  image: CachedNetworkImageProvider(background),
                  placeholderBuilder: OctoBlurHashFix.placeHolder(
                    'LA7{HstRnNyEK-.SkDkWMJXT%zWB',
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  errorBuilder: OctoError.icon(color: HRColors.bottomColor),
                  fit: BoxFit.cover,
                )),
            Container(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
