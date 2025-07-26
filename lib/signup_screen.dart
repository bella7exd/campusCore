import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final Color _hogwartsBlue = const Color(0xFF0E1A40); 
  final Color _hogwartsBlueDarker = const Color(0xFF0A1433); 
  final Color _gryffindorRed = const Color(0xFF740001);
  final Color _goldAccent = const Color(0xFFD3A625); 
  final Color _darkText = const Color(0xFF333333); 
  final Color _parchmentColor = const Color(0xFFF0EAD6); 

  final List<String> _roles = ['Student', 'Faculty', 'Alumni', 'Admin'];
  String _selectedRole = 'Student'; // Default role

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? userCredential = await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(), // Use trim to remove leading/trailing whitespace
        _passwordController.text.trim(), // Use trim
      );

      if (userCredential != null && userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': _emailController.text.trim(), // Store trimmed email
          'name': _usernameController.text.trim(), // Store trimmed username
          'role': _selectedRole.toLowerCase(), // Store as lowercase for easy comparison
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Enrollment successful! Welcome to Hogwarts!', style: TextStyle(color: Colors.white)),
              backgroundColor: _gryffindorRed,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Your magical incantation (password) is too weak. Choose a stronger one!'; // Themed
      } else if (e.code == 'email-already-in-use') {
        message = 'This Owl Post address is already registered in the Ministry records.'; // Themed
      } else if (e.code == 'invalid-email') {
        message = 'That\'s not a valid Owl Post address. Please check your spelling.'; // Themed
      }
      else {
        message = 'Enrollment failed: ${e.message}. The Sorting Hat is currently unavailable.'; // Themed
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: _gryffindorRed),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected magical glitch occurred: $e', style: const TextStyle(color: Colors.white)), backgroundColor: _gryffindorRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_hogwartsBlue, _hogwartsBlueDarker], // Themed gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enroll at Hogwarts', // Themed title
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'HarryPotterFont', // Custom font
                    shadows: [
                      Shadow(
                        blurRadius: 15.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(5.0, 5.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Username Input
                _buildTextField(
                  controller: _usernameController,
                  hintText: 'Your Wizard Name', // Themed hint
                  icon: Icons.person_outline, // Themed icon
                  isPassword: false,
                ),
                const SizedBox(height: 20),

                // Email Input
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Owl Post Address (Email)', // Themed hint
                  icon: Icons.mail_outline, // Themed icon
                  isPassword: false,
                ),
                const SizedBox(height: 20),

                // Password Input
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Choose a Secret Incantation (Password)', // Themed hint
                  icon: Icons.lock_outline, // Themed icon
                  isPassword: true,
                ),
                const SizedBox(height: 20),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(
                        _getThemedRoleName(role), // Themed role names
                        style: TextStyle(color: _darkText), // Themed text color
                      ),
                    );
                  }).toList(),
                  dropdownColor: _parchmentColor, // Themed dropdown background
                  decoration: InputDecoration(
                    hintText: 'Select Your House/Role', // Themed hint
                    hintStyle: TextStyle(color: _darkText.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.95), // Themed fill
                    prefixIcon: Icon(Icons.shield_outlined, color: _goldAccent), // Themed icon
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _goldAccent, width: 2.5), // Themed focused border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _hogwartsBlue.withOpacity(0.5), width: 1.5), // Themed enabled border
                    ),
                  ),
                  style: TextStyle(color: _darkText), // Text in dropdown
                ),
                const SizedBox(height: 30),

                // Signup Button
                _isLoading
                    ? CircularProgressIndicator(color: _goldAccent) // Themed progress indicator
                    : ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gryffindorRed, // Themed button color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.6),
                        ),
                        child: const Text(
                          'Get Sorted!', // Themed button text
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'HarryPotterFont'), // Custom font
                        ),
                      ),
                const SizedBox(height: 20),

                // Redirect to Login
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text(
                    "Already have a wand? Enter Hogwarts!", // Themed prompt
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress, // Ensure email keyboard for email field
      obscureText: isPassword ? _obscurePassword : false,
      style: TextStyle(color: _darkText),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: _darkText.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.95),
        prefixIcon: Icon(icon, color: _goldAccent),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: _goldAccent,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _goldAccent, width: 2.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _hogwartsBlue.withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }

  String _getThemedRoleName(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'Hogwarts Student';
      case 'faculty':
        return 'Hogwarts Professor';
      case 'alumni':
        return 'Order of the Phoenix Member';
      case 'admin':
        return 'Ministry Official';
      default:
        return role;
    }
  }
}