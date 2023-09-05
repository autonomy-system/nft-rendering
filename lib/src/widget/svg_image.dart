import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';
import 'package:xml/xml.dart';

class SvgImage extends StatefulWidget {
  final String url;
  final String userAgent;
  final bool fallbackToWebView;
  final BaseCacheManager? cacheManager;
  final WidgetBuilder? loadingWidgetBuilder;
  final WidgetBuilder? errorWidgetBuilder;
  final WidgetBuilder? unsupportWidgetBuilder;
  final VoidCallback? onLoaded;
  final VoidCallback? onError;

  const SvgImage({
    super.key,
    this.userAgent = "",
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
        if (widget.fallbackToWebView) {
          svg = await _fixSvgSize(
            svgData: svg,
          );
        }
        parse(svg);
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
            !_webviewLoadFailed &&
            !Platform.isMacOS) {
          final svgData = (snapshot.error as SvgNotSupported).svgData;

          return AspectRatio(
            aspectRatio: 1,
            child: InAppWebView(
              key: Key(widget.url),
              initialUrlRequest: URLRequest(url: Uri.tryParse(widget.url)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  userAgent: widget.userAgent,
                  supportZoom: false,
                  transparentBackground: true,
                ),
                ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
              ),
              onWebViewCreated: (controller) {},
              onLoadStop: (controller, uri) {
                widget.onLoaded?.call();
              },
              onLoadError: (controller, uri, code, message) {
                setState(() {
                  _webviewLoadFailed = true;
                });
              },
            ),
          );
        }
        if (snapshot.error is SvgNotSupported && !widget.fallbackToWebView) {
          return widget.unsupportWidgetBuilder?.call(context) ??
              const SizedBox();
        }
        if (snapshot.hasError || _webviewLoadFailed) {
          return widget.errorWidgetBuilder?.call(context) ?? const SizedBox();
        }
        return widget.loadingWidgetBuilder?.call(context) ?? const SizedBox();
      },
    );
  }
}

class SvgNotSupported {
  final String svgData;

  SvgNotSupported(this.svgData);
}

Future<String> _fixSvgSize({
  required String svgData,
}) async {
  return compute<String, String>((svg) {
    final doc = XmlDocument.parse(svg);
    final root = doc.findElements("svg").first;
    root.setAttribute("width", "100%");
    root.setAttribute("height", "100%");
    return doc.toXmlString();
  }, svgData);
}
