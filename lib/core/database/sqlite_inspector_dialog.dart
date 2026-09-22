import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_database.dart';

class SqliteInspectorDialog extends StatefulWidget {
  const SqliteInspectorDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SqliteInspectorDialog(),
    );
  }

  @override
  State<SqliteInspectorDialog> createState() => _SqliteInspectorDialogState();
}

class _SqliteInspectorDialogState extends State<SqliteInspectorDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _wishlistItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final db = await AppDatabase.instance.database;
      final products = await db.query('products', limit: 30);
      final cart = await db.query('cart_items');
      final wishlist = await db.query('wishlist_items');

      if (mounted) {
        setState(() {
          _products = products;
          _cartItems = cart;
          _wishlistItems = wishlist;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storage_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SQLite Database Viewer',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'ecommerce_store.db • Live sqflite Inspector',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Tables',
                  onPressed: _loadData,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'products (${_products.length})'),
              Tab(text: 'cart_items (${_cartItems.length})'),
              Tab(text: 'wishlist_items (${_wishlistItems.length})'),
              const Tab(text: 'Table Schemas (SQL)'),
            ],
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductsTab(isDark),
                      _buildCartTab(isDark),
                      _buildWishlistTab(isDark),
                      _buildSchemasTab(isDark),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(bool isDark) {
    if (_products.isEmpty) {
      return _buildEmptyState('No products cached in SQLite yet.\nBrowse products in app to auto-populate!');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final row = _products[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${row['id']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row['title']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Category: ${row['category']} • Price: \$${row['price']} • Rating: ${row['rating']}★',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartTab(bool isDark) {
    if (_cartItems.isEmpty) {
      return _buildEmptyState('cart_items table is currently empty.\nAdd items to cart to see live rows here!');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final row = _cartItems[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Row ID: ${row['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'user_id: ${row['user_id']}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'product_id: ${row['product_id']}   •   quantity: ${row['quantity']}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishlistTab(bool isDark) {
    if (_wishlistItems.isEmpty) {
      return _buildEmptyState('wishlist_items table is currently empty.\nHeart items to see live rows here!');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _wishlistItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final row = _wishlistItems[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'product_id: ${row['product_id']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'user: ${row['user_id']}',
                style: const TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchemasTab(bool isDark) {
    const schemaSql = '''-- 1. PRODUCTS TABLE
CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  price REAL,
  discountPercentage REAL,
  rating REAL,
  stock INTEGER,
  brand TEXT,
  thumbnail TEXT,
  images TEXT,
  warrantyInformation TEXT,
  shippingInformation TEXT,
  returnPolicy TEXT
);

-- 2. CART ITEMS TABLE
CREATE TABLE cart_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  product_json TEXT NOT NULL,
  UNIQUE(user_id, product_id) ON CONFLICT REPLACE
);

-- 3. WISHLIST ITEMS TABLE
CREATE TABLE wishlist_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  product_id INTEGER NOT NULL,
  product_json TEXT NOT NULL,
  UNIQUE(user_id, product_id) ON CONFLICT REPLACE
);''';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF090D16) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const SelectableText(
          schemaSql,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Color(0xFF38BDF8),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.table_rows_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
