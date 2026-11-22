import 'package:flutter_test/flutter_test.dart';
import 'package:rodape/main.dart';

void main() {
  test('RodapeApp deve ser criado', () {
    const app = RodapeApp(initialRoute: AppRoutes.onboarding);
    expect(app, isA<RodapeApp>());
  });
}
