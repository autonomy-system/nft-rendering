import 'package:flutter/material.dart';
import 'package:nft_rendering/src/nft_rendering_widget.dart';

// The widget can be called for nft rendering
class NFTRenderingCombineWidget extends StatelessWidget {
  final String mimeType;
  final String previewURL;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const NFTRenderingCombineWidget({
    Key? key,
    required this.mimeType,
    required this.previewURL,
    this.errorWidget,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildRenderingWidget(context);
  }

  Widget _buildRenderingWidget(BuildContext context) {
    // if typesOfNFTRenderingWidget doesn't have miypeType, we will return webview nft rendering
    INFTRenderingWidget renderingWidget =
        typesOfNFTRenderingWidget[mimeType] ?? WebviewNFTRenderingWidget();

    renderingWidget.setRenderWidgetBuilder(RenderingWidgetBuilder(
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      previewURL: previewURL,
    ));

    return Container(
      child: renderingWidget.build(context),
    );
  }
}
