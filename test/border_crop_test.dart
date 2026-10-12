import 'dart:typed_data';

import 'package:dartotsu/Core/Reader/BorderCrop.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List page(int w, int h, {required int border, int ink = 60}) {
  final data = Uint8List(w * h * 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final inside =
          x >= border && x < w - border && y >= border && y < h - border;
      final v = inside ? ((x * 7 + y * 13) % 120) + ink : 255;
      final o = (y * w + x) * 4;
      data[o] = v;
      data[o + 1] = v;
      data[o + 2] = v;
      data[o + 3] = 255;
    }
  }
  return data;
}

void main() {
  test('white margins are cropped', () {
    final rect = cropRectFromPixels(page(100, 140, border: 12), 100, 140)!;
    expect(rect.left, closeTo(0.11, 0.02));
    expect(rect.right, closeTo(0.89, 0.02));
    expect(rect.top, closeTo(0.078, 0.02));
  });

  test('full bleed pages are left alone', () {
    expect(cropRectFromPixels(page(100, 140, border: 0), 100, 140), isNull);
  });

  test('a blank page is not cropped to nothing', () {
    final blank = Uint8List(100 * 100 * 4)..fillRange(0, 100 * 100 * 4, 255);
    expect(cropRectFromPixels(blank, 100, 100), isNull);
  });
}
