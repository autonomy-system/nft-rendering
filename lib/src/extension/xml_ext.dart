import 'package:xml/xml.dart';

// https://oreillymedia.github.io/Using_SVG/guide/units.html
const _absoluteLengthScale = {
  "": 1.0,
  "px": 1.0,
  "in": 96.0,
  "cm": 37.795,
  "mm": 3.779,
  "pt": 1.3333,
  "pc": 16
};

final _absoluteLengthPattern = RegExp(r"^(\d+(\.\d*)?)([A-Za-z]*)$");

extension XmlElementExtension on XmlElement {
  double _parseAbsoluteLength(String? text) {
    final matched = _absoluteLengthPattern.firstMatch(text ?? "");
    final value = double.tryParse(matched?.group(1) ?? "") ?? 0;
    final unit = matched?.group(3) ?? "";
    return value * (_absoluteLengthScale[unit] ?? 1.0);
  }

  double get absoluteWidth {
    String? width = getAttribute("width");
    return _parseAbsoluteLength(width);
  }

  double get absoluteHeight {
    String? width = getAttribute("height");
    return _parseAbsoluteLength(width);
  }
}
