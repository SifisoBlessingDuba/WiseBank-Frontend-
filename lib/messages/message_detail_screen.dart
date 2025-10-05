import 'package:flutter/material.dart';

class MessageDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const MessageDetailScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Padding(padding: const EdgeInsets.all(16.0), child: Text(content)),
  );
}
