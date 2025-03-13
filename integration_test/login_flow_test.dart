
import 'package:flutter/material.dart';
import 'package:flutter_class/login_scren.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  group('Login Flow Test', () {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Should show Required Fields error message when user taps on login button without entering email id & password ',
          (WidgetTester tester) async{
        //Arrange
        await tester.pumpWidget(const MaterialApp(
          home: LoginScreen(),
        ));
        //Act
        Finder submitButton = find.byType(ElevatedButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle(Duration(seconds: 2));

        Finder errorText = find.text('Required Fields');

        expect(errorText, findsNWidgets(2));
      });

  testWidgets('Should show home screen when user taps on login button after entering valid email id & password ',
      (WidgetTester tester) async{
        //Arrange
        await tester.pumpWidget(const MaterialApp(
          home: LoginScreen(),
        ));
        //Act
        Finder userNameTextField = find.byKey(const ValueKey('email_id'));
        Finder passwordTextField = find.byKey(const ValueKey('password'));
        await tester.enterText(userNameTextField, "felipe@email.com");
        await tester.enterText(passwordTextField, "password");

        Finder submitButton = find.byType(ElevatedButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        Finder welcomeText = find.byType(Text);

        expect(welcomeText, findsOneWidget);
    });
  });
}