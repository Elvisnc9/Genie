import 'package:flutter/material.dart';

class SettingsPanel extends StatelessWidget {
  final VoidCallback onDismiss;

  const SettingsPanel({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          color: const Color(0xFF2A2E28),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Settings', style: TextStyle(color: Colors.white)),
                TextButton(onPressed: onDismiss, child: const Text('Close')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}