import 'package:flutter/material.dart';

class NotificationsFragment extends StatelessWidget {
  const NotificationsFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Notifications – Updates on interactions, follows, likes, and comments',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
