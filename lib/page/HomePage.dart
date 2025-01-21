import 'package:asklab/page/AddPost.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:asklab/page/fragments/FeedsFragment.dart'; // Import Fragments
import 'package:asklab/page/fragments/ExploreFragment.dart';
import 'package:asklab/page/fragments/NotificationsFragment.dart';
import 'package:asklab/page/fragments/ProfileFragment.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // List of fragments for navigation
  final List<Widget> _pages = [
    const FeedsFragment(),
    const ExploreFragment(),
    const SizedBox(), // Placeholder for floating action button
    const NotificationsFragment(),
    const ProfileFragment(),
  ];

  // Method to handle the selection of bottom navigation items
  void _onItemTapped(int index) {
    if (index != 2) {
      // Skip the "Add" action (Floating Button)
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _pages[_currentIndex], // Display the selected page/fragment
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPost()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF009ADB),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black, // Set selected item color if needed
        unselectedItemColor: Colors.grey, // Make unselected items grey
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.article, color: Colors.grey),
            label: 'Feeds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, color: Colors.grey),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.white),
            label:
                'Add', // This is just a placeholder, FAB will be in the middle
            backgroundColor: Colors.transparent, // Make it invisible
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.grey),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
