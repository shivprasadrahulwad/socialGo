import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {
  final bool isToggled;
  final Function() onTap;

  const CustomToggleButton({
    Key? key,
    required this.isToggled,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 47.0,
        height: 25.0,
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: isToggled ? Colors.green : Colors.grey[300],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isToggled ? 24.0 : 4.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 15.0,
                height: 15.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToggled ? Colors.white : Colors.transparent,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}