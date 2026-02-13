import 'package:flutter_test/flutter_test.dart';

import 'package:nedo_halo/main.dart';

void main() {
  testWidgets('NedoHaloApp renders intro screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NedoHaloApp());

    expect(find.text('Welcome to HALO'), findsOneWidget);
    expect(find.text('Caregiver'), findsOneWidget);
  });
}
