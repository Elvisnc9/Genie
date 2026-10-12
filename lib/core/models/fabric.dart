import 'package:flutter/painting.dart';

/// A fabric or finish option for a piece, e.g. "Terracotta bouclé".
class Fabric {
  const Fabric({required this.id, required this.name, required this.color, this.image});

  factory Fabric.fromJson(Map<String, dynamic> json) => Fabric(
    id: json['id'] as String,
    name: json['name'] as String,
    color: Color(int.parse((json['hex'] as String).replaceFirst('#', 'FF'), radix: 16)),
    image: json['image'] as String?,
  );

  final String id;
  final String name;
  final Color color;

  /// A render of the piece in this fabric, when one exists.
  final String? image;

  @override
  bool operator ==(Object other) => other is Fabric && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
