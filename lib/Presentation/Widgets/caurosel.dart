import 'package:flutter/material.dart';

class FurnitureSelector extends StatefulWidget {
  const FurnitureSelector({super.key});

  @override
  State<FurnitureSelector> createState() => _FurnitureSelectorState();
}

class _FurnitureSelectorState extends State<FurnitureSelector> {
  int selectedIndex = 1;

  final List<String> furnitureItems = [
    'assets/icons/Gennie.png',
    'assets/icons/Gennie.png',
    'assets/icons/Gennie.png',
    'assets/icons/Gennie.png',
    'assets/icons/Gennie.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(furnitureItems.length, (index) {
            final bool isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  radius: 35,
                  backgroundImage: AssetImage(furnitureItems[index]),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
