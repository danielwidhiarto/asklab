import 'package:flutter/material.dart';

class FeedsFragment extends StatelessWidget {
  const FeedsFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Feeds – View posts from people you follow',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
