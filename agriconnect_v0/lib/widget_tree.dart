import 'dart:convert';

import 'package:agriconnect_v0/connect_page.dart';
import 'package:agriconnect_v0/detect_disease.dart';
import 'package:agriconnect_v0/genomePage.dart';
import 'package:agriconnect_v0/home_marketplace.dart';
import 'package:agriconnect_v0/loginpage.dart';
import 'package:agriconnect_v0/forecast_page.dart';
import 'package:agriconnect_v0/notifier.dart';
import 'package:agriconnect_v0/storepages.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeMarketplacePage(),
    DiseaseDetectionPage(),
    AgroChatListPage(),
    WeatherForecastPage(),
  ];

  final List<String> _titles = const [
    "Marketplace",
    "Detect Disease",
    "Connect",
    "News",
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

  void _openDrawerPage(String title, IconData icon, String description) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BasicPage(icon: icon, title: title, description: description),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ValueListenableBuilder<SessionUser?>(
        valueListenable: sessionNotifier,
        builder: (context, user, _) {
          final bool isLoggedIn = user != null;
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(
                              0xFFF97316,
                            ).withOpacity(0.10),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              size: 22,
                              color: Color(0xFFF97316),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLoggedIn ? user.fullName : "Guest Farmer",
                                  style: const TextStyle(
                                    color: Color(0xFF111111),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isLoggedIn
                                      ? user.phoneNumber
                                      : "Not signed in",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isLoggedIn)
                            Text(
                              "Verified",
                              style: TextStyle(
                                color: const Color(0xFF40B37A),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),

                      // ── Guest buttons ──
                      if (!isLoggedIn) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LoginPage(homePage: WidgetTree()),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Sign in",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Menu ────────────────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Light section (Farm Tools + Shopping) ──
                    _menuItem(
                      icon: Icons.shopping_bag_outlined,
                      label: "My Orders",
                      badge: isLoggedIn ? "4" : null,
                      onTap: () => _openDrawerPage(
                        "My Orders",
                        Icons.shopping_bag_outlined,
                        "Track medicine orders, delivery status, and purchase history.",
                      ),
                    ),
                    _menuItem(
                      icon: Icons.auto_awesome_outlined,
                      label: "Genome AI",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GenomeAIPage()),
                      ),
                    ),
                    _menuItem(
                      icon: Icons.document_scanner_outlined,
                      label: "Scanned Diseases",
                      onTap: () => _openDrawerPage(
                        "Disease Scanner",
                        Icons.document_scanner_outlined,
                        "Use your camera to detect crop diseases instantly using AI.",
                      ),
                    ),
                    _sectionLabel("My Store", dark: false),
                    ValueListenableBuilder<StoreSession?>(
                      valueListenable: storeSessionNotifier,
                      builder: (context, store, _) {
                        final bool hasStore = store != null;

                        return Column(
                          children: [
                            // Store Home
                            _gatedMenuItem(
                              icon: Icons.home_outlined,
                              label: "Store Home",
                              active: hasStore,
                              onTap: hasStore
                                  ? () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const StoreHomePage(),
                                        ),
                                      );
                                    }
                                  : null,
                            ),

                            // Store Recording
                            _gatedMenuItem(
                              icon: Icons.currency_exchange,
                              label: "Store Recording",
                              active: hasStore,
                              onTap: hasStore
                                  ? () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const StoreRecordingPage(),
                                        ),
                                      );
                                    }
                                  : null,
                            ),

                            // Store Transactions
                            _gatedMenuItem(
                              icon: Icons.document_scanner,
                              label: "Store Transactions",
                              active: hasStore,
                              onTap: hasStore
                                  ? () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const StoreTransactionsPage(),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        );
                      },
                    ),
                    _menuItem(
                      icon: Icons.info_outline,
                      label: "Store Info",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StoreInfoPage(),
                          ),
                        );
                      },
                    ),

                    Container(
                      width: double.infinity,
                      height: 400,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 32, 32, 32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel("Account", dark: true),
                          _darkMenuItem(
                            icon: Icons.notifications_outlined,
                            label: "Notifications",
                            badge: isLoggedIn ? "2" : null,
                            onTap: () => _openDrawerPage(
                              "Notifications",
                              Icons.notifications_outlined,
                              "Disease alerts, order updates, chat messages, and weather warnings.",
                            ),
                          ),
                          _darkMenuItem(
                            icon: Icons.settings_outlined,
                            label: "Settings",
                            onTap: () => _openDrawerPage(
                              "Settings",
                              Icons.settings_outlined,
                              "Manage language, notifications, privacy, and app preferences.",
                            ),
                          ),
                          _darkMenuItem(
                            icon: Icons.support_agent_outlined,
                            label: "Support",
                            onTap: () => _openDrawerPage(
                              "Support",
                              Icons.support_agent_outlined,
                              "Contact support for help with orders, disease scans, and app issues.",
                            ),
                          ),
                          _darkMenuItem(
                            icon: Icons.info_outline_rounded,
                            label: "About",
                            onTap: () => _openDrawerPage(
                              "About",
                              Icons.info_outline_rounded,
                              "This app helps farmers detect crop diseases, buy medicines, access advice, and connect with others.",
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              color: Colors.white.withOpacity(0.08),
                              height: 1,
                              thickness: 0.5,
                            ),
                          ),

                          _darkMenuItem(
                            icon: isLoggedIn
                                ? Icons.logout_rounded
                                : Icons.swap_horiz_rounded,
                            label: isLoggedIn ? "Sign out" : "Switch account",
                            isDestructive: true,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LoginPage(homePage: WidgetTree()),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────────
  Widget _sectionLabel(String label, {bool dark = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: dark ? Colors.white.withOpacity(0.30) : Colors.grey.shade400,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ── Light menu item ───────────────────────────────────────────────────────────
  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.grey.shade100,
      highlightColor: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 19, color: Colors.grey.shade600),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right, size: 17, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  // ── Dark menu item ────────────────────────────────────────────────────────────
  Widget _darkMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
    bool isDestructive = false,
  }) {
    final Color fg = isDestructive
        ? Colors.orange.shade400
        : Colors.white.withOpacity(0.80);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.04),
      highlightColor: Colors.white.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 19, color: fg.withOpacity(0.70)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                size: 17,
                color: Colors.white.withOpacity(0.15),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    fetchAllProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            _titles[_currentIndex],
            style: const TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Colors.orange,
                size: 18,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // ── Notifications ────────────────────────────────────────────────
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BasicPage(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    description:
                        "Disease alerts, order updates, weather warnings, and chat notifications.",
                  ),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF555555),
                    size: 20,
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "6",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Cart ─────────────────────────────────────────────────────────
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BasicPage(
                    icon: Icons.person,
                    title: "Profile",
                    description:
                        "Manage your farmer profile, location, crops, and account details.",
                  ),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_shopping_cart_outlined,
                color: Color(0xFF555555),
                size: 20,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.8, color: const Color(0xFFEEEEEA)),
        ),
      ),

      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.09),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black54,
          selectedItemColor: Colors.greenAccent.shade200,

          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              activeIcon: Icon(Icons.storefront_outlined),
              label: "Market",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt),
              label: "Detect",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: "Connect",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_outlined),
              activeIcon: Icon(Icons.article),
              label: "Forecast",
            ),
          ],
        ),
      ),
    );
  }

  Widget _gatedMenuItem({
    required IconData icon,
    required String label,
    required bool active,
    VoidCallback? onTap,
  }) {
    final Color iconColor = active
        ? Colors.grey.shade600
        : Colors.grey.shade300;
    final Color labelColor = active
        ? const Color(0xFF1A1A1A)
        : Colors.grey.shade300;

    return InkWell(
      onTap: active ? onTap : null,
      splashColor: active ? Colors.grey.shade100 : Colors.transparent,
      highlightColor: active ? Colors.grey.shade50 : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 19, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (!active)
              // Small lock badge when store not connected
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Connect store",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right, size: 17, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}

class BasicPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const BasicPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 72, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
