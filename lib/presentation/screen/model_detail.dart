import 'package:flutter/material.dart';

class CatalogPanel extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onSelectFurniture;

  const CatalogPanel({super.key, required this.onDismiss, required this.onSelectFurniture});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.95,
        child: Container(
          color: const Color(0xFF2A2E28),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Catalog', style: TextStyle(color: Colors.white)),
                TextButton(onPressed: onSelectFurniture, child: const Text('Select item')),
                TextButton(onPressed: onDismiss, child: const Text('Close')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class FurnitureInfoScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onViewInRoom;

  const FurnitureInfoScreen({super.key, required this.onBack, required this.onViewInRoom});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF23261F),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Furniture Info', style: TextStyle(color: Colors.white)),
            TextButton(onPressed: onViewInRoom, child: const Text('View in my room')),
            TextButton(onPressed: onBack, child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}