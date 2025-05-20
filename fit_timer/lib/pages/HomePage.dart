import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(child: TextButton(onPressed: () =>{}, child: const Text("Programs"))),
          Expanded(child: TextButton(onPressed: () =>{}, child: Text("Programs"))),
        ],
      ),
    );
  }
}
