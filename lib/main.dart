import 'package:campusconnect/screens/home.dart';
import 'package:campusconnect/screens/login.dart';
import 'package:campusconnect/screens/notifications.dart';
import 'package:campusconnect/screens/profile_page.dart';
import 'package:campusconnect/screens/project_create.dart';
import 'package:campusconnect/screens/project_list.dart';
import 'package:campusconnect/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before running the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Define the initial route of your app
      initialRoute: '/',
      // Register the routes used in the application
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(), // Register the HomePage route here
        '/signup': (context) => SignupPage(),
          '/profile': (context) => ProfilePage(),
          '/projects': (context) => ProjectListPage(),
        '/createProject': (context) => CreateProjectPage(),
        '/notifications': (context) => NotificationPage(),
      },
    );
  }
}
