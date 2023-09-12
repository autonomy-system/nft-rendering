import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    as inapp_webview;
import 'package:flutter_inline_webview_macos/flutter_inline_webview_macos.dart';
import 'package:flutter_inline_webview_macos/flutter_inline_webview_macos.dart'
    as inapp_webview_macos;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:nft_rendering/src/nft_error_widget.dart';
import 'package:nft_rendering/src/nft_loading_widget.dart';
import 'package:nft_rendering/src/widget/svg_image.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

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

class RenderingType {
  static const image = 'image';
  static const svg = 'svg';
  static const gif = 'gif';
  static const audio = 'audio';
  static const video = 'video';
  static const pdf = 'application/pdf';
  static const webview = 'webview';
  static const modelViewer = 'modelViewer';
}

INFTRenderingWidget typesOfNFTRenderingWidget(String type) {
  switch (type) {
    case RenderingType.image:
      return ImageNFTRenderingWidget();
    case RenderingType.svg:
      return SVGNFTRenderingWidget();
    case RenderingType.gif:
      return GifNFTRenderingWidget();
    case RenderingType.audio:
      return AudioNFTRenderingWidget();
    case RenderingType.video:
      return VideoNFTRenderingWidget();
    case RenderingType.pdf:
      return PDFNFTRenderingWidget();
    case RenderingType.modelViewer:
      return Platform.isMacOS
          ? WebviewMacOSNFTRenderingWidget()
          : ModelViewerRenderingWidget();
    case RenderingType.webview:
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
  late Widget? noPreviewUrlWidget;
  final String? thumbnailURL;
  late String? previewURL;
  late BaseCacheManager? cacheManager;
  late dynamic controller;
  final int? latestPosition;
  final String? overriddenHtml;
  final bool isMute;
  final bool skipViewport;
  Function({int? time, InAppWebViewController? webViewController})? onLoaded;
  Function({int? time})? onDispose;
  FocusNode? focusNode;
  String? userAgent;

  RenderingWidgetBuilder({
    this.loadingWidget,
    this.errorWidget,
    this.noPreviewUrlWidget,
    this.thumbnailURL,
    this.previewURL,
    this.cacheManager,
    this.controller,
    this.onLoaded,
    this.onDispose,
    this.latestPosition,
    this.overriddenHtml,
    this.isMute = false,
    this.focusNode,
    this.skipViewport = false,
    this.userAgent = "",
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
      overriddenHtml = renderingWidgetBuilder.overriddenHtml;
      isMute = renderingWidgetBuilder.isMute;
      skipViewport = renderingWidgetBuilder.skipViewport;
      focusNode = renderingWidgetBuilder.focusNode;
    }
  }

  void setRenderWidgetBuilder(RenderingWidgetBuilder renderingWidgetBuilder) {
    loadingWidget =
        renderingWidgetBuilder.loadingWidget ?? const NFTLoadingWidget();
    errorWidget = renderingWidgetBuilder.errorWidget ?? const NFTErrorWidget();
    noPreviewUrlWidget =
        renderingWidgetBuilder.noPreviewUrlWidget ?? const NoPreviewUrlWidget();
    previewURL = renderingWidgetBuilder.previewURL ?? "";
    cacheManager = renderingWidgetBuilder.cacheManager;
    controller = renderingWidgetBuilder.controller;
    onLoaded = renderingWidgetBuilder.onLoaded;
    onDispose = renderingWidgetBuilder.onDispose;
    latestPosition = renderingWidgetBuilder.latestPosition;
    overriddenHtml = renderingWidgetBuilder.overriddenHtml;
    isMute = renderingWidgetBuilder.isMute;
    skipViewport = renderingWidgetBuilder.skipViewport;
    focusNode = renderingWidgetBuilder.focusNode;
    userAgent = renderingWidgetBuilder.userAgent ?? "";
  }

  Function({int? time, InAppWebViewController? webViewController})? onLoaded;
  Function({int? time})? onDispose;
  FocusNode? focusNode;
  Widget loadingWidget = const NFTLoadingWidget();
  Widget errorWidget = const NFTErrorWidget();
  Widget noPreviewUrlWidget = const NoPreviewUrlWidget();
  String previewURL = "";
  dynamic controller;
  BaseCacheManager? cacheManager;
  int? latestPosition;
  String? overriddenHtml;
  bool isMute = false;
  bool skipViewport = false;
  String userAgent = "";

  Widget build(BuildContext context) => const SizedBox();

  void dispose();

  void didPopNext();

  Future<void> pauseOrResume() async {}

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
    return previewURL.isEmpty ? noPreviewUrlWidget : _widgetBuilder();
  }

  Widget _widgetBuilder() {
    return CachedNetworkImage(
      imageUrl: previewURL,
      imageBuilder: (context, imageProvider) {
        onLoaded?.call();
        return Image(
          image: imageProvider,
        );
      },
      cacheManager: cacheManager,
      placeholder: (context, url) => loadingWidget,
      placeholderFadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 0),
      errorWidget: (context, url, error) {
        onLoaded?.call();
        return Center(
          child: errorWidget,
        );
      },
      // fit: BoxFit.cover,
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
    return previewURL.isEmpty ? noPreviewUrlWidget : _widgetBuilder();
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
    return previewURL.isEmpty ? noPreviewUrlWidget : _widgetBuilder();
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
      fadeOutDuration: const Duration(milliseconds: 0),
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

  @override
  Future<void> pauseOrResume() async {
    if (_player?.playing == true) {
      await _pauseAudio();
    } else {
      await _resumeAudio();
    }
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
      if (isMute) {
        _player?.setVolume(0);
      }
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
            fadeOutDuration: const Duration(milliseconds: 0),
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
                color: const Color.fromRGBO(0, 255, 163, 1),
                backgroundColor: Colors.transparent,
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
  ValueNotifier<Duration> positionListener = ValueNotifier(const Duration());

  VideoNFTRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        ) {
    runZonedGuarded(() {
      _controller = VideoPlayerController.networkUrl(Uri.parse(previewURL));

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
        if (isMute) {
          _controller?.setVolume(0);
        }
        onLoaded?.call(time: durationVideo);
        _controller?.setLooping(true);
        if (_playAfterInitialized) {
          _controller?.play();
        }
        _controller?.addListener(_controlerListener);
      });
    }, (error, stack) {
      _stateOfRenderingWidget.playingFailed();
    });
  }

  @override
  Future<void> pauseOrResume() async {
    if (_controller?.value.isPlaying ?? false) {
      await _controller?.pause();
    } else {
      await _controller?.play();
    }
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
      _controller = VideoPlayerController.networkUrl(Uri.parse(previewURL));

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
        if (isMute) {
          _controller?.setVolume(0);
        }
        onLoaded?.call(time: time);
        _stateOfRenderingWidget.previewLoaded();
        _controller?.setLooping(true);
        if (_playAfterInitialized) {
          _controller?.play();
        }
        _controller?.addListener(_controlerListener);
      });
    }, (error, stack) {
      _stateOfRenderingWidget.playingFailed();
    });
  }

  void _controlerListener() {
    final positon = _controller?.value.position;
    if (positon != null) {
      positionListener.value = positon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _stateOfRenderingWidget,
      builder: (context, child) {
        return previewURL.isEmpty ? noPreviewUrlWidget : _widgetBuilder();
      },
    );
  }

  Widget _widgetBuilder() {
    if (_controller != null) {
      if (_stateOfRenderingWidget.isPlayingFailed && _thumbnailURL != null) {
        return CachedNetworkImage(
          imageUrl: _thumbnailURL!,
          imageBuilder: (context, imageProvider) => Image(
            image: imageProvider,
          ),
          cacheManager: cacheManager,
          placeholder: (context, url) => loadingWidget,
          placeholderFadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 0),
          errorWidget: (context, url, error) => Center(
            child: errorWidget,
          ),
          fit: BoxFit.cover,
        );
      } else if (_stateOfRenderingWidget.isPreviewLoaded) {
        return Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder<Duration>(
                  valueListenable: positionListener,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value.inMilliseconds /
                          _controller!.value.duration.inMilliseconds,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromRGBO(0, 255, 163, 1)),
                      backgroundColor: Colors.transparent,
                    );
                  }),
            ),
            Visibility(
              visible: isMute,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: SvgPicture.asset("assets/images/Mute_Circle.svg"),
                ),
              ),
            ),
          ],
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

  InAppWebViewController? _webViewController;
  TextEditingController? _textController;
  final _stateOfRenderingWidget = StateOfRenderingWidget();
  late Key key;

  @override
  void setRenderWidgetBuilder(RenderingWidgetBuilder renderingWidgetBuilder) {
    super.setRenderWidgetBuilder(renderingWidgetBuilder);
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _stateOfRenderingWidget,
      builder: (context, child) {
        return previewURL.isEmpty ? noPreviewUrlWidget : _widgetBuilder();
      },
    );
  }

  Widget _widgetBuilder() {
    return Stack(
      fit: StackFit.loose,
      children: [
        Visibility(
          visible: focusNode != null,
          child: TextFormField(
            controller: _textController,
            focusNode: focusNode,
            onChanged: (value) {
              _webViewController?.evaluateJavascript(
                  source:
                      'window.dispatchEvent(new KeyboardEvent(\'keydown\', {\'key\': \'${value.characters.last}\',\'keyCode\': ${keysCode[value.characters.last]},\'which\': ${keysCode[value.characters.last]}}));window.dispatchEvent(new KeyboardEvent(\'keypress\', {\'key\': \'${value.characters.last}\',\'keyCode\': ${keysCode[value.characters.last]},\'which\': ${keysCode[value.characters.last]}}));window.dispatchEvent(new KeyboardEvent(\'keyup\', {\'key\': \'${value.characters.last}\',\'keyCode\': ${keysCode[value.characters.last]},\'which\': ${keysCode[value.characters.last]}}));');
              _textController?.text = '';
            },
          ),
        ),
        InAppWebView(
          key: Key(previewURL),
          initialUrlRequest: inapp_webview.URLRequest(
              url: Uri.tryParse(
                  overriddenHtml != null ? 'about:blank' : previewURL)),
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                userAgent: userAgent,
                mediaPlaybackRequiresUserGesture: false,
              ),
              android: AndroidInAppWebViewOptions(),
              ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true)),
          initialUserScripts: UnmodifiableListView<UserScript>([
            UserScript(source: '''
                window.print = function () {
                  console.log('Skip printing');
                };
                ''', injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START)
          ]),
          onWebViewCreated: (controller) {
            _webViewController = controller;
            if (overriddenHtml != null) {
              final uri = Uri.dataFromString(overriddenHtml!,
                  mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
              _webViewController?.loadUrl(
                  urlRequest: inapp_webview.URLRequest(url: uri));
            }
          },
          onLoadStop: (controller, uri) async {
            _stateOfRenderingWidget.previewLoaded();
            onLoaded?.call(webViewController: _webViewController);
            const javascriptString = '''
                var meta = document.createElement('meta');
                            meta.setAttribute('name', 'viewport');
                            document.getElementsByTagName('head')[0].appendChild(meta);
                ''';
            await _webViewController?.evaluateJavascript(
                source: javascriptString);

            if (!skipViewport) {
              await _webViewController?.evaluateJavascript(
                  source: '''document.body.style.overflow = 'hidden';''');
            }

            if (isMute) {
              _webViewController?.evaluateJavascript(
                  source:
                      "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.muted = true; } var audio = document.getElementsByTagName('audio')[0]; if(audio != undefined) { audio.muted = true; }");
            }
          },
        ),
        if (!_stateOfRenderingWidget.isPreviewLoaded) ...[
          loadingWidget,
        ],
      ],
    );
  }

  @override
  void didPopNext() {
    _webViewController?.evaluateJavascript(
        source:
            "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.play(); } var audio = document.getElementsByTagName('audio')[0]; if(audio != undefined) { audio.play(); }");
  }

  @override
  void dispose() {
    _webViewController?.evaluateJavascript(
        source:
            "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.pause(); } var audio = document.getElementsByTagName('audio')[0]; if(audio != undefined) { audio.pause(); }");
    _textController?.dispose();
    _webViewController = null;
  }

  @override
  Future<bool> clearPrevious() async {
    await _webViewController?.evaluateJavascript(
        source:
            "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.pause(); } var audio = document.getElementsByTagName('audio')[0]; if(audio != undefined) { audio.pause(); }");
    return true;
  }

  updateWebviewSize() {
    if (_webViewController != null) {
      EasyDebounce.debounce(
          'screen_rotate', // <-- An ID for this particular debouncer
          const Duration(milliseconds: 100), // <-- The debounce duration
          () => _webViewController?.evaluateJavascript(
              source:
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
            ? noPreviewUrlWidget
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
            initialUrlRequest:
                inapp_webview_macos.URLRequest(url: Uri.tryParse(previewURL)),
            width: size.width,
            height: size.height,
            onWebViewCreated: (webViewController) async {
              _webViewController = webViewController;
              await _webViewController?.loadUrl(
                  urlRequest: inapp_webview_macos.URLRequest(
                      url: Uri.tryParse(previewURL)));
              _stateOfRenderingWidget.previewLoaded();
              onLoaded?.call();
              const javascriptString = '''
                  var meta = document.createElement('meta');
                              meta.setAttribute('name', 'viewport');
                              document.getElementsByTagName('head')[0].appendChild(meta);
                              document.body.style.overflow = 'hidden';
                  ''';
              await _webViewController?.runJavascript(javascriptString);
              _webViewController
                  ?.runJavascript("window.dispatchEvent(new Event('resize'));");
            },
            onLoadStop: (controller, url) async {},
            onDispose: () {
              _webViewController?.runJavascript(
                  "var video = document.getElementsByTagName('video')[0]; if(video != undefined) { video.pause(); }");
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
  void dispose() {}

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
    return previewURL.isEmpty ? noPreviewUrlWidget : _widgetBuilder();
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

/// Model viewer widget type
class ModelViewerRenderingWidget extends INFTRenderingWidget {
  ModelViewerRenderingWidget({
    RenderingWidgetBuilder? renderingWidgetBuilder,
  }) : super(
          renderingWidgetBuilder: renderingWidgetBuilder,
        );

  @override
  Widget build(BuildContext context) {
    return previewURL.isEmpty ? noPreviewUrlWidget : _widgetBuilder();
  }

  Widget _widgetBuilder() {
    return Stack(
      children: [
        ModelViewer(
          key: Key(previewURL),
          src: previewURL,
          ar: true,
          autoRotate: true,
          backgroundColor: Colors.black,
        ),
      ],
    );
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
