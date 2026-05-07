import 'package:flutter_test/flutter_test.dart';

import 'package:crudapi/main.dart';

void main() {
  testWidgets('Affiche la page de connexion', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('WoodyCraft Admin'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
