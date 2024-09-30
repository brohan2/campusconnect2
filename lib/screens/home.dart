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
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.2, // Adjust the opacity for a subtle background
              child: Image.asset(
                'assets/backgroud.webp', // Path to the background image
                fit: BoxFit.cover, // Cover the whole screen
              ),
            ),
          ),

          // Split screen into two halves using a Row
          Row(
            children: [
              // Left half (Team Up section)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the Project List page
                    Navigator.pushNamed(context, '/projects');
                  },
                  child: Container(
                    color: Colors.orange.withOpacity(0.2), // Light orange color
                    child: Center(
                      child: Text(
                        'Team Up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Right half (Threads section)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the Thread page
                    Navigator.pushNamed(context, '/threadpage');
                  },
                  child: Container(
                    color: Colors.blue.withOpacity(0.2), // Light blue color
                    child: Center(
                      child: Text(
                        'Threads',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
