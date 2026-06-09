import 'package:eventra/core/widgets/navbar.dart';
import 'package:eventra/features/home/views/main_screen.dart';
import 'package:flutter/material.dart';

class EventraSubpageShell extends StatelessWidget {
  const EventraSubpageShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: MainNavBar(
          currentIndex: currentIndex.clamp(0, 4),
          onTap: (index) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => MainScreen(initialIndex: index),
              ),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
