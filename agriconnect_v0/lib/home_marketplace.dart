import 'dart:convert';
import 'package:agriconnect_v0/notifier.dart';
import 'package:agriconnect_v0/product_details.dart';
import 'package:agriconnect_v0/theme/app_theme.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = "All";
  String searchQuery = "";
  bool showIntro = true;

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
    try {
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
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      body: Stack(
        children: [
          ValueListenableBuilder<List<Product>>(
            valueListenable: fetchedProducts,
            builder: (context, products, _) {
              return CustomScrollView(
                slivers: [
                  // Search and quick action
                  SliverToBoxAdapter(child: _buildHeader()),

                  // Category Pills
                  SliverToBoxAdapter(child: _buildCategories()),

                  // Filtered product chunks
                  ..._buildSections(products),

                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              );
            },
          ),

          // Intro banner at bottom
          if (showIntro)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: AnimatedOpacity(
                opacity: showIntro ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: DoctorCropColors.textPrimary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: DoctorCropColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Verified Agro Marketplace",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Direct access to certified medicines, seeds & fertilizers.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => showIntro = false),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSections(List<Product> allProducts) {
    // Filter by category and search query
    final filtered = allProducts.where((p) {
      final matchesCategory = selectedCategory == "All" ||
          p.location.toLowerCase() == selectedCategory.toLowerCase() ||
          p.productName.toLowerCase().contains(selectedCategory.toLowerCase());

      final matchesQuery = searchQuery.isEmpty ||
          p.productName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.location.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesCategory && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: DoctorCropColors.surfaceMuted,
                    shape: BoxShape.circle,
                    border: Border.all(color: DoctorCropColors.border),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 32,
                    color: DoctorCropColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No agricultural products found",
                  style: TextStyle(
                    color: DoctorCropColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Try selecting a different category or clearing your search keywords.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DoctorCropColors.textSecondary, fontSize: 12.5),
                ),
                if (searchQuery.isNotEmpty || selectedCategory != "All") ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedCategory = "All";
                        searchQuery = "";
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text("Reset Filters"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ];
    }

    // Split into chunks of 6 products for curated carousels
    final List<List<Product>> chunks = [];
    for (int i = 0; i < filtered.length; i += 6) {
      chunks.add(
        filtered.sublist(i, i + 6 > filtered.length ? filtered.length : i + 6),
      );
    }

    final titles = [
      "Featured Farm Products",
      "Popular Crop Medicines",
      "Essential Seeds & Nutrients",
      "More Agro Supplies",
    ];

    final List<Widget> sections = [];
    for (int i = 0; i < chunks.length; i++) {
      sections.add(
        SliverToBoxAdapter(
          child: _sectionTitle(
            i < titles.length ? titles[i] : "More Products",
            chunks[i].length,
          ),
        ),
      );
      sections.add(SliverToBoxAdapter(child: _scrollableRow(chunks[i])));
    }

    return sections;
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DoctorCropColors.border, width: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => searchQuery = val.trim()),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: DoctorCropColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: DoctorCropColors.textMuted,
                    size: 20,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          color: DoctorCropColors.textMuted,
                          onPressed: () {
                            setState(() {
                              searchQuery = "";
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  hintText: "Search seeds, fertilizers, pesticides...",
                  hintStyle: const TextStyle(
                    color: DoctorCropColors.textMuted,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: DoctorCropColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DoctorCropColors.primary.withOpacity(0.2),
                width: 0.9,
              ),
            ),
            child: const Icon(
              Icons.filter_list_rounded,
              color: DoctorCropColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 10, bottom: 4),
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
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? DoctorCropColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? DoctorCropColors.primary
                      : DoctorCropColors.border,
                  width: 0.9,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: DoctorCropColors.primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  color: selected ? Colors.white : DoctorCropColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: DoctorCropColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: DoctorCropColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: DoctorCropColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const Text(
            "See all",
            style: TextStyle(
              color: DoctorCropColors.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scrollableRow(List<Product> items) {
    return SizedBox(
      height: 290,
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
        width: 195,
        decoration: DoctorCropTheme.cardDecoration(radius: 14),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded top corners
            Stack(
              children: [
                Image.network(
                  product.imageUrl,
                  height: 145,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 145,
                      color: DoctorCropColors.surfaceMuted,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              DoctorCropColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 145,
                    color: DoctorCropColors.surfaceMuted,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: DoctorCropColors.textMuted,
                      ),
                    ),
                  ),
                ),

                // Location tag badge overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: DoctorCropColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          product.location,
                          style: const TextStyle(
                            color: DoctorCropColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DoctorCropColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DoctorCropColors.textSecondary,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${product.priceRwf} RWF",
                        style: const TextStyle(
                          color: DoctorCropColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: DoctorCropColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: DoctorCropColors.primary,
                          size: 16,
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
