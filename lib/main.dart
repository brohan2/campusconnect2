import 'package:campusconnect/screens/Connections/all_users.dart';
import 'package:campusconnect/screens/TeamUp/my_projects.dart';
import 'package:campusconnect/screens/Threads/thread_page.dart';
import 'package:campusconnect/screens/home.dart';
import 'package:campusconnect/screens/Threads/create_thread.dart';
import 'package:campusconnect/screens/authentications/login.dart';
import 'package:campusconnect/screens/TeamUp/my_requests_page.dart';
import 'package:campusconnect/screens/TeamUp/notifications.dart';
import 'package:campusconnect/screens/TeamUp/profile_page.dart';
import 'package:campusconnect/screens/TeamUp/project_create.dart';
import 'package:campusconnect/screens/TeamUp/project_list.dart';
import 'package:campusconnect/screens/authentications/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before running the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/signup': (context) => SignupPage(),
        '/profile': (context) => ProfilePage(),
        '/projects': (context) => ProjectListPage(),
        '/createProject': (context) => CreateProjectPage(),
        '/notifications': (context) => NotificationsPage(),
        '/myRequests': (context) => MyRequestsPage(),
        '/threadpage': (context) => ThreadsPage(),
        '/myProjects' : (context) => MyProjectsPage(),
        // Use a builder function to pass the UID to UserListPage
        '/allusers': (context) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            return UserListPage(currentUserId: currentUser.uid);
          } else {
            return LoginPage(); // Fallback in case the user is not authenticated
          }
        },
      },
    );
  }
}
