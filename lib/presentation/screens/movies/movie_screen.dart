import 'package:flutter/material.dart';

class MovieScreen extends StatefulWidget {
  static const String name = 'movie_screen';

  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  @override
  void initState() {
    super.initState();
    // You can perform any initialization or data fetching here using widget.movieId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Movie ID: ${widget.movieId}')));
  }
}
