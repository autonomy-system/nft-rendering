import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inline_webview_macos/flutter_inline_webview_macos.dart';
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
const keysCode = {
  "backspace": 8,
  "tab": 9,
  "enter": 13,
  "shift": 16,
  "ctrl": 17,
  "alt": 18,
  "pausebreak": 19,
  "capslock": 20,
  "esc": 27,
  "space": 32,
  "pageup": 33,
  "pagedown": 34,
  "end": 35,
  "home": 36,
  "leftarrow": 37,
  "uparrow": 38,
  "rightarrow": 39,
  "downarrow": 40,
  "insert": 45,
  "delete": 46,
  "0": 48,
  "1": 49,
  "2": 50,
  "3": 51,
  "4": 52,
  "5": 53,
  "6": 54,
  "7": 55,
  "8": 56,
  "9": 57,
  "a": 65,
  "b": 66,
  "c": 67,
  "d": 68,
  "e": 69,
  "f": 70,
  "g": 71,
  "h": 72,
  "i": 73,
  "j": 74,
  "k": 75,
  "l": 76,
  "m": 77,
  "n": 78,
  "o": 79,
  "p": 80,
  "q": 81,
  "r": 82,
  "s": 83,
  "t": 84,
  "u": 85,
  "v": 86,
  "w": 87,
  "x": 88,
  "y": 89,
  "z": 90,
  "leftwindowkey": 91,
  "rightwindowkey": 92,
  "selectkey": 93,
  "numpad0": 96,
  "numpad1": 97,
  "numpad2": 98,
  "numpad3": 99,
  "numpad4": 100,
  "numpad5": 101,
  "numpad6": 102,
  "numpad7": 103,
  "numpad8": 104,
  "numpad9": 105,
  "multiply": 106,
  "add": 107,
  "subtract": 109,
  "decimalpoint": 110,
  "divide": 111,
  "f1": 112,
  "f2": 113,
  "f3": 114,
  "f4": 115,
  "f5": 116,
  "f6": 117,
  "f7": 118,
  "f8": 119,
  "f9": 120,
  "f10": 121,
  "f11": 122,
  "f12": 123,
  "numlock": 144,
  "scrolllock": 145,
  "semicolon": 186,
  "equalsign": 187,
  "comma": 188,
  "dash": 189,
  "period": 190,
  "forwardslash": 191,
  "graveaccent": 192,
  "openbracket": 219,
  "backslash": 220,
  "closebracket": 221,
  "singlequote": 222
};

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
      return Platform.isMacOS
          ? WebviewMacOSNFTRenderingWidget()
          : WebviewNFTRenderingWidget();
    default:
      return Platform.isMacOS
          ? WebviewMacOSNFTRenderingWidget()
          : WebviewNFTRenderingWidget();
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
  final int? latestPosition;
  Function({int? time})? onLoaded;
  Function({int? time})? onDispose;

  RenderingWidgetBuilder({
    this.loadingWidget,
    this.errorWidget,
    this.thumbnailURL,
    this.previewURL,
    this.cacheManager,
    this.controller,
    this.onLoaded,
    this.onDispose,
    this.latestPosition,
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
      onLoaded = renderingWidgetBuilder.onLoaded;
      onDispose = renderingWidgetBuilder.onDispose;
      latestPosition = renderingWidgetBuilder.latestPosition;
    }
  }

  void setRenderWidgetBuilder(RenderingWidgetBuilder renderingWidgetBuilder) {
    loadingWidget =
        renderingWidgetBuilder.loadingWidget ?? const NFTLoadingWidget();
    errorWidget = renderingWidgetBuilder.errorWidget ?? const NFTErrorWidget();
    previewURL = renderingWidgetBuilder.previewURL ?? "";
    cacheManager = renderingWidgetBuilder.cacheManager;
    controller = renderingWidgetBuilder.controller;
    onLoaded = renderingWidgetBuilder.onLoaded;
    onDispose = renderingWidgetBuilder.onDispose;
    latestPosition = renderingWidgetBuilder.latestPosition;
  }

  Function({int? time})? onLoaded;
  Function({int? time})? onDispose;
  Widget loadingWidget = const NFTLoadingWidget();
  Widget errorWidget = const NFTErrorWidget();
  String previewURL = "";
  dynamic controller;
  BaseCacheManager? cacheManager;
  int? latestPosition;

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
      imageBuilder: (context, imageProvider) {
        onLoaded?.call();
        return PhotoView(
          imageProvider: imageProvider,
        );
      },
      cacheManager: cacheManager,
      placeholder: (context, url) => loadingWidget,
      placeholderFadeInDuration: const Duration(milliseconds: 300),
      errorWidget: (context, url, error) {
        onLoaded?.call();
        return Center(
          child: errorWidget,
        );
      },
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
        onLoaded: () => onLoaded?.call(),
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
    onLoaded?.call();
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
      onLoaded?.call(time: _player?.duration?.inSeconds);
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
  bool _playAfterInitialized = true;

  VideoNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        ) {
    runZonedGuarded(() {
      _controller = VideoPlayerController.network(previewURL);

      _controller!.initialize().then((_) async {
        _stateOfRenderingWidget.previewLoaded();
        final durationVideo = _controller?.value.duration.inSeconds ?? 0;
        Duration position;
        if (latestPosition == null || latestPosition! >= durationVideo) {
          position = const Duration(seconds: 0);
        } else {
          position = Duration(seconds: latestPosition!);
        }
        await _controller?.seekTo(position);
        onLoaded?.call(time: durationVideo);
        _controller?.setLooping(true);
        if (_playAfterInitialized) {
          _controller?.play();
        }
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

      _controller!.initialize().then((_) async {
        final time = _controller?.value.duration.inSeconds;
        Duration position;
        if (latestPosition == null ||
            latestPosition! >= _controller!.value.duration.inSeconds) {
          position = const Duration(seconds: 0);
        } else {
          position = Duration(seconds: latestPosition!);
        }
        await _controller?.seekTo(position);
        onLoaded?.call(time: time);
        _stateOfRenderingWidget.previewLoaded();
        _controller?.setLooping(true);
        if (_playAfterInitialized) {
          _controller?.play();
        }
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
    _playAfterInitialized = true;
    _controller?.play();
  }

  @override
  void dispose() async {
    final position = await _controller?.position;
    onDispose?.call(time: position?.inSeconds ?? 0);
    _controller?.dispose();
    _controller = null;
  }

  @override
  Future<bool> clearPrevious() async {
    _playAfterInitialized = false;
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
  late Key key;
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
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    deviceInfo.androidInfo.then((value) {
      bool isTV =
          value.systemFeatures.contains('android.software.leanback_only');
      if (!isTV) {
        SystemChannels.keyEvent.setMessageHandler((message) async {
          if (message is! Map) return;
          final character = message['character'];
          final type = message['type'];
          _webViewController?.runJavascript(
              'window.dispatchEvent(new KeyboardEvent(\'$type\', {\'key\': \'$character\',\'keyCode\': ${keysCode[character]}}));');
        });
      }
    });

    return Stack(
      fit: StackFit.loose,
      children: [
        WebView(
          key: Key(previewURL),
          initialUrl: previewURL,
          initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
          },
          onWebResourceError: (WebResourceError error) {},
          onPageFinished: (some) async {
            _stateOfRenderingWidget.previewLoaded();
            onLoaded?.call();
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
          backgroundColor: Colors.black,
        ),
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
    _webViewController?.runJavascript(
        "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.pause(); }");
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

/// Webview rendering widget type for MacOS
class WebviewMacOSNFTRenderingWidget extends INFTRenderingWidget {
  WebviewMacOSNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        );

  InlineWebViewMacOsController? _webViewController;
  final _stateOfRenderingWidget = StateOfRenderingWidget();
  late Key key;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _stateOfRenderingWidget,
      builder: (context, child) {
        return previewURL.isEmpty
            ? const NoPreviewUrlWidget()
            : _widgetBuilder(context);
      },
    );
  }

  Widget _widgetBuilder(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heightRatio = size.height / 1080;
    return Stack(
      fit: StackFit.loose,
      children: [
        Padding(
          padding: EdgeInsets.only(top: heightRatio * 92),
          child: InlineWebViewMacOs(
            key: Key(previewURL),
            initialUrlRequest: URLRequest(url: Uri.tryParse(previewURL)),
            width: size.width,
            height: size.height,
            onWebViewCreated: (webViewController) {
              _webViewController = webViewController;
              _webViewController?.loadUrl(
                  urlRequest: URLRequest(url: Uri.tryParse(previewURL)));
            },
            onLoadStop: (controller, url) async {
              _stateOfRenderingWidget.previewLoaded();
              onLoaded?.call();
              const javascriptString = '''
                  var meta = document.createElement('meta');
                              meta.setAttribute('name', 'viewport');
                              document.getElementsByTagName('head')[0].appendChild(meta);
                              document.body.style.overflow = 'hidden';
                  ''';
              await _webViewController?.runJavascript(javascriptString);
            },
          ),
        ),
        if (!_stateOfRenderingWidget.isPreviewLoaded) ...[
          loadingWidget,
        ]
      ],
    );
  }

  @override
  void didPopNext() {
    _webViewController?.runJavascript(
        "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.play(); }");
  }

  @override
  void dispose() {
    _webViewController?.runJavascript(
        "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.pause(); }");
    _webViewController?.dispose();
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

  final _loading = ValueNotifier(true);
  final _loadError = ValueNotifier<PdfDocumentLoadFailedDetails?>(null);

  Widget _widgetBuilder() {
    return Stack(children: [
      SfPdfViewer.network(
        previewURL,
        key: Key(previewURL),
        controller: controller is PdfViewerController ? controller : null,
        onDocumentLoaded: (_) {
          onLoaded?.call();
          _loading.value = false;
        },
        onDocumentLoadFailed: (error) {
          onLoaded?.call();
          _loading.value = false;
          _loadError.value = error;
        },
      ),
      ValueListenableBuilder<PdfDocumentLoadFailedDetails?>(
        valueListenable: _loadError,
        builder: (context, error, child) {
          return Visibility(
            visible: error != null,
            child: Container(
              color: Colors.black,
              child: errorWidget,
            ),
          );
        },
      ),
      ValueListenableBuilder<bool>(
        valueListenable: _loading,
        builder: (context, loading, child) {
          return Visibility(
            visible: loading,
            child: Container(
              color: Colors.black,
              child: loadingWidget,
            ),
          );
        },
      ),
    ]);
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
