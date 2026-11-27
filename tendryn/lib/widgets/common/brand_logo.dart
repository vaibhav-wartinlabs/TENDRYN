import 'package:flutter/material.dart';

/// The official Tendryn logo (symbol + wordmark), exported from Figma. One
/// asset for every platform; size it by height.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.height = 52});

  static const String asset = 'assets/images/brand/logo_full.png';

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Tendryn',
    );
  }
}
