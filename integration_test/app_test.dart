import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:unistream/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("", (WidgetTester tester) async {
    //arrange
    app.main();
    await tester.pumpAndSettle();
    /* Tester le fonctionnement de l'app */
  });
}
