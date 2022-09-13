import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nft_rendering/src/nft_error_widget.dart';
import 'package:nft_rendering/src/nft_loading_widget.dart';
import 'package:nft_rendering/src/widget/svg_image.dart';
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
    case 'gif':
      return GifNFTRenderingWidget();
    case "audio":
      return AudioNFTRenderingWidget();
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
  final String? thumbnailURL;
  late String? previewURL;
  late BaseCacheManager? cacheManager;
  late dynamic controller;

  RenderingWidgetBuilder({
    this.loadingWidget,
    this.errorWidget,
    this.thumbnailURL,
    this.previewURL,
    this.cacheManager,
    this.controller,
  });
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
      controller = renderingWidgetBuilder.controller;
    }
  }

  void setRenderWidgetBuilder(RenderingWidgetBuilder renderingWidgetBuilder) {
    loadingWidget =
        renderingWidgetBuilder.loadingWidget ?? const NFTLoadingWidget();
    errorWidget = renderingWidgetBuilder.errorWidget ?? const NFTErrorWidget();
    previewURL = renderingWidgetBuilder.previewURL ?? "";
    cacheManager = renderingWidgetBuilder.cacheManager;
    controller = renderingWidgetBuilder.controller;
  }

  Widget loadingWidget = const NFTLoadingWidget();
  Widget errorWidget = const NFTErrorWidget();
  String previewURL = "";
  dynamic controller;
  BaseCacheManager? cacheManager;

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
    return previewURL.isEmpty ? const NoPreviewUrlWidget() : _widgetBuilder();
  }

  Widget _widgetBuilder() {
    return CachedNetworkImage(
      imageUrl: previewURL,
      imageBuilder: (context, imageProvider) => PhotoView(
        imageProvider: imageProvider,
      ),
      cacheManager: cacheManager,
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
    return previewURL.isEmpty ? const NoPreviewUrlWidget() : _widgetBuilder();
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
      child: SvgImage(
        url: previewURL,
        fallbackToWebView: true,
        loadingWidgetBuilder: (context) => loadingWidget,
        onLoaded: () {},
        onError: () {},
      ),
    );
  }
}

class GifNFTRenderingWidget extends INFTRenderingWidget {
  GifNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        );

  @override
  Widget build(BuildContext context) {
    return previewURL.isEmpty ? const NoPreviewUrlWidget() : _widgetBuilder();
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
    return CachedNetworkImage(
      imageUrl: previewURL,
      placeholder: (context, url) => loadingWidget,
      placeholderFadeInDuration: const Duration(milliseconds: 300),
      errorWidget: (context, url, error) => Center(
        child: errorWidget,
      ),
      fit: BoxFit.cover,
    );
  }
}

class AudioNFTRenderingWidget extends INFTRenderingWidget {
  String? _thumbnailURL;
  AudioPlayer? _player;

  final _progressStreamController = StreamController<double>();

  @override
  Future<bool> clearPrevious() async {
    await _pauseAudio();
    return true;
  }

  @override
  void didPopNext() {
    _resumeAudio();
  }

  @override
  void dispose() {
    _disposeAudioPlayer();
  }

  Future _disposeAudioPlayer() async {
    await _player?.dispose();
    _player = null;
  }

  Future _playAudio(String audioURL) async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _player = AudioPlayer();
      _player?.positionStream.listen((event) {
        final progress =
            event.inMilliseconds / (_player?.duration?.inMilliseconds ?? 1);
        _progressStreamController.sink.add(progress);
      });
      await _player?.setLoopMode(LoopMode.all);
      await _player?.setAudioSource(AudioSource.uri(Uri.parse(audioURL)));
      await _player?.play();
    } catch (e) {
      if (kDebugMode) {
        print("Can't set audio source: $audioURL. Error: $e");
      }
    }
  }

  _pauseAudio() async {
    await _player?.pause();
  }

  _resumeAudio() async {
    await _player?.play();
  }

  @override
  void setRenderWidgetBuilder(RenderingWidgetBuilder renderingWidgetBuilder) {
    super.setRenderWidgetBuilder(renderingWidgetBuilder);
    _thumbnailURL = renderingWidgetBuilder.thumbnailURL;
    _disposeAudioPlayer().then((_) {
      final audioURL = renderingWidgetBuilder.previewURL;
      if (audioURL != null) {
        _playAudio(audioURL);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: CachedNetworkImage(
            imageUrl: _thumbnailURL ?? "",
            cacheManager: cacheManager,
            placeholder: (context, url) => loadingWidget,
            placeholderFadeInDuration: const Duration(milliseconds: 300),
            errorWidget: (context, url, error) => Center(
              child: errorWidget,
            ),
            fit: BoxFit.contain,
          ),
        ),
        StreamBuilder<double>(
            stream: _progressStreamController.stream,
            builder: (context, snapshot) {
              return LinearProgressIndicator(
                value: snapshot.data ?? 0,
                color: Colors.white,
                backgroundColor: Colors.black,
              );
            }),
      ],
    );
  }
}

/// Video rendering widget type
class VideoNFTRenderingWidget extends INFTRenderingWidget {
  String? _thumbnailURL;

  VideoNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        ) {
    runZonedGuarded(() {
      _controller = VideoPlayerController.network(previewURL);

      _controller!.initialize().then((_) {
        _stateOfRenderingWidget.previewLoaded();
        _controller?.play();
        _controller?.setLooping(true);
      });
    }, (error, stack) {
      _stateOfRenderingWidget.playingFailed();
    });
  }

  VideoPlayerController? _controller;
  final _stateOfRenderingWidget = StateOfRenderingWidget();

  @override
  void setRenderWidgetBuilder(RenderingWidgetBuilder renderingWidgetBuilder) {
    super.setRenderWidgetBuilder(renderingWidgetBuilder);
    runZonedGuarded(() {
      _thumbnailURL = renderingWidgetBuilder.thumbnailURL;
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
    }, (error, stack) {
      _stateOfRenderingWidget.playingFailed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _stateOfRenderingWidget,
      builder: (context, child) {
        return previewURL.isEmpty
            ? const NoPreviewUrlWidget()
            : _widgetBuilder();
      },
    );
  }

  Widget _widgetBuilder() {
    if (_controller != null) {
      if (_stateOfRenderingWidget.isPlayingFailed && _thumbnailURL != null) {
        return CachedNetworkImage(
          imageUrl: _thumbnailURL!,
          imageBuilder: (context, imageProvider) => PhotoView(
            imageProvider: imageProvider,
          ),
          cacheManager: cacheManager,
          placeholder: (context, url) => loadingWidget,
          placeholderFadeInDuration: const Duration(milliseconds: 300),
          errorWidget: (context, url, error) => Center(
            child: errorWidget,
          ),
          fit: BoxFit.cover,
        );
      } else if (_stateOfRenderingWidget.isPreviewLoaded) {
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
  bool isPlayingFailed = false;

  void previewLoaded() {
    isPreviewLoaded = true;
    isPlayingFailed = false;
    notifyListeners();
  }

  void playingFailed() {
    isPreviewLoaded = false;
    isPlayingFailed = true;
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
        return previewURL.isEmpty
            ? const NoPreviewUrlWidget()
            : _widgetBuilder();
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
    return previewURL.isEmpty ? const NoPreviewUrlWidget() : _widgetBuilder();
  }

  Widget _widgetBuilder() {
    if (controller is PdfViewerController) {
      return SfPdfViewer.network(previewURL,
          key: Key(previewURL), controller: controller);
    } else {
      return SfPdfViewer.network(previewURL, key: Key(previewURL));
    }
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

class NoPreviewUrlWidget extends StatelessWidget {
  const NoPreviewUrlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Center(
          child: ClipPath(
            clipper: RectangleClipper(),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              height: size.width,
              width: size.width,
              color: Colors.white,
            ),
          ),
        ),
        Center(
          child: ClipPath(
            clipper: RectangleClipper(),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              height: size.width - 2,
              width: size.width - 2,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class RectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 14;

    Path path = Path()
      ..lineTo(0, 0)
      ..lineTo(size.width - radius, 0)
      ..lineTo(size.width, radius)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
