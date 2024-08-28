import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 0)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  final String id; // Unique identifier for the item

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? category;

  @HiveField(3)
  bool isBought;

  ShoppingItem({
    required this.id,
    required this.name,
    this.category,
    this.isBought = false,
  });
}
