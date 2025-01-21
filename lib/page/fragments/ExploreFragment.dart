import 'package:flutter/material.dart';

class ExploreFragment extends StatelessWidget {
  const ExploreFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Explore – Discover random posts, trends, and hashtags',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
