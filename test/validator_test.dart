import 'package:flutter_class/validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  test('Validate for empty email', () {
  //Arrange & Act
    var result = Validator.validateEmail('');

    //Assert
    expect(result, 'Email is required');
  });

  test('Validate for invalid email', () {
    //Arrange & Act
    var result = Validator.validateEmail('test');

    //Assert
    expect(result, 'Please enter a valid email');
  });

  test('Validate for valid email', () {
    //Arrange & Act
    var result = Validator.validateEmail('exemplo@email.com');
    //Assert
    expect(result, null);
  });

  test('Validate for empty password', () {
    //Arrange & Act
    var result = Validator.validatePassword('');

    //Assert
    expect(result, 'Password is required');
  });

  test('Validate for password with less than 6 characters', () {
    //Arrange & Act
    var result = Validator.validatePassword('pass');

    //Assert
    expect(result, 'Password must be at least 6 characters long');
  });

  test('Validate for valid password', () {
    //Arrange & Act
    var result = Validator.validatePassword('password');

    //Assert
    expect(result, null);
  });

}