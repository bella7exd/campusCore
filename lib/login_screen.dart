import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  final Color _hogwartsBlue = const Color(0xFF0E1A40); 
  final Color _gryffindorRed = const Color(0xFF740001);
  final Color _goldAccent = const Color(0xFFD3A625); 
  final Color _darkText = const Color(0xFF333333); 
  final Color _parchmentColor = const Color(0xFFF0EAD6); 

  final List<String> _roles = ['Student', 'Faculty', 'Alumni', 'Admin'];
  String _selectedRole = 'Student'; // Default role

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in user
      UserCredential? userCredential = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = userCredential?.user;

      if (user != null) {
        // Fetch role from Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists || !userDoc.data()!.containsKey('role')) {
          throw Exception('Your wizarding role was not found. Please contact the Headmaster.'); // Themed error
        }

        final savedRole = userDoc['role'];

        if (savedRole.toLowerCase() != _selectedRole.toLowerCase()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Role mismatch! You're trying to log in as $_selectedRole but your registered role is $savedRole. Please ensure your Sorting Hat choice is correct."), // Themed message
                backgroundColor: _gryffindorRed), // Themed error color
          );
          FirebaseAuth.instance.signOut();
          return;
        }

        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No wizard found for that Owl Post address.'; // Themed message
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect incantation! (Wrong password provided).'; // Themed message
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid Owl Post address or incantation.'; // Themed message
      } else {
        message = 'Login failed: ${e.message}. The Sorting Hat is confused.'; // Themed message
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: _gryffindorRed)); // Themed snackbar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An unexpected magical anomaly occurred: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: _gryffindorRed)); // Themed snackbar
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Magical blue/purple gradient for background
          gradient: LinearGradient(
            colors: [_hogwartsBlue, _hogwartsBlue.withBlue(_hogwartsBlue.blue + 50)],
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
                  'Welcome Back, Wizard!', // Themed title
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'HarryPotterFont', // Apply custom font
                    shadows: [
                      Shadow(
                        blurRadius: 15.0, // Increased blur
                        color: Colors.black.withOpacity(0.5), // Darker shadow
                        offset: const Offset(5.0, 5.0), // More offset
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Owl Post Address', // Themed hint
                  icon: Icons.mail_outline, // Themed icon
                  isPassword: false,
                ),
                const SizedBox(height: 20),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Secret Incantation (Password)', // Themed hint
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
                    hintText: 'Choose Your House/Role', // Themed hint
                    hintStyle: TextStyle(color: _darkText.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9), // Slightly transparent white fill
                    prefixIcon: Icon(Icons.shield_outlined, color: _goldAccent), // Themed icon
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _goldAccent, width: 2), // Themed focused border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _hogwartsBlue.withOpacity(0.5), width: 1), // Themed enabled border
                    ),
                  ),
                  style: TextStyle(color: _darkText), // Text in dropdown
                ),
                const SizedBox(height: 30),

                // Login Button
                _isLoading
                    ? CircularProgressIndicator(color: _goldAccent) // Themed progress indicator
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gryffindorRed, // Themed button color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18), // Larger padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // More rounded
                          ),
                          elevation: 8, // More prominent shadow
                          shadowColor: Colors.black.withOpacity(0.6), // Darker shadow
                        ),
                        child: const Text(
                          'Enter Hogwarts', // Themed button text
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'HarryPotterFont'), // Custom font
                        ),
                      ),
                const SizedBox(height: 20),

                // Navigate to Signup
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/signup');
                  },
                  child: Text(
                    "No wand yet? Get sorted into a House!", // Themed prompt
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
      obscureText: isPassword ? _obscurePassword : false,
      style: TextStyle(color: _darkText), // Themed text color for input
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: _darkText.withOpacity(0.6)), // Themed hint color
        filled: true,
        fillColor: Colors.white.withOpacity(0.95), // Slightly more opaque white for input background
        prefixIcon: Icon(icon, color: _goldAccent), // Themed icon color
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: _goldAccent, // Themed visibility toggle icon
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // More rounded
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _goldAccent, width: 2.5), // Thicker, gold focus border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _hogwartsBlue.withOpacity(0.5), width: 1.5), // Subtle blue border
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