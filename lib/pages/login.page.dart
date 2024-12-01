import 'package:flutter/material.dart';
import 'package:todo_app/database/handler.dart';
import 'package:todo_app/database/schemas/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/pages/widgets/app_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if the user is registered
      DatabaseHandler db = DatabaseHandler();
      User? user = await db.getUserByEmail(_email);
      if (user != null && user.password == _password) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('currentUserId', user.id!);
        Navigator.pushReplacementNamed(context, '/tasks');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Login'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Login'),
              ),
              TextButton(
                child: const Text('Don\'t have an account? Register'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
