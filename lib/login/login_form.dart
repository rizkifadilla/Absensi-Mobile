import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for TextInputFormatter
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../mainMenu/main_screen.dart'; // Import the MainScreen

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _userController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String password = _passwordController.text;
      String user = _userController.text;

      try {
        // Make API request
        var url = Uri.parse('http://192.168.45.148/absensi-online/login');
        var response = await http.post(
          url,
          body: jsonEncode({'username': user, 'password': password}),
          headers: {'Content-Type': 'application/json'},
        );

        // Handle response
        if (response.statusCode == 200) {
          // Parse JSON response
          var data = jsonDecode(response.body);

          // Navigate to MainScreen and pass user data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                userData: data['data'],
              ),
            ),
          );
        } else {
          var data = jsonDecode(response.body);
          String errorMessage = data['message'];
          if (errorMessage.isNotEmpty) {
            // Handle error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login failed: $errorMessage')),
            );
          }
        }
      } catch (e) {
        // Catch any exceptions or errors
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 150,
            ),
            SizedBox(height: 24.0),
            Text(
              'Login',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.0),
            TextFormField(
              controller: _userController,
              decoration: InputDecoration(
                labelText: 'User',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your user';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => _login(context), // Pass context here
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _userController.dispose();
    super.dispose();
  }
}
