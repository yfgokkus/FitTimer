import 'package:fit_timer/widgets/ClickAnimatedTextButton.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClickAnimatedTextButton(text: "Programs", onPressed: () => {}),
          const SizedBox(height: 20),
          ClickAnimatedTextButton(text: "Programs", onPressed: () => {}),
        ],
      ),
    );
  }
}



