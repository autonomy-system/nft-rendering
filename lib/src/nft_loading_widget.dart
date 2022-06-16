import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Default of loading state widget
class NFTLoadingWidget extends StatelessWidget {
  const NFTLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CupertinoActivityIndicator(color: Colors.white, radius: 16),
    );
  }
}
