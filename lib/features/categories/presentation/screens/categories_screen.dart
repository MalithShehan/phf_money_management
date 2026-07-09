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

  void _showDeleteConfirmationDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Category?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "${category.name}"? '
          'This will permanently delete all transactions associated with this category.',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(categoryProvider.notifier).deleteCategory(category.id);
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "${category.name}" deleted.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: displayColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddCategoryDialog(category: cat),
                                  );
                                } else if (value == 'delete') {
                                  _showDeleteConfirmationDialog(context, cat);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddCategoryDialog(),
          );
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddCategoryDialog extends ConsumerStatefulWidget {
  final Category? category;
  const AddCategoryDialog({super.key, this.category});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String _selectedType = 'Expense';
  String _selectedColor = '#1976D2';
  String _selectedIcon = 'category';

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

  Color _hexToColor(String? hexString) {
    if (hexString == null) return const Color(0xFF1976D2);
    final hex = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    if (widget.category != null) {
      _selectedType = widget.category!.type;
      _selectedColor = widget.category!.color ?? '#1976D2';
      _selectedIcon = widget.category!.icon ?? 'category';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
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
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Category Type'),
                items: const [
                  DropdownMenuItem(value: 'Income', child: Text('Income')),
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedColor,
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
                    setState(() {
                      _selectedColor = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedIcon,
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
                    setState(() {
                      _selectedIcon = value;
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
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newCategory = Category(
                id: isEditing ? widget.category!.id : 0,
                name: _nameController.text.trim(),
                type: _selectedType,
                icon: _selectedIcon,
                color: _selectedColor,
              );

              if (isEditing) {
                ref.read(categoryProvider.notifier).editCategory(newCategory);
              } else {
                ref.read(categoryProvider.notifier).addCategory(newCategory);
              }

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing 
                        ? 'Category "${newCategory.name}" updated successfully!'
                        : 'Category "${newCategory.name}" created successfully!'
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

