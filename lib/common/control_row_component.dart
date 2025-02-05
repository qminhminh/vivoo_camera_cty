import 'package:flutter/material.dart';

class ControlRowComponent extends StatelessWidget {
  final List<Widget> buttons;

  const ControlRowComponent({
    super.key,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons
          .map((button) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: button,
              ))
          .toList(),
    );
  }
}
