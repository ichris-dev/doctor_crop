import 'package:agriconnect_v0/genomePage.dart';
import 'package:agriconnect_v0/notifier.dart';
import 'package:agriconnect_v0/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DoctorCropColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DoctorCropColors.border, width: 0.8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: DoctorCropColors.textPrimary,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DoctorCropColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            Row(
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
                    color: DoctorCropColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Product link copied to clipboard"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DoctorCropColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DoctorCropColors.border, width: 0.8),
              ),
              child: const Icon(
                Icons.share_outlined,
                color: DoctorCropColors.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.9, color: DoctorCropColors.border),
        ),
      ),

      // ── Clean Non-Overlapping Bottom Bar ─────────────────────────────
      bottomNavigationBar: Container(
        decoration: DoctorCropTheme.bottomNavDecoration(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Chat / Message Seller button
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: DoctorCropColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DoctorCropColors.border, width: 0.9),
                ),
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Messaging seller for ${product.productName}"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: DoctorCropColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Primary Order CTA
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showOrderConfirmation(context);
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text("Order Now · ${product.priceRwf} RWF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DoctorCropColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Product Image with Badges
          Container(
            decoration: DoctorCropTheme.cardDecoration(hasShadow: true),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: DoctorCropColors.surfaceMuted,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: DoctorCropColors.textMuted,
                      ),
                    ),
                  ),
                ),

                // Gradient text overlay for contrast
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),

                // Location badge (top left)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: DoctorCropColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          product.location,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Price badge (top right)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: DoctorCropColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${product.priceRwf} RWF",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                // Bottom title & verification
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF4ADE80),
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Certified Doctor Crop Supply",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
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

          const SizedBox(height: 16),

          // Genome AI Helper Card
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GenomeAIPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DoctorCropColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: DoctorCropColors.info.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: DoctorCropColors.info.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: DoctorCropColors.info,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Consult Genome AI Assistant",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: DoctorCropColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Ask about exact dosage, soil application, and harvest compatibility.",
                          style: TextStyle(
                            fontSize: 11.5,
                            color: DoctorCropColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: DoctorCropColors.info,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Specification & Information Breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: DoctorCropTheme.cardDecoration(),
            child: Column(
              children: [
                _infoLine(
                  icon: Icons.description_outlined,
                  title: "Product Description",
                  text: product.description,
                  color: DoctorCropColors.primary,
                ),
                const Divider(height: 24),
                _infoLine(
                  icon: Icons.verified_user_outlined,
                  title: "Certified Agro Seller",
                  text:
                      "Verified retail store in ${product.location}. Products undergo quality review for agricultural authenticity and potency.",
                  color: DoctorCropColors.info,
                ),
                const Divider(height: 24),
                _infoLine(
                  icon: Icons.health_and_safety_outlined,
                  title: "Safety & Application Note",
                  text:
                      "Always verify application timing, protective gear, and dilution rates before applying farm chemicals or treatments.",
                  color: DoctorCropColors.accent,
                ),
                const Divider(height: 24),
                _infoLine(
                  icon: Icons.local_shipping_outlined,
                  title: "Pickup & Delivery",
                  text:
                      "Same-day pickup available at store location or local farm delivery arranged with seller.",
                  color: DoctorCropColors.textPrimary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DoctorCropColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: DoctorCropColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: DoctorCropColors.textPrimary,
                            ),
                          ),
                          Text(
                            "${product.priceRwf} RWF · In stock at ${product.location}",
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: DoctorCropColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Order Confirmation",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DoctorCropColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "By submitting this order, a notification will be delivered directly to the store manager to prepare your package.",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: DoctorCropColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Order placed for ${product.productName}!"),
                          backgroundColor: DoctorCropColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text("Confirm & Place Order"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoLine({
    required IconData icon,
    required String title,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  color: DoctorCropColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
