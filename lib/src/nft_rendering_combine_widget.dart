import 'package:flutter/material.dart';
import 'package:nft_rendering/src/nft_rendering_widget.dart';

// The widget can be called for nft rendering
class NFTRenderingCombineWidget extends StatefulWidget {
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
  State<StatefulWidget> createState() {
    return _NFTRenderingCombineWidget();
  }
}

class _NFTRenderingCombineWidget extends State<NFTRenderingCombineWidget> {
  late INFTRenderingWidget _renderingWidget;

  @override
  Widget build(BuildContext context) {
    return _buildRenderingWidget(context);
  }

  Widget _buildRenderingWidget(BuildContext context) {
    // if typesOfNFTRenderingWidget doesn't have mimeType, we will return webview nft rendering
    _renderingWidget = typesOfNFTRenderingWidget[widget.mimeType] ??
        WebviewNFTRenderingWidget();

    _renderingWidget.setRenderWidgetBuilder(RenderingWidgetBuilder(
      loadingWidget: widget.loadingWidget,
      errorWidget: widget.errorWidget,
      previewURL: widget.previewURL,
    ));

    return Container(
      child: _renderingWidget.build(context),
    );
  }
}
