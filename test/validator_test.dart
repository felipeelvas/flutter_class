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

}