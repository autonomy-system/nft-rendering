import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';
import 'package:http/http.dart' as http;
import 'package:nft_rendering/src/extension/xml_ext.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart';

class SvgImage extends StatefulWidget {
  final String url;
  final bool fallbackToWebView;
  final BaseCacheManager? cacheManager;
  final WidgetBuilder? loadingWidgetBuilder;
  final WidgetBuilder? errorWidgetBuilder;
  final WidgetBuilder? unsupportWidgetBuilder;
  final VoidCallback? onLoaded;
  final VoidCallback? onError;

  const SvgImage({
    super.key,
    required this.url,
    this.fallbackToWebView = false,
    this.cacheManager,
    this.loadingWidgetBuilder,
    this.errorWidgetBuilder,
    this.onLoaded,
    this.onError,
    this.unsupportWidgetBuilder,
  });

  @override
  State<StatefulWidget> createState() {
    return _SvgImageState();
  }
}

class _SvgImageState extends State<SvgImage> {
  final Completer<String> _svgString = Completer();
  bool _webviewLoadFailed = false;

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    Future(() async {
      String? svg;
      try {
        if (widget.cacheManager != null) {
          final cachedFile =
              await widget.cacheManager?.getSingleFile(widget.url);
          svg = await cachedFile?.readAsString() ?? "";
        } else {
          final resp = await http.get(Uri.parse(widget.url));
          svg = resp.body;
        }
        if (widget.fallbackToWebView && Platform.isIOS) {
          final screenSize = MediaQuery.of(context).size;
          svg = await _scaleSvgImage(
            svgData: svg,
            maxSize: min(screenSize.width, screenSize.height) * 0.95,
          );
        }
        await SvgParser().parse(svg, warningsAsErrors: true);
        _svgString.complete(svg);
      } catch (e) {
        if (svg != null) {
          _svgString.completeError(SvgNotSupported(svg));
        } else {
          _svgString.completeError(e);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _svgString.future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SvgPicture.string(snapshot.data ?? "");
        } else if (snapshot.error is SvgNotSupported &&
            widget.fallbackToWebView &&
            !_webviewLoadFailed) {
          final svgData = (snapshot.error as SvgNotSupported).svgData;
          return AspectRatio(
            aspectRatio: 1,
            child: WebView(
              key: Key(widget.url),
              zoomEnabled: false,
              javascriptMode: JavascriptMode.unrestricted,
              allowsInlineMediaPlayback: true,
              backgroundColor: Colors.transparent,
              onWebViewCreated: (controller) {
                controller.loadHtmlString(svgData);
              },
              onPageFinished: (_) {
                widget.onLoaded?.call();
              },
              onWebResourceError: (WebResourceError error) {
                setState(() {
                  _webviewLoadFailed = true;
                });
              },
            ),
          );
        } else if (snapshot.error is SvgNotSupported &&
            !widget.fallbackToWebView) {
          return widget.unsupportWidgetBuilder?.call(context) ??
              const SizedBox();
        } else if (snapshot.hasError || _webviewLoadFailed) {
          return widget.errorWidgetBuilder?.call(context) ?? const SizedBox();
        } else {
          return widget.loadingWidgetBuilder?.call(context) ?? const SizedBox();
        }
      },
    );
  }
}

class SvgNotSupported {
  final String svgData;

  SvgNotSupported(this.svgData);
}

Future<String> _scaleSvgImage({
  required String svgData,
  required double maxSize,
}) async {
  return compute<List, String>((data) {
    final svg = data[0] as String;
    final size = data[1] as double;
    final doc = XmlDocument.parse(svg);
    final root = doc.findElements("svg").first;
    final width = root.absoluteWidth;
    final height = root.absoluteHeight;
    if (width < size && height < size) {
      return svgData;
    } else {
      final ratio = width / height;
      if (ratio > 1) {
        root.setAttribute("width", "$size");
        root.setAttribute("height", "${size / ratio}");
      } else {
        root.setAttribute("width", "${size * ratio}");
        root.setAttribute("height", "$size");
      }
      return doc.toXmlString();
    }
  }, [svgData, maxSize]);
}
