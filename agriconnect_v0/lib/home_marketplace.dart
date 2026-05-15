import 'dart:convert';

import 'package:agriconnect_v0/notifier.dart';
import 'package:agriconnect_v0/product_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeMarketplacePage extends StatefulWidget {
  final Map<String, String> message;
  const HomeMarketplacePage({
    super.key,
    this.message = const {"message": "loaded successfully"},
  });

  @override
  State<HomeMarketplacePage> createState() => _HomeMarketplacePageState();
}

class _HomeMarketplacePageState extends State<HomeMarketplacePage> {
  static const Color _ink = Color(0xFF111111);
  static const Color _subText = Color(0xFF999999);
  static const Color _surface = Color(0xFFFAFAF8);
  static const Color _border = Color(0xFFEEEEEA);
  static const Color _green = Color(0xFF40B37A);
  static const Color _orange = Color(0xFFF97316);

  String selectedCategory = "All";
  bool showIntro = false;

  final List<String> categories = [
    "All",
    "Food Crops",
    "Cash Crops",
    "Manure",
    "Animals",
    "Plant Medicine",
    "Animal Medicine",
  ];

  Future<void> fetchAllProducts() async {
    final url = Uri.parse("http://192.168.50.36:8000/fetch-products");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        fetchedProducts.value = (data['content'] as List)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => showIntro = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: fetchedProducts,
            builder: (context, products, _) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildCategories()),

                  // Filter products by selected category
                  ..._buildSections(products),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            },
          ),

          // Intro banner
          AnimatedPositioned(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: showIntro ? 0 : -100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _orange,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Explore verified agro stores, compare sellers, and open each store to view its products.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => showIntro = false),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build sections: one horizontal scrollable row per every 6 products ──
  List<Widget> _buildSections(List<Product> allProducts) {
    // Filter if a category is selected
    final filtered = selectedCategory == "All"
        ? allProducts
        : allProducts.where((p) => p.location == selectedCategory).toList();

    if (filtered.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Text(
                "No products found",
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
              ),
            ),
          ),
        ),
      ];
    }

    // Split into chunks of 6
    final List<List<Product>> chunks = [];
    for (int i = 0; i < filtered.length; i += 6) {
      chunks.add(
        filtered.sublist(i, i + 6 > filtered.length ? filtered.length : i + 6),
      );
    }

    // Build one section per chunk
    final List<Widget> sections = [];
    for (int i = 0; i < chunks.length; i++) {
      sections.add(
        SliverToBoxAdapter(
          child: _sectionTitle(
            i == 0
                ? "Featured Products"
                : i == 1
                ? "Popular Items"
                : i == 2
                ? "Special Offers"
                : "More Products",
          ),
        ),
      );
      sections.add(SliverToBoxAdapter(child: _scrollableRow(chunks[i])));
    }

    return sections;
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
              ),
              child: const TextField(
                style: TextStyle(fontSize: 13.5, color: _ink),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  hintText: "Search crops, animals, medicine...",
                  hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Color(0xFF555555),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 33,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: selected ? _green : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _green : const Color(0xFFE2E2E0),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF444444),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "See all",
            style: TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Horizontal row of up to 6 product cards ──────────────────────────────
  Widget _scrollableRow(List<Product> items) {
    return SizedBox(
      height: 318,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _productCard(items[index]),
      ),
    );
  }

  Widget _productCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image from backend ────────────────────────────────────────
            Image.network(
              product.imageUrl,
              height: 168,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 128,
                  color: const Color(0xFFF0F0EC),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: 118,
                color: const Color(0xFFF0F0EC),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFCCCCCC),
                ),
              ),
            ),

            // ── Info ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.location,
                      style: const TextStyle(
                        color: _green,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    product.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _subText,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${product.priceRwf} RWF",
                        style: const TextStyle(
                          color: _orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ProductCardType { normal, fullWidth, eightyPercent }
