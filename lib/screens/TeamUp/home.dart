import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(200)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              // Navigate to the Profile page
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome text
            Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            SizedBox(height: 20),

            // Button to navigate to Team Up (Project List) Page
            ElevatedButton(
              onPressed: () {
                // Navigate to the Project List page
                Navigator.pushNamed(context, '/projects');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.orange, // Text color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Explore Projects (Team Up)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),

            // Add more buttons if needed, like Notifications or My Requests
            // Uncomment these if you want them on the Home Page
            
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/notifications');
            //   },
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.orange, // Button color
            //     onPrimary: Colors.white, // Text color
            //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //   ),
            //   child: Text('View Notifications'),
            // ),
            // SizedBox(height: 20),
            
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/myRequests');
            //   },
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.orange, // Button color
            //     onPrimary: Colors.white, // Text color
            //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //   ),
            //   child: Text('Go to My Requests'),
            // ),

          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/chat'); // Navigate to chat page
      //   },
      //   backgroundColor: Colors.orange,
      //   child: Icon(Icons.chat),
      //   tooltip: 'Chat',
      // ),
    );
  }
}
