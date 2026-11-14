import 'dart:convert';
import 'package:agriconnect_v0/connect_page.dart';
import 'package:agriconnect_v0/detect_disease.dart';
import 'package:agriconnect_v0/genomePage.dart';
import 'package:agriconnect_v0/home_marketplace.dart';
import 'package:agriconnect_v0/loginpage.dart';
import 'package:agriconnect_v0/forecast_page.dart';
import 'package:agriconnect_v0/notifier.dart';
import 'package:agriconnect_v0/seasonal_page.dart';
import 'package:agriconnect_v0/storepages.dart';
import 'package:agriconnect_v0/theme/app_theme.dart';
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
    "Forecast & News",
  ];

  final List<String> _subtitles = const [
    "Verified agro inputs & tools",
    "AI leaf disease diagnosis",
    "Agronomists & farmers near you",
    "Real-time Rwandan weather & alerts",
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
    } catch (e) {
      // Retain gracefully if backend is offline during preview
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

          return Column(
            children: [
              // ── Header Profile Area ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
                decoration: const BoxDecoration(
                  color: DoctorCropColors.surface,
                  border: Border(
                    bottom: BorderSide(color: DoctorCropColors.border, width: 0.9),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isLoggedIn
                                ? DoctorCropColors.primaryLight
                                : DoctorCropColors.accentLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLoggedIn
                                  ? DoctorCropColors.primary.withOpacity(0.3)
                                  : DoctorCropColors.accent.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isLoggedIn
                                ? Icons.person_rounded
                                : Icons.person_outline_rounded,
                            size: 24,
                            color: isLoggedIn
                                ? DoctorCropColors.primary
                                : DoctorCropColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLoggedIn ? user.fullName : "Guest Farmer",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: DoctorCropColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isLoggedIn
                                    ? user.phoneNumber
                                    : "Sign in to unlock all features",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: DoctorCropColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isLoggedIn)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: DoctorCropColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 11,
                                  color: DoctorCropColors.primary,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  "Verified",
                                  style: TextStyle(
                                    color: DoctorCropColors.primary,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Guest Actions
                    if (!isLoggedIn) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LoginPage(homePage: const WidgetTree()),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DoctorCropColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Sign in",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const BasicPage(
                                          icon: Icons.person_add_outlined,
                                          title: "Create Account",
                                          description: "Sign in or register from the sign in page to set up your farmer profile.",
                                        ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: DoctorCropColors.textPrimary,
                                side: const BorderSide(
                                  color: DoctorCropColors.border,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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

              // ── Scrollable Menu List ─────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _sectionLabel("Farm & AI Services"),
                    _menuItem(
                      icon: Icons.document_scanner_rounded,
                      label: "Disease Scanner",
                      accentColor: DoctorCropColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 1);
                      },
                    ),
                    _menuItem(
                      icon: Icons.auto_awesome_rounded,
                      label: "Genome AI Assistant",
                      accentColor: DoctorCropColors.info,
                      badge: "AI",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GenomeAIPage()),
                        );
                      },
                    ),
                    _menuItem(
                      icon: Icons.shopping_bag_outlined,
                      label: "My Orders",
                      badge: isLoggedIn ? "4" : null,
                      onTap: () => _openDrawerPage(
                        "My Orders",
                        Icons.shopping_bag_outlined,
                        "Track agricultural supplies, delivery updates, and store receipts.",
                      ),
                    ),
                    _menuItem(
                      icon: Icons.calendar_month_outlined,
                      label: "Seasonal Records",
                      badge: "New",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SeasonalPage(),
                          ),
                        );
                      },
                    ),

                    const Divider(height: 20),
                    _sectionLabel("My Agro Store"),
                    ValueListenableBuilder<StoreSession?>(
                      valueListenable: storeSessionNotifier,
                      builder: (context, store, _) {
                        final bool hasStore = store != null;

                        return Column(
                          children: [
                            _gatedMenuItem(
                              icon: Icons.storefront_outlined,
                              label: "Store Home",
                              active: hasStore,
                              onTap: hasStore
                                  ? () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const StoreHomePage(),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                            _gatedMenuItem(
                              icon: Icons.receipt_long_outlined,
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
                            _gatedMenuItem(
                              icon: Icons.swap_horiz_rounded,
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
                            _menuItem(
                              icon: Icons.info_outline_rounded,
                              label: "Store Information",
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
                          ],
                        );
                      },
                    ),

                    const Divider(height: 20),
                    _sectionLabel("Account & Support"),
                    _menuItem(
                      icon: Icons.notifications_none_rounded,
                      label: "Notifications",
                      badge: isLoggedIn ? "2" : null,
                      onTap: () => _openDrawerPage(
                        "Notifications",
                        Icons.notifications_none_rounded,
                        "Crop disease warnings, store updates, community replies, and weather alerts.",
                      ),
                    ),
                    _menuItem(
                      icon: Icons.tune_rounded,
                      label: "Settings",
                      onTap: () => _openDrawerPage(
                        "Settings",
                        Icons.tune_rounded,
                        "Manage language (Kinyarwanda/English), alert thresholds, and farm preferences.",
                      ),
                    ),
                    _menuItem(
                      icon: Icons.support_agent_rounded,
                      label: "Help & Support",
                      onTap: () => _openDrawerPage(
                        "Support",
                        Icons.support_agent_rounded,
                        "Need assistance with diagnostic accuracy, deliveries, or farm consulting? Our agronomists are available.",
                      ),
                    ),
                    _menuItem(
                      icon: Icons.info_outline_rounded,
                      label: "About Doctor Crop",
                      onTap: () => _openDrawerPage(
                        "About Doctor Crop",
                        Icons.eco_rounded,
                        "Doctor Crop connects Rwandan farmers with instant disease diagnostics, certified agro-veterinary shops, and verified agronomists.",
                      ),
                    ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLoggedIn
                              ? DoctorCropColors.accentLight.withOpacity(0.4)
                              : DoctorCropColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _menuItem(
                          icon: isLoggedIn
                              ? Icons.logout_rounded
                              : Icons.login_rounded,
                          label: isLoggedIn ? "Sign out" : "Sign in to Account",
                          accentColor: isLoggedIn
                              ? DoctorCropColors.accentDark
                              : DoctorCropColors.primary,
                          onTap: () {
                            Navigator.pop(context);
                            if (isLoggedIn) {
                              sessionNotifier.value = null;
                              storeSessionNotifier.value = null;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LoginPage(homePage: const WidgetTree()),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Drawer Footer Version
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: const Text(
                  "Doctor Crop v1.0.0 · Production Ready",
                  style: TextStyle(
                    fontSize: 11,
                    color: DoctorCropColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: DoctorCropColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? accentColor,
    String? badge,
  }) {
    final color = accentColor ?? DoctorCropColors.textSecondary;
    return InkWell(
      onTap: onTap,
      splashColor: DoctorCropColors.primaryLight.withOpacity(0.5),
      highlightColor: DoctorCropColors.primaryLight.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (accentColor ?? DoctorCropColors.primary).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: DoctorCropColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: DoctorCropColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: DoctorCropColors.textMuted,
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
    return InkWell(
      onTap: active ? onTap : null,
      splashColor: active ? DoctorCropColors.primaryLight : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: active
                    ? DoctorCropColors.primary.withOpacity(0.08)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: active
                    ? DoctorCropColors.primary
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: active
                      ? DoctorCropColors.textPrimary
                      : Colors.grey.shade400,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!active)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 0.8),
                ),
                child: const Text(
                  "Not connected",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: DoctorCropColors.textMuted,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _titles[_currentIndex],
              style: const TextStyle(
                color: DoctorCropColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 19,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              _subtitles[_currentIndex],
              style: const TextStyle(
                color: DoctorCropColors.textMuted,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: DoctorCropColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DoctorCropColors.border, width: 0.9),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: DoctorCropColors.primary,
                size: 20,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // ── Notifications ───────────────────────────────────────────
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BasicPage(
                    icon: Icons.notifications_active_outlined,
                    title: "Farm Alerts & Notifications",
                    description:
                        "Stay notified with instant crop disease detection reports, marketplace updates, agronomist advice, and weather alerts.",
                  ),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: DoctorCropColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DoctorCropColors.border, width: 0.9),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: DoctorCropColors.textSecondary,
                    size: 20,
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: DoctorCropColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Quick Profile / Cart Action ─────────────────────────────
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BasicPage(
                    icon: Icons.account_circle_outlined,
                    title: "Farmer Profile",
                    description:
                        "View and manage your registered farmer credentials, designated farm location in Rwanda, active crop varieties, and orders.",
                  ),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: DoctorCropColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DoctorCropColors.border, width: 0.9),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_outline_rounded,
                color: DoctorCropColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.9, color: DoctorCropColors.border),
        ),
      ),

      body: IndexedStack(index: _currentIndex, children: _pages),

      // ── Clean Elevated Modern Bottom Navigation ───────────────────────
      bottomNavigationBar: Container(
        decoration: DoctorCropTheme.bottomNavDecoration(),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: DoctorCropColors.primary,
            unselectedItemColor: DoctorCropColors.textMuted,
            elevation: 0,
            selectedFontSize: 11.5,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.storefront_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.storefront_rounded),
                ),
                label: "Market",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.document_scanner_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.document_scanner_rounded),
                ),
                label: "Detect",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.forum_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.forum_rounded),
                ),
                label: "Connect",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.cloud_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.cloud_rounded),
                ),
                label: "Forecast",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standalone Full-Featured Detail / Placeholder Screen with Back Button & Helpful Actions
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
      backgroundColor: DoctorCropColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
              size: 16,
              color: DoctorCropColors.textPrimary,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: DoctorCropColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.9, color: DoctorCropColors.border),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: DoctorCropColors.primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: DoctorCropColors.primary.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 44,
                    color: DoctorCropColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: DoctorCropColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: DoctorCropTheme.cardDecoration(),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DoctorCropColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Return to Previous Screen"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
