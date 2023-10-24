import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Post extends StatelessWidget {
  final String postText;
   String? postMedia;
   Post({
    super.key,
   required this.postText,
  this.postMedia,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
