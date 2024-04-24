import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1/provider/auth_provider.dart';
import 'package:v1/screens/onboarding/onboarding_scrreen.dart';
import 'package:v1/screens/profile/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Add this variable to track the selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate based on the selected index
    if (_selectedIndex == 0) {
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (_selectedIndex == 2) {
      // Navigate to ProfileScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        items: const [  CurvedNavigationBarItem(child:Icon(Icons.home,color: Color.fromARGB(255, 55, 55, 55),)),
      CurvedNavigationBarItem(child: Icon(Icons.maps_home_work,
                    color: Color.fromARGB(255, 55, 55, 55))),
      CurvedNavigationBarItem(child: Icon(Icons.person, color: Color.fromARGB(255, 55, 55, 55))),],

        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        color: const Color(0xFFBC0063),
        animationDuration: const Duration(milliseconds: 300),
        buttonBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        onTap: _onItemTapped, // Add onTap handler
        index: _selectedIndex, // Set the index of the selected icon
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () {
              ap.userSignOut().then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                    ),
                  );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(ap.userModel.firstname),
            Text(ap.userModel.lastname),
            Text(ap.userModel.username),
            Text(ap.userModel.dob),
            Text(ap.userModel.email),
            Text(ap.userModel.phoneNumber),
          ],
        ),
      ),
    );
  }
}
