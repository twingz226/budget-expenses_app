import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/custom_category.dart';
import '../utils/categories.dart';

class CategoryService {
  static Box<CustomCategory>? _categoryBox;

  static Box<CustomCategory> get categoryBox {
    _categoryBox ??= Hive.box<CustomCategory>(
      AppConstants.customCategoriesBoxName,
    );
    return _categoryBox!;
  }

  static Future<void> addCategory(CustomCategory category) async {
    await categoryBox.add(category);
  }

  static Future<void> updateCategory(int index, CustomCategory category) async {
    await categoryBox.putAt(index, category);
  }

  static Future<void> deleteCategory(int index) async {
    await categoryBox.deleteAt(index);
  }

  static List<CustomCategory> getAllCustomCategories() {
    return categoryBox.values.toList();
  }

  static List<String> getAllCategories() {
    final customCategories = getAllCustomCategories()
        .map((c) => c.name)
        .toList();
    return [...AppConstants.expenseCategories, ...customCategories];
  }

  static CustomCategory? getCustomCategoryByName(String name) {
    final categories = getAllCustomCategories().where(
      (category) => category.name == name,
    );
    return categories.isNotEmpty ? categories.first : null;
  }

  static Color getCategoryColor(String categoryName) {
    // Check if it's a custom category
    final customCategory = getCustomCategoryByName(categoryName);
    if (customCategory != null) {
      return Color(int.parse(customCategory.color.replaceFirst('#', '0xFF')));
    }

    // Return default category colors
    switch (categoryName) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Bills':
        return Colors.red;
      case 'Shopping':
        return Colors.purple;
      case 'Health':
        return Colors.green;
      case 'Others':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static IconData getCategoryIcon(String categoryName) {
    // Check if it's a custom category
    final customCategory = getCustomCategoryByName(categoryName);
    if (customCategory != null) {
      // Convert icon string to IconData
      try {
        final iconCodePoint = int.parse(customCategory.icon);
        return IconData(iconCodePoint, fontFamily: 'MaterialIcons');
      } catch (e) {
        return Icons.category;
      }
    }

    // Return default category icons
    switch (categoryName) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Bills':
        return Icons.receipt;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Health':
        return Icons.local_hospital;
      case 'Others':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  static bool isCustomCategory(String categoryName) {
    return getCustomCategoryByName(categoryName) != null;
  }

  static List<Map<String, dynamic>> getAvailableIcons() {
    return [
      {'name': 'Home', 'icon': Icons.home.codePoint},
      {'name': 'Work', 'icon': Icons.work.codePoint},
      {'name': 'School', 'icon': Icons.school.codePoint},
      {'name': 'Entertainment', 'icon': Icons.movie.codePoint},
      {'name': 'Travel', 'icon': Icons.flight.codePoint},
      {'name': 'Fitness', 'icon': Icons.fitness_center.codePoint},
      {'name': 'Shopping', 'icon': Icons.shopping_cart.codePoint},
      {'name': 'Gift', 'icon': Icons.card_giftcard.codePoint},
      {'name': 'Pet', 'icon': Icons.pets.codePoint},
      {'name': 'Book', 'icon': Icons.book.codePoint},
      {'name': 'Music', 'icon': Icons.music_note.codePoint},
      {'name': 'Game', 'icon': Icons.sports_esports.codePoint},
      {'name': 'Coffee', 'icon': Icons.coffee.codePoint},
      {'name': 'Dining', 'icon': Icons.dinner_dining.codePoint},
      {'name': 'Grocery', 'icon': Icons.shopping_basket.codePoint},
      {'name': 'Pharmacy', 'icon': Icons.local_pharmacy.codePoint},
      {'name': 'Gas', 'icon': Icons.local_gas_station.codePoint},
      {'name': 'Electricity', 'icon': Icons.electrical_services.codePoint},
      {'name': 'Water', 'icon': Icons.water_drop.codePoint},
      {'name': 'Internet', 'icon': Icons.wifi.codePoint},
    ];
  }

  static List<Map<String, dynamic>> getAvailableColors() {
    return [
      {'name': 'Red', 'color': '#F44336'},
      {'name': 'Pink', 'color': '#E91E63'},
      {'name': 'Purple', 'color': '#9C27B0'},
      {'name': 'Deep Purple', 'color': '#673AB7'},
      {'name': 'Indigo', 'color': '#3F51B5'},
      {'name': 'Blue', 'color': '#2196F3'},
      {'name': 'Light Blue', 'color': '#03A9F4'},
      {'name': 'Cyan', 'color': '#00BCD4'},
      {'name': 'Teal', 'color': '#009688'},
      {'name': 'Green', 'color': '#4CAF50'},
      {'name': 'Light Green', 'color': '#8BC34A'},
      {'name': 'Lime', 'color': '#CDDC39'},
      {'name': 'Yellow', 'color': '#FFEB3B'},
      {'name': 'Amber', 'color': '#FFC107'},
      {'name': 'Orange', 'color': '#FF9800'},
      {'name': 'Deep Orange', 'color': '#FF5722'},
      {'name': 'Brown', 'color': '#795548'},
      {'name': 'Grey', 'color': '#9E9E9E'},
      {'name': 'Blue Grey', 'color': '#607D8B'},
      {'name': 'Black', 'color': '#000000'},
    ];
  }
}
