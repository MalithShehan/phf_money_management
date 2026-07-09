import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_management/core/widgets/app_drawer.dart';
import 'package:phf_money_management/features/categories/domain/entities/category.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final List<Map<String, String>> _colorOptions = const [
    {'name': 'Blue', 'hex': '#1976D2'},
    {'name': 'Emerald', 'hex': '#2E7D32'},
    {'name': 'Red', 'hex': '#C62828'},
    {'name': 'Teal', 'hex': '#00796B'},
    {'name': 'Orange', 'hex': '#EF6C00'},
    {'name': 'Purple', 'hex': '#6A1B9A'},
  ];

  final List<Map<String, dynamic>> _iconOptions = const [
    {'name': 'General', 'icon': Icons.category_rounded, 'id': 'category'},
    {'name': 'Food', 'icon': Icons.restaurant_rounded, 'id': 'restaurant'},
    {'name': 'Transport', 'icon': Icons.directions_car_rounded, 'id': 'car'},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded, 'id': 'shopping'},
    {'name': 'Home/Rent', 'icon': Icons.home_rounded, 'id': 'home'},
    {'name': 'Salary', 'icon': Icons.monetization_on_rounded, 'id': 'salary'},
    {'name': 'Entertainment', 'icon': Icons.movie_rounded, 'id': 'entertainment'},
  ];

  IconData _getIconData(String? iconId) {
    final match = _iconOptions.firstWhere((element) => element['id'] == iconId, orElse: () => _iconOptions.first);
    return match['icon'] as IconData;
  }

  Color _hexToColor(String? hexString) {
    if (hexString == null) return const Color(0xFF1976D2);
    final hex = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _showAddCategoryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    String localSelectedType = 'Expense';
    String localSelectedColor = '#1976D2'; // Default Blue color hex
    String localSelectedIcon = 'category';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Category'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Category Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: localSelectedType,
                        decoration: const InputDecoration(labelText: 'Category Type'),
                        items: const [
                          DropdownMenuItem(value: 'Income', child: Text('Income')),
                          DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              localSelectedType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: localSelectedColor,
                        decoration: const InputDecoration(labelText: 'Display Color'),
                        items: _colorOptions.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['hex'],
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _hexToColor(opt['hex']),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(opt['name']!),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              localSelectedColor = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: localSelectedIcon,
                        decoration: const InputDecoration(labelText: 'Category Icon'),
                        items: _iconOptions.map<DropdownMenuItem<String>>((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['id'] as String,
                            child: Row(
                              children: [
                                Icon(opt['icon'] as IconData, size: 20),
                                const SizedBox(width: 8),
                                Text(opt['name'] as String),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              localSelectedIcon = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newCategory = Category(
                        id: 0,
                        name: nameController.text.trim(),
                        type: localSelectedType,
                        icon: localSelectedIcon,
                        color: localSelectedColor,
                      );

                      ref.read(categoryProvider.notifier).addCategory(newCategory);

                      Navigator.of(dialogContext).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Category "${newCategory.name}" created successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: categoryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryState.categories.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🏷️',
                          style: TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Categories',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Create your first category.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: categoryState.categories.length,
                  itemBuilder: (context, index) {
                    final cat = categoryState.categories[index];
                    final displayColor = _hexToColor(cat.color);
                    final isExpense = cat.type.toLowerCase() == 'expense';

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: displayColor.withValues(alpha: 0.1),
                          child: Icon(_getIconData(cat.icon), color: displayColor),
                        ),
                        title: Text(
                          cat.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          cat.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: isExpense ? Colors.red[800] : Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: displayColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
