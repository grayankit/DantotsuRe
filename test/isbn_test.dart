import 'package:dartotsu/Core/Services/Api/IsbnLookup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeIsbn accepts 10 and 13 digit codes', () {
    expect(normalizeIsbn('978-1-9747-3647-4'), '9781974736474');
    expect(normalizeIsbn('4088725093'), '4088725093');
    expect(normalizeIsbn('abc'), isNull);
    expect(normalizeIsbn('12345'), isNull);
  });

  test('cleanBookTitle drops volume markers and editions', () {
    expect(cleanBookTitle('Berserk, Vol. 3'), 'Berserk');
    expect(cleanBookTitle('Chainsaw Man, Vol. 1'), 'Chainsaw Man');
    expect(
      cleanBookTitle('Spice and Wolf, Vol. 1 (light novel)'),
      'Spice and Wolf',
    );
    expect(cleanBookTitle('Frieren: Beyond Journey\'s End, Vol. 2'), 'Frieren');
    expect(cleanBookTitle('Vinland Saga Volume 5'), 'Vinland Saga');
    expect(cleanBookTitle('Monster 2'), 'Monster');
    expect(cleanBookTitle('86'), '86');
  });
}
