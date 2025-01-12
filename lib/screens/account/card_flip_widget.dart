import 'package:barcode_widget/barcode_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CardFlipWidget extends StatefulWidget {
  @override
  _CardFlipWidgetState createState() => _CardFlipWidgetState();
}

class _CardFlipWidgetState extends State<CardFlipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flip Animation
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * pi;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(angle),
                child: angle <= pi / 2
                    ? _buildFrontCard()
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: _buildBackCard(),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 50, bottom: 40, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Container with Overlapping Card
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Grey Circular Container
                  Container(
                    height: 260,
                    width: 260,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      image: DecorationImage(fit: BoxFit.cover,image: AssetImage('assets/images/shrutika.png'))
                    ),
                  ),
                  Positioned(
                    bottom: -5, 
                    child: Transform.rotate(
                      angle: 0.05,
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Text(
                              'SHIV ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Centered Name and Details
              const Text(
                'Shivprasad Rahulwad',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text('MITAOE PUNE'),
              const Text('CSE'),
              const Text(
                '"Start where you are. Use what you have. Do what you can."',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Dotted Border with Text
              DottedBorder(
                color: Colors.grey,
                strokeWidth: 1.5,
                dashPattern: [8, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Text(
                    'Edit profile',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Container(
          height: 530,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RepaintBoundary(
                  key: _globalKey,
                  child: Center(
                    child: BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      color: Colors.black,
                      data: 'Shrutika Rahulwad  ti yedii ahe',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Text(
                        'SHIVPRASAD_RAHULWAD',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
