import 'package:flutter/material.dart';

class ProfileFragment extends StatelessWidget {
  const ProfileFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Profile – View and edit your personal profile page',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
