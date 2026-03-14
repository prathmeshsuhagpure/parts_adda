import 'dart:async';
import 'package:flutter/material.dart';

class IconLoader extends StatefulWidget {
  const IconLoader({super.key});

  @override
  State<IconLoader> createState() => _IconLoaderState();
}

class _IconLoaderState extends State<IconLoader> {
  final List<IconData> icons = [
    Icons.settings,
    Icons.build,
    Icons.extension,
    Icons.precision_manufacturing,
  ];

  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          currentIndex = (currentIndex + 1) % icons.length;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Icon(
        icons[currentIndex],
        key: ValueKey(currentIndex),
        size: 40,
        color: Colors.white,
      ),
    );
  }
}