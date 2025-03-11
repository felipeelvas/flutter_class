import 'package:flutter_class/maths_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Maths Utils -', () {
    test('check for two number addition', () {
      //Arrange
      var a = 17;
      var b = 13;
      //Act
      var sum = add(a, b);

      //Assert
      expect(sum, 30);
    });
    test('check for two number subtraction', () {
      //Arrange
      var a = 43;
      var b = 13;
      //Act
      var sub = subtract(a, b);

      //Assert
      expect(sub, 30);
    });

    test('check for two number multiplication', () {
      //Arrange
      var a = 3;
      var b = 13;
      //Act
      var mul = multiply(a, b);

      //Assert
      expect(mul, 39);
    });
  });

}