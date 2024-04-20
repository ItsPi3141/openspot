import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
                child: GridView.count(crossAxisCount: 2, children: [
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              ),
              Card(
                child: Text("test"),
              )
            ]))
          ],
        ),
      ),
    );
  }
}
