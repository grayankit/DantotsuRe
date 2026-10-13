import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dartotsu/Core/Downloads/Archives.dart';
import 'package:flutter_test/flutter_test.dart';

ArchiveFile file(String name, List<int> bytes) =>
    ArchiveFile(name, bytes.length, bytes);

ArchiveFile text(String name, String content) =>
    file(name, utf8.encode(content));

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('archives'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('recognises comic and book files', () {
    expect(isComicArchive('/a/Chapter 1.CBZ'), isTrue);
    expect(isComicArchive('/a/Chapter 1.zip'), isTrue);
    expect(isComicArchive('/a/Chapter 1.epub'), isFalse);
    expect(isBookFile('/a/Vol 3.epub'), isTrue);
  });

  test('natural order puts 2 before 10', () {
    final names = ['10.jpg', '2.jpg', '1.jpg']..sort(naturalCompare);
    expect(names, ['1.jpg', '2.jpg', '10.jpg']);
  });

  test('a cbz is unpacked into ordered pages', () async {
    final archive = Archive()
      ..add(file('10.jpg', [10]))
      ..add(file('2.jpg', [2]))
      ..add(file('__MACOSX/2.jpg', [9]))
      ..add(file('.hidden.png', [9]))
      ..add(text('readme.txt', 'hi'))
      ..add(file('1.png', [1]));
    final cbz = File('${dir.path}/Chapter 1.cbz')
      ..writeAsBytesSync(ZipEncoder().encode(archive));
    final pages = await extractComic(cbz.path, '${dir.path}/out');
    expect(pages.length, 3);
    expect(pages.map((f) => File(f).readAsBytesSync().first), [1, 2, 10]);
    final again = await extractComic(cbz.path, '${dir.path}/out');
    expect(again, pages);
  });

  test('an epub becomes one html document with local images', () async {
    final archive = Archive()
      ..add(
        text(
          'META-INF/container.xml',
          '<container><rootfiles><rootfile full-path="OEBPS/content.opf"/></rootfiles></container>',
        ),
      )
      ..add(
        text(
          'OEBPS/content.opf',
          '<package><manifest>'
              '<item id="a" href="ch1.xhtml"/><item id="b" href="text/ch2.xhtml"/>'
              '</manifest><spine><itemref idref="b"/><itemref idref="a"/></spine></package>',
        ),
      )
      ..add(
        text(
          'OEBPS/ch1.xhtml',
          '<html><body><p>First</p><img src="img/a.png"/></body></html>',
        ),
      )
      ..add(
        text(
          'OEBPS/text/ch2.xhtml',
          '<html><body><p>Second</p><script>x()</script></body></html>',
        ),
      )
      ..add(file('OEBPS/img/a.png', [1, 2, 3]));
    final epub = File('${dir.path}/Volume 3.epub')
      ..writeAsBytesSync(ZipEncoder().encode(archive));
    final out = await epubToHtml(epub.path, '${dir.path}/files');
    expect(out.indexOf('Second'), lessThan(out.indexOf('First')));
    expect(out.contains('x()'), isFalse);
    final src = RegExp(r'src="([^"]+)"').firstMatch(out)!.group(1)!;
    expect(File(src).existsSync(), isTrue);
  });
}
