import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Default of error state widget
class NFTErrorWidget extends StatelessWidget {
  const NFTErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/images/image_error.svg',
        width: 148,
        height: 158,
      ),
    );
  }
}
