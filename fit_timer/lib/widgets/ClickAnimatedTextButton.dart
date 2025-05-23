import 'package:flutter/material.dart';

class ClickAnimatedTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color defaultColor;
  final Color clickedColor;
  final double defaultFontSize;
  final double clickedFontSize;
  final Duration animationDuration;

  const ClickAnimatedTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.defaultColor = Colors.white,
    this.clickedColor = const Color(0xFFC1FF72),
    this.defaultFontSize = 18,
    this.clickedFontSize = 22,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<ClickAnimatedTextButton> createState() =>
      _ClickAnimatedTextButtonState();
}

class _ClickAnimatedTextButtonState extends State<ClickAnimatedTextButton> {
  bool _isClicked = false;

  void _handleClick() {
    // Set clicked state: changes color and starts font animation
    setState(() {
      _isClicked = true;
    });

    // Wait for animation to finish, then trigger onPressed and reset state
    Future.delayed(widget.animationDuration, () {
      widget.onPressed();

      setState(() {
        _isClicked = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: TextButton(
        onPressed: _handleClick,
        style: TextButton.styleFrom(
          padding: EdgeInsets.only(right:10),
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedDefaultTextStyle(
            duration: widget.animationDuration,
            style: TextStyle(
              fontSize: _isClicked
                  ? widget.clickedFontSize
                  : widget.defaultFontSize,
              fontWeight: FontWeight.bold,
              color: _isClicked
                  ? widget.clickedColor
                  : widget.defaultColor, // now animated with font size
            ),
            child: Text(widget.text),
          ),
        ),
      ),
    );
  }
}
