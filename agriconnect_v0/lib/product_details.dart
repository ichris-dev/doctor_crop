import 'package:agriconnect_v0/genomePage.dart';
import 'package:agriconnect_v0/notifier.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  String _shortDescription(String text) {
    if (text.length <= 120) return text;
    return "${text.substring(0, 120)}...";
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF101214);
    const green = Color(0xFF22C55E);
    const blue = Color(0xFF2563EB);
    const orange = Color(0xFFF97316);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black54,
            size: 15,
          ),
        ),
        title: Column(
          spacing: 5,
          children: [
            Row(
              spacing: 10,
              children: [
                Text(
                  "Green Valley Agro Store",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Icon(Icons.verified, color: green, size: 18),
              ],
            ),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Musanze, Rwanda",
                      style: TextStyle(color: Colors.black87, fontSize: 10.5),
                    ),
                  ],
                ),
                Spacer(),
                const Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 15, color: Colors.black45),
                    SizedBox(width: 6),
                    Text(
                      "+250 788 123 456",
                      style: TextStyle(color: Colors.black54, fontSize: 10.5),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_outlined,
                color: Color(0xFF555555),
                size: 18,
              ),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 8, bottom: 8, right: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.favorite_border_rounded,
                color: Color(0xFF555555),
                size: 18,
              ),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.8, color: const Color(0xFFEEEEEA)),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.07)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: const Text("Order"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: 15, left: 10, right: 10),
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 🌙 Dark gradient for text readability
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,

                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // 🏷️ Category badge (top left)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "category",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // 💰 Price badge (top right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${product.priceRwf}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // 🧠 Bottom text overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(
                              Icons.verified,
                              color: Color(0xFF22C55E),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Verified Farm Product",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 16, 5, 95),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store card
                    const SizedBox(height: 14),

                    // One combined description card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _infoLine(
                            icon: Icons.description_outlined,
                            title: "Description",
                            text: _shortDescription(product.description),
                            color: green,
                          ),
                          const Divider(height: 22),

                          _infoLine(
                            icon: Icons.verified_user_outlined,
                            title: "Seller information",
                            text:
                                "Verified agro-seller. Contact the store to confirm stock, quantity, and delivery.",
                            color: blue,
                          ),
                          const Divider(height: 22),

                          _infoLine(
                            icon: Icons.health_and_safety_outlined,
                            title: "Usage note",
                            text:
                                "For farm medicines, confirm dosage and safety guidance with an agronomist or veterinarian.",
                            color: orange,
                          ),
                          const Divider(height: 22),

                          _infoLine(
                            icon: Icons.local_shipping_outlined,
                            title: "Delivery",
                            text:
                                "Delivery depends on location, order size, and seller agreement.",
                            color: black,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: blue.withOpacity(0.18)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: blue,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Genome AI can explain product usage, benefits, risks, storage, and market value.",
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.45,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Positioned(
          //   bottom: 60, // 👈 IMPORTANT (see below)
          //   right: 16,
          //   child: Container(
          //     padding: EdgeInsets.all(10),
          //     decoration: BoxDecoration(
          //       color: Colors.blue,
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     child: Icon(Icons.message_outlined, color: Colors.white),
          //   ),
          // ),
          Positioned(
            bottom: 60, // 👈 IMPORTANT (see below)
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.message_outlined, size: 20),
              label: const Text("Message"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 10, // 👈 IMPORTANT (see below)
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GenomeAIPage()),
                );
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: const Text("Genome AI"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
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
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _traditionalBox({required String title, required String text}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF101214),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
