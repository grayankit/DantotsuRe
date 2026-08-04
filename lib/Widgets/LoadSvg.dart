import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget loadSvg(
  String assetPath, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  Color? color,
}) {
  final isSvg = assetPath.toLowerCase().endsWith('.svg');

  if (isSvg) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  return Image.asset(assetPath, width: width, height: height, fit: fit);
}
