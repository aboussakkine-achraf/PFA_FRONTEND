import 'package:flutter/material.dart';
import 'api_service.dart'; // Make sure to import the ApiService
import 'sign_in_screen.dart'; // Import the SignIn screen

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // To track if passwords match
  bool _isPasswordMatch = true;
  bool _isUsernameEmpty = false;
  bool _isEmailEmpty = false;
  bool _isPasswordEmpty = false;
  bool _isConfirmPasswordEmpty = false;

  void _validatePassword() {
    setState(() {
      // Compare password and confirm password
      _isPasswordMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _validateForm() {
    setState(() {
      // Check if any fields are empty
      _isUsernameEmpty = _usernameController.text.isEmpty;
      _isEmailEmpty = _emailController.text.isEmpty;
      _isPasswordEmpty = _passwordController.text.isEmpty;
      _isConfirmPasswordEmpty = _confirmPasswordController.text.isEmpty;

      // Validate password matching
      _validatePassword();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        // Make the body scrollable
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
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _isEmailEmpty ? 'Email is required' : null,
                ),
                onChanged: (_) {
                  setState(() {
                    _isEmailEmpty = _emailController.text.isEmpty;
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
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  errorText: _isConfirmPasswordEmpty
                      ? 'Confirm password is required'
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _isConfirmPasswordEmpty =
                        _confirmPasswordController.text.isEmpty;
                  });
                  _validatePassword(); // Validate password match
                },
              ),
              // Display password mismatch error if needed
              if (!_isPasswordMatch)
                Text(
                  'Passwords do not match!',
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 20),
              // Center the sign-up button
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        _validateForm(); // Validate all fields

                        // If there are no errors, proceed to sign up logic
                        if (_isPasswordMatch &&
                            !_isUsernameEmpty &&
                            !_isEmailEmpty &&
                            !_isPasswordEmpty &&
                            !_isConfirmPasswordEmpty) {
                          // Call the registerUser method from ApiService
                          try {
                            String result = await ApiService.registerUser(
                              username: _usernameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            // If registration is successful, show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result)),
                            );

                            // Redirect to SignIn page after successful registration
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInScreen()),
                            );
                          } catch (e) {
                            // If registration fails, show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to register user')),
                            );
                          }
                        } else {
                          // Show a message or keep the error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Please fill in all fields correctly')),
                          );
                        }
                      },
                      child: Text('Sign Up'),
                    ),
                    SizedBox(height: 10),
                    // Sign In button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign In if you already have an account',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
