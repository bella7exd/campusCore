// lib/main.dart
import 'models/event.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import the generated Firebase options file. This file is created by
// flutterfire configure.
// If you see an error here, re-run flutterfire configure in your
// project root.
import 'firebase_options.dart';
// Import custom services and screens
// Ensure this path is correct based on your project name
import 'login_screen.dart'; // Ensure this path is correct
import 'signup_screen.dart'; // Ensure this path is correct
import 'home_screen.dart';
import 'user_profile_screen.dart';
import 'goal_task_manager_screen.dart';
import 'add_edit_goal_screen.dart';
import 'goal_model.dart'; 

// Import the necessary screens for Alumni and Faculty (only detail screens remain here)
import 'alumni_screen.dart';
import 'alumni_detail_screen.dart'; // New

import 'faculty_screen.dart';
import 'faculty_detail_screen.dart'; // New

import 'guidance_screen.dart'; // Placeholder screen
import 'event_detail_screen.dart'; // Import the event detail screen
import 'add_event_screen.dart';

// Import the data models
import 'models/alumni_model.dart'; // Import AlumniModel
import 'models/faculty_model.dart'; // Import FacultyModel

void main() async {
  // Ensure Flutter widgets are initialized before Firebase. This is crucial.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated options for the current platform.
  // This must be called before using any Firebase services.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // print('Firebase initialized successfully!'); // For debugging, consider removing in prod
  } catch (e) {
    // print('Error initializing Firebase: $e'); // Avoid print in production
    // Consider showing an error dialog or handling this more gracefully in a real app.
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Core',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 237, 232, 232),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Define AppBarTheme globally for consistent styling
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0E1A40), // Hogwarts Blue
            foregroundColor: Color(0xFFD3A625), // Gold Accent for icons and text
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'HarryPotterFont',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD3A625), // Gold Accent
            ),
          )),
      // Define your routes
      initialRoute: '/', // Or '/login' if you want login to be the first screen
      routes: {
        // Updated to use the correct class names directly without 'new' or 'const' if not needed
        '/': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  return HomeScreen(); // User is logged in
                }
                return LoginScreen(); // User is not logged in, show login
              },
            ),
        '/login': (context) => LoginScreen(), // Correctly referencing LoginScreen
        '/signup': (context) => SignupScreen(), // Correctly referencing SignupScreen
        '/home': (context) => HomeScreen(),
        '/profile': (context) => UserProfileScreen(),
        '/goals': (context) => GoalTaskManagerScreen(),
        '/alumni': (context) => AlumniScreen(),
        '/faculty': (context) => FacultyScreen(),
        '/guidance': (context) => StudentRoadmapScreen(), 
        // Removed direct instantiation of AddEdit screens from 'routes' map
        // as they are now handled by user_profile_screen.dart
      },
      // Use onGenerateRoute for routes that might receive arguments
      onGenerateRoute: (settings) {
        // Handle both adding and editing goals through a single route
        if (settings.name == '/add_edit_goal') {
          // If arguments are passed, it's an edit operation; otherwise, it's an add operation.
          final Goal? goal = settings.arguments as Goal?;
          return MaterialPageRoute(
            builder: (context) {
              return AddEditGoalScreen(goal: goal);
            },
          );
        }
        // Handle alumni detail
        else if (settings.name == '/alumni_detail') {
          final Alumni alumni = settings.arguments as Alumni;
          return MaterialPageRoute(
            builder: (context) {
              return AlumniDetailScreen(alumni: alumni);
            },
          );
        }
        // REMOVED: else if (settings.name == '/add_edit_alumni') - no longer needed here

        // Handle faculty detail
        else if (settings.name == '/faculty_detail') {
          final Faculty faculty = settings.arguments as Faculty;
          return MaterialPageRoute(
            builder: (context) {
              return FacultyDetailScreen(faculty: faculty);
            },
          );
        }
        // REMOVED: else if (settings.name == '/add_edit_faculty') - no longer needed here

        else if (settings.name == '/event_detail') {
          final Event event = settings.arguments as Event;
          return MaterialPageRoute(
            builder: (context) {
              return EventDetailScreen(event: event);
            },
          );
        } else if (settings.name == '/add_event') {
          // Handle AddEventScreen route
          final Event? event = settings.arguments as Event?; // For potential future editing
          return MaterialPageRoute(
            builder: (context) {
              return AddEventScreen(event: event);
            },
          );
        }
        return null;
      },
    );
  }
}