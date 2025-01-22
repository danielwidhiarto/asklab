import 'package:flutter/material.dart';

class DMFragment extends StatelessWidget {
  const DMFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF009ADB),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5, // Replace with dynamic count
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Replace with user avatar
            ),
            title: const Text('Jordan Jones'), // Replace with sender name
            subtitle: const Text(
                'Such a pretty photo! - 3m'), // Replace with message preview and timestamp
            onTap: () {
              // Navigate to chat screen
            },
          );
        },
      ),
    );
  }
}
