import 'package:flutter/material.dart';
import 'search_bar_widget.dart';

/// 다양한 필터링 패턴 예시
class FilteringExamples {
  /// 1. 기본 텍스트 필터링 (문자열 포함)
  static List<String> filterByText(List<String> items, String query) {
    if (query.isEmpty) return items;

    return items
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// 2. 객체 리스트 필터링 (여러 필드 검색)
  static List<Product> filterProducts(List<Product> products, String query) {
    if (query.isEmpty) return products;

    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 3. 카테고리별 필터링
  static List<Product> filterByCategory(
    List<Product> products,
    String category,
  ) {
    if (category.isEmpty) return products;

    return products.where((product) => product.category == category).toList();
  }

  /// 4. 복합 필터링 (텍스트 + 카테고리)
  static List<Product> filterProductsAdvanced(
    List<Product> products,
    String textQuery,
    String? category,
  ) {
    var filtered = products;

    // 카테고리 필터 적용
    if (category != null && category.isNotEmpty) {
      filtered =
          filtered.where((product) => product.category == category).toList();
    }

    // 텍스트 검색 적용
    if (textQuery.isNotEmpty) {
      final lowerQuery = textQuery.toLowerCase();
      filtered =
          filtered.where((product) {
            return product.name.toLowerCase().contains(lowerQuery) ||
                product.description.toLowerCase().contains(lowerQuery);
          }).toList();
    }

    return filtered;
  }
}

/// 예시 데이터 모델
class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
  });
}

/// 실제 사용 예시 페이지
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();

  // 전체 데이터
  final List<Product> _allProducts = [
    Product(
      id: '1',
      name: 'iPhone 15',
      category: 'Electronics',
      description: 'Latest smartphone from Apple',
      price: 999.99,
    ),
    Product(
      id: '2',
      name: 'Samsung Galaxy',
      category: 'Electronics',
      description: 'Android smartphone',
      price: 899.99,
    ),
    Product(
      id: '3',
      name: 'Nike Shoes',
      category: 'Fashion',
      description: 'Comfortable running shoes',
      price: 129.99,
    ),
  ];

  // 필터링된 데이터
  List<Product> _filteredProducts = [];
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
  }

  // 검색어 변경 시 필터링
  void _onSearchChanged(String query) {
    setState(() {
      _filteredProducts = FilteringExamples.filterProductsAdvanced(
        _allProducts,
        query,
        _selectedCategory.isEmpty ? null : _selectedCategory,
      );
    });
  }

  // 카테고리 변경 시 필터링
  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredProducts = FilteringExamples.filterProductsAdvanced(
        _allProducts,
        _searchController.text,
        category.isEmpty ? null : category,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품 목록')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 검색창
            SearchBarWidget(
              controller: _searchController,
              hintText: 'Search products...',
              onChanged: _onSearchChanged,
              margin: const EdgeInsets.only(bottom: 16),
            ),

            // 카테고리 필터
            Row(
              children: [
                const Text('Category: '),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All')),
                    const DropdownMenuItem(
                      value: 'Electronics',
                      child: Text('Electronics'),
                    ),
                    const DropdownMenuItem(
                      value: 'Fashion',
                      child: Text('Fashion'),
                    ),
                  ],
                  onChanged: (value) => _onCategoryChanged(value ?? ''),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 검색 결과
            Expanded(
              child: ListView.builder(
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return Card(
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.category} - ${product.description}',
                      ),
                      trailing: Text('\$${product.price}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// 간단한 텍스트 리스트 필터링 예시
class SimpleTextFilterPage extends StatefulWidget {
  const SimpleTextFilterPage({super.key});

  @override
  State<SimpleTextFilterPage> createState() => _SimpleTextFilterPageState();
}

class _SimpleTextFilterPageState extends State<SimpleTextFilterPage> {
  final List<String> _allItems = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
  ];

  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = FilteringExamples.filterByText(_allItems, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('간단한 필터링')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBarWidget(
              hintText: 'Search items...',
              onChanged: _filterItems,
              margin: const EdgeInsets.only(bottom: 16),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filteredItems[index]),
                    leading: const Icon(Icons.list),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
