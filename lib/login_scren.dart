import 'package:flutter/material.dart';
import 'package:flutter_class/validator.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

  class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _Key = GlobalKey<FormState>();

  get validator => null;

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.deepPurple,
      title: const Text('Sing in'),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _Key,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              key: const ValueKey('email_id'),
              decoration: const InputDecoration(labelText: 'Enter Email ID'),
              validator: (value) => Validator.validateEmail(value ?? ""),
            ),
            TextFormField(
              controller: _passwordController,
              key: const ValueKey('password'),
              decoration: const InputDecoration(labelText: 'Enter Password'),
              validator: (value) => Validator.validatePassword(value ?? ""),
            ),
            const SizedBox(height: 20, width: 20 ,
            ),
            ElevatedButton(
              onPressed: () {
               if (_Key.currentState!.validate() == true) {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
               }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    ),
  );
  }
}