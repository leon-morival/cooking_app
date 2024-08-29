import 'package:cooking_app/auth/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/shopping_item.dart'; // Ensure to import your model
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cooking_app/views/main_page.dart'; // Import your main page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the adapter for ShoppingItem
  Hive.registerAdapter(ShoppingItemAdapter());

  // Open the 'shopping_box' box
  await Hive.openBox<ShoppingItem>('shopping_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.aliceTextTheme(
          Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.black, displayColor: Colors.black),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return MainPage(); // Redirect to MainPage if user is logged in
          } else {
            return LoginPage(); // Redirect to LoginScreen if user is not logged in
          }
        }
        return CircularProgressIndicator(); // Show a loading spinner while waiting
      },
    );
  }
}
