import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.blueGrey),
          SizedBox(height: 16),
          Text('AI Vision Scan (Coming Soon)'),
        ],
      ),
    );
  }
}
