import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/expense_provider.dart';
import 'add_edit_category_dialog.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản Lý Danh Mục'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.arrow_downward_rounded, color: Colors.redAccent),
                text: 'Khoản Chi (Chi tiêu)',
              ),
              Tab(
                icon: Icon(Icons.arrow_upward_rounded, color: Colors.green),
                text: 'Khoản Thu (Thu nhập)',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(context, provider.expenseCategories, 'expense'),
            _buildCategoryList(context, provider.incomeCategories, 'income'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AddEditCategoryDialog(defaultType: 'expense'),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm danh mục'),
        ),
      ),
    );
  }

  Widget _buildCategoryList(
      BuildContext context, List<CategoryModel> categories, String type) {
    final theme = Theme.of(context);
    final provider = context.read<ExpenseProvider>();

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 56, color: theme.disabledColor),
            const SizedBox(height: 12),
            Text(
              'Chưa có danh mục nào.',
              style: TextStyle(color: theme.disabledColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(cat.icon, color: cat.color, size: 24),
            ),
            title: Row(
              children: [
                Text(
                  cat.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 8),
                if (cat.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Mặc định',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              cat.type == 'expense' ? 'Danh mục chi tiêu' : 'Danh mục thu nhập',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddEditCategoryDialog(
                        initialCategory: cat,
                        defaultType: cat.type,
                      ),
                    );
                  },
                ),
                if (!cat.isDefault)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa danh mục'),
                          content: Text(
                              'Bạn có muốn xóa danh mục tùy chỉnh "${cat.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.deleteCategory(cat.id);
                                Navigator.pop(ctx);
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
