import 'package:flutter/material.dart';
import 'api_service.dart'; // Import your ApiService
import 'extraction.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isUsernameEmpty = false;
  bool _isPasswordEmpty = false;
  bool _isLoading = false; // To show loading indicator during API call

  void _validateForm() {
    setState(() {
      _isUsernameEmpty = _usernameController.text.isEmpty;
      _isPasswordEmpty = _passwordController.text.isEmpty;
    });
  }

  // Call the login method
  void _login() async {
    _validateForm();

    if (!_isUsernameEmpty && !_isPasswordEmpty) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        bool isLoggedIn = await ApiService.login(
          _usernameController.text,
          _passwordController.text,
        );

        if (isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful')),
          );
          // Navigate to the MainScreen
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => MainScreen()), // Replace with MainScreen
          // );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ExtractionPage()),
            (route) => false, // Removes all previous routes
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: _isUsernameEmpty ? 'Username is required' : null,
                ),
                onChanged: (_) {
                  setState(() {
                    _isUsernameEmpty = _usernameController.text.isEmpty;
                  });
                },
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: _isPasswordEmpty ? 'Password is required' : null,
                ),
                onChanged: (_) {
                  setState(() {
                    _isPasswordEmpty = _passwordController.text.isEmpty;
                  });
                },
              ),
              SizedBox(height: 20),
              // Sign In Button
              Center(
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _login, // Disable button when loading
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
