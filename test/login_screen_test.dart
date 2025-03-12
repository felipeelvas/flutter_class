
import 'package:flutter/material.dart';
import 'package:flutter_class/login_scren.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('Should have a title', (WidgetTester tester) async {
    //Arrange
   await tester.pumpWidget(const MaterialApp(
        home: LoginScreen(),
    ));
    //Act
    Finder title = find.text('Sing in');
    //Assert
    expect(title, findsOneWidget);
  });

  testWidgets('Should have one text field form to collect user email id', (WidgetTester tester) async {
    //Arrange
    await tester.pumpWidget(const MaterialApp(
        home: LoginScreen(),
    ));
    //Act
    Finder userNameTextField = find.byKey(const ValueKey('email_id'));
    //Assert
    expect(userNameTextField, findsOneWidget);
  });

  testWidgets('Should have one text field form to collect password', (WidgetTester tester) async {
    //Arrange
    await tester.pumpWidget(const MaterialApp(
      home: LoginScreen(),
    ));
    //Act
    Finder passwordTextField = find.byKey(const ValueKey('password'));
    //Assert
    expect(passwordTextField, findsOneWidget);
  });

  testWidgets('Should have a button to submit the form', (WidgetTester tester) async {
    //Arrange
    await tester.pumpWidget(const MaterialApp(
      home: LoginScreen(),
    ));
    //Act
    Finder submitButton = find.byType(ElevatedButton);
    //Assert
    expect(submitButton, findsOneWidget);
  });
  
  testWidgets("Should show Required Fields error message if user email id & password is empty ", (WidgetTester tester) async {
    //Arrange
    await tester.pumpWidget(const MaterialApp(
      home: LoginScreen(),
    ));
    //Act
    Finder submitButton = find.byType(ElevatedButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    Finder errorTexts = find.text('Required Field');

    //Assert
    expect(errorTexts, findsNWidgets(2));
  });

  testWidgets("Should submit form when user email id & password is valid", (WidgetTester tester) async {
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
    Finder errorTexts = find.text('Required Field');

    //Assert
    expect(errorTexts, findsNothing);
  });
}