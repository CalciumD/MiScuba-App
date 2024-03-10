import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:misuba2/firebase_auth_services.dart/firebase_auth_service.dart';
import 'package:misuba2/loginpage.dart';
import 'package:misuba2/mainpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageStates();
}

class _RegisterPageStates extends State<RegisterPage> {
  final FirebaseAuthServce _auth = FirebaseAuthServce();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signUpWithEmaulAndPassword(email, password);

    if (user != null) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    } else {
      print("User already assigned");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff6495ed),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                child: Container(
                  height: 150.0,
                  width: 190.0,
                  padding: const EdgeInsets.only(top: 40),
                  child: Image.asset('asset/images/scubawhite.png'),
                ),
              ),
            ),
            // Username ADDRESSS ONE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                controller: _usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter valid username'),
              ),
            ),
            // CONFIRM EMAIL ADDRESS TWO
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Confirm Email Address',
                ),
              ),
            ),
            //  PASSWORD ONE
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            // Forgot Password
            TextButton(
              onPressed: () {
                // FOROGT PASSWORD SCREEN
              },
              child: const Text(
                '',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
            // Sign Up Button
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                color: const Color(0xff673AB7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  _signUp();
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            // Login Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text(
                  'Login In',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
