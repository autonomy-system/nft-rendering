import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nft_rendering/src/nft_error_widget.dart';
import 'package:nft_rendering/src/nft_loading_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Get nft rendering widget by type
/// You can add and define more types by creating classes extends [INFTRenderingWidget]
///
INFTRenderingWidget typesOfNFTRenderingWidget(String type) {
  switch (type) {
    case "image":
      return ImageNFTRenderingWidget();
    case "svg":
      return SVGNFTRenderingWidget();
    case "video":
      return VideoNFTRenderingWidget();
    case "application/pdf":
      return PDFNFTRenderingWidget();
    case "webview":
      return WebviewNFTRenderingWidget();
    default:
      return WebviewNFTRenderingWidget();
  }
}

/// Class holds property of rendering widget
class RenderingWidgetBuilder {
  late Widget? loadingWidget;
  late Widget? errorWidget;
  late String? previewURL;

  RenderingWidgetBuilder(
      {this.loadingWidget, this.errorWidget, this.previewURL});
}

/// interface of rendering widget
abstract class INFTRenderingWidget {
  INFTRenderingWidget({RenderingWidgetBuilder? renderingWidgetBuilder}) {
    if (renderingWidgetBuilder != null) {
      loadingWidget =
          renderingWidgetBuilder.loadingWidget ?? const NFTLoadingWidget();
      errorWidget =
          renderingWidgetBuilder.errorWidget ?? const NFTErrorWidget();
      previewURL = renderingWidgetBuilder.previewURL ?? "";
    }
  }

  void setRenderWidgetBuilder(RenderingWidgetBuilder renderingWidgetBuilder) {
    loadingWidget =
        renderingWidgetBuilder.loadingWidget ?? const NFTLoadingWidget();
    errorWidget = renderingWidgetBuilder.errorWidget ?? const NFTErrorWidget();
    previewURL = renderingWidgetBuilder.previewURL ?? "";
  }

  Widget loadingWidget = const NFTLoadingWidget();
  Widget errorWidget = const NFTErrorWidget();
  String previewURL = "";

  Widget build(BuildContext context) => const SizedBox();

  void dispose();

  void didPopNext();

  Future<bool> clearPrevious();
}

/// Image rendering widget type
class ImageNFTRenderingWidget extends INFTRenderingWidget {
  ImageNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        );

  @override
  Widget build(BuildContext context) {
    return _widgetBuilder();
  }

  Widget _widgetBuilder() {
    return CachedNetworkImage(
      imageUrl: previewURL,
      imageBuilder: (context, imageProvider) => PhotoView(
        imageProvider: imageProvider,
      ),
      placeholder: (context, url) => loadingWidget,
      placeholderFadeInDuration: const Duration(milliseconds: 300),
      errorWidget: (context, url, error) => Center(
        child: errorWidget,
      ),
      fit: BoxFit.cover,
    );
  }

  @override
  void didPopNext() {}

  @override
  void dispose() {}

  @override
  Future<bool> clearPrevious() {
    return Future.value(true);
  }
}

class SVGNFTRenderingWidget extends INFTRenderingWidget {
  SVGNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        );

  @override
  Widget build(BuildContext context) {
    return _widgetBuilder();
  }

  @override
  Future<bool> clearPrevious() {
    return Future.value(true);
  }

  @override
  void didPopNext() {}

  @override
  void dispose() {}

  Widget _widgetBuilder() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.white,
        child: SvgPicture.network(
          previewURL,
          placeholderBuilder: (context) => loadingWidget,
        ),
      ),
    );
  }
}

/// Video rendering widget type
class VideoNFTRenderingWidget extends INFTRenderingWidget {
  VideoNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        ) {
    _controller = VideoPlayerController.network(previewURL);

    _controller!.initialize().then((_) {
      _stateOfRenderingWidget.previewLoaded();
      _controller?.play();
      _controller?.setLooping(true);
    });
  }

  VideoPlayerController? _controller;
  final _stateOfRenderingWidget = StateOfRenderingWidget();

  @override
  void setRenderWidgetBuilder(RenderingWidgetBuilder renderingWidgetBuilder) {
    super.setRenderWidgetBuilder(renderingWidgetBuilder);
    if (_controller != null) {
      _controller?.dispose();
      _controller = null;
    }
    _controller = VideoPlayerController.network(previewURL);

    _controller!.initialize().then((_) {
      _stateOfRenderingWidget.previewLoaded();
      _controller?.play();
      _controller?.setLooping(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _stateOfRenderingWidget,
      builder: (context, child) {
        return _widgetBuilder();
      },
    );
  }

  Widget _widgetBuilder() {
    if (_controller != null) {
      if (_stateOfRenderingWidget.isPreviewLoaded) {
        return AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        );
      } else {
        return loadingWidget;
      }
    } else {
      return const SizedBox();
    }
  }

  @override
  void didPopNext() {
    _controller?.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  Future<bool> clearPrevious() async {
    await _controller?.pause();
    return true;
  }
}

class StateOfRenderingWidget with ChangeNotifier {
  bool isPreviewLoaded = false;

  void previewLoaded() {
    this.isPreviewLoaded = true;
    notifyListeners();
  }
}

/// Webview rendering widget type
class WebviewNFTRenderingWidget extends INFTRenderingWidget {
  WebviewNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        );

  WebViewController? _webViewController;
  final _stateOfRenderingWidget = StateOfRenderingWidget();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _stateOfRenderingWidget,
      builder: (context, child) {
        return _widgetBuilder();
      },
    );
  }

  Widget _widgetBuilder() {
    return Stack(
      fit: StackFit.loose,
      children: [
        WebView(
            key: Key(previewURL),
            initialUrl: previewURL,
            zoomEnabled: false,
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
            },
            onWebResourceError: (WebResourceError error) {},
            onPageFinished: (some) async {
              _stateOfRenderingWidget.previewLoaded();
              const javascriptString = '''
                var meta = document.createElement('meta');
                            meta.setAttribute('name', 'viewport');
                            meta.setAttribute('content', 'width=device-width');
                            document.getElementsByTagName('head')[0].appendChild(meta);
                            document.body.style.overflow = 'hidden';
                ''';
              await _webViewController?.runJavascript(javascriptString);
            },
            javascriptMode: JavascriptMode.unrestricted,
            allowsInlineMediaPlayback: true,
            backgroundColor: Colors.black),
        if (!_stateOfRenderingWidget.isPreviewLoaded) ...[
          loadingWidget,
        ]
      ],
    );
    ;
  }

  @override
  void didPopNext() {
    _webViewController?.runJavascript(
        "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.play(); }");
  }

  @override
  void dispose() {
    _webViewController = null;
  }

  @override
  Future<bool> clearPrevious() async {
    await _webViewController?.runJavascript(
        "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.pause(); }");
    return true;
  }

  updateWebviewSize() {
    if (_webViewController != null) {
      EasyDebounce.debounce(
          'screen_rotate', // <-- An ID for this particular debouncer
          const Duration(milliseconds: 100), // <-- The debounce duration
          () => _webViewController?.runJavascript(
              "window.dispatchEvent(new Event('resize'));") // <-- The target method
          );
    }
  }
}

/// PDF rendering widget type
class PDFNFTRenderingWidget extends INFTRenderingWidget {
  PDFNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        );

  @override
  Widget build(BuildContext context) {
    return _widgetBuilder();
  }

  Widget _widgetBuilder() {
    return SfPdfViewer.network(previewURL, key: Key(previewURL));
  }

  @override
  Future<bool> clearPrevious() {
    return Future.value(true);
  }

  @override
  void didPopNext() {}

  @override
  void dispose() {}
}
