import 'package:flutter/material.dart';
import 'login/login_form.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('LOGIN ABSEN SMKN 2 DEPOK'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: LoginForm(),
          ),
        ),
      ),
    );
  }
}
