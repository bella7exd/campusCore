// lib/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
class AuthService {
  // Get an instance of Firebase Authentication
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // for consistency

  // Stream to listen to authentication state changes
  Stream<User?> get userStream => _firebaseAuth.authStateChanges();

  // Method to sign up a new user with email and password.
  // Returns the UserCredential object if successful, otherwise throws FirebaseAuthException.
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return userCredential; // Return the UserCredential
    } on FirebaseAuthException {
      // Re-throw the FirebaseAuthException so the UI can catch and display specific errors
      rethrow;
    } catch (e) {
      print('Sign Up Error: $e');
      return null;
    }
  }

  // Method to sign in an existing user with email and password.
  // Returns the UserCredential object if successful, otherwise throws FirebaseAuthException.
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential; // Return the UserCredential
    } on FirebaseAuthException {
      // Re-throw the FirebaseAuthException so the UI can catch and display specific errors
      rethrow;
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }
   // Method to sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential with the access token and ID token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if this is a new user or existing user
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // New user signing up with Google
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? '',
            'role': 'student', // Default role for Google sign-ups (you can change this)
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Google Error: ${e.code} - ${e.message}');
      rethrow; // Re-throw to handle in UI
    } catch (e) {
      print('Google Sign-In Error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Method to sign out the currently authenticated user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  // Method to get the currently authenticated user (convenience method)
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}