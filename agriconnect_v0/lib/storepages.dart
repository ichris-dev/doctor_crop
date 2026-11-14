import 'dart:math';
import 'package:agriconnect_v0/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:agriconnect_v0/notifier.dart';

// ─────────────────────────────────────────────────────────────
//  SHARED: Back button with background
// ─────────────────────────────────────────────────────────────
Widget _backBtn(BuildContext context) {
  return GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
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
  );
}

// ─────────────────────────────────────────────────────────────
//  SHARED AppBar
// ─────────────────────────────────────────────────────────────
AppBar _buildAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leadingWidth: 54,
    leading: Center(child: _backBtn(context)),
    title: Text(
      title,
      style: const TextStyle(
        color: DoctorCropColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 0.9, color: DoctorCropColors.border),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  SHARED Modern BottomNav
// ─────────────────────────────────────────────────────────────
Widget _sharedBottomNav({
  required int currentIndex,
  required ValueChanged<int> onTap,
  required List<BottomNavigationBarItem> items,
}) {
  return Container(
    decoration: DoctorCropTheme.bottomNavDecoration(),
    child: SafeArea(
      top: false,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: DoctorCropColors.primary,
        unselectedItemColor: DoctorCropColors.textMuted,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        items: items,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  SHARED: No-store locked view
// ─────────────────────────────────────────────────────────────
Widget _noStoreView(BuildContext context, String pageName) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: DoctorCropTheme.cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DoctorCropColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 34,
                color: DoctorCropColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "$pageName Unavailable",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: DoctorCropColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You currently do not have a verified agro store linked to this farmer account. Contact Doctor Crop support to register your agro-dealership.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: DoctorCropColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Return to Previous Screen"),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  SHARED: Marketplace-style product card
// ─────────────────────────────────────────────────────────────
Widget _marketCard(
  BuildContext context,
  StoreProduct p, {
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 185,
      decoration: DoctorCropTheme.cardDecoration(radius: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            p.imageUrl,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, prog) {
              if (prog == null) return child;
              return Container(
                height: 130,
                color: DoctorCropColors.surfaceMuted,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              height: 130,
              color: DoctorCropColors.surfaceMuted,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: DoctorCropColors.textMuted,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: DoctorCropColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p.location,
                    style: const TextStyle(
                      color: DoctorCropColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DoctorCropColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  p.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DoctorCropColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${p.priceRwf} RWF",
                      style: const TextStyle(
                        color: DoctorCropColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: DoctorCropColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: DoctorCropColors.primary,
                        size: 14,
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

// ─────────────────────────────────────────────────────────────
//  CATEGORY CHIPS
// ─────────────────────────────────────────────────────────────
const List<String> _kCats = [
  "All",
  "Fertilizer",
  "Pesticide",
  "Seeds",
  "Medicine",
  "Herbicide",
  "Insecticide",
  "Veterinary",
];

Widget _catChips(String selected, ValueChanged<String> onSelect) {
  return SizedBox(
    height: 36,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _kCats.length,
      itemBuilder: (_, i) {
        final cat = _kCats[i];
        final sel = selected == cat;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: sel ? DoctorCropColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel ? DoctorCropColors.primary : DoctorCropColors.border,
                width: 0.9,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              cat,
              style: TextStyle(
                color: sel ? Colors.white : DoctorCropColors.textSecondary,
                fontSize: 11.5,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  STORE INFO PAGE
// ═══════════════════════════════════════════════════════════════
class StoreInfoPage extends StatelessWidget {
  const StoreInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      appBar: _buildAppBar(context, "Store Information"),
      body: ValueListenableBuilder<StoreSession?>(
        valueListenable: storeSessionNotifier,
        builder: (context, store, _) {
          if (store == null) return _noStoreView(context, "Store Info");
          return _body(context, store);
        },
      ),
    );
  }

  Widget _body(BuildContext context, StoreSession store) {
    final total = store.products.fold<int>(0, (s, p) => s + p.priceRwf);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DoctorCropColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: DoctorCropColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DoctorCropColors.primary.withOpacity(0.35),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: DoctorCropColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.storeName,
                            style: const TextStyle(
                              color: DoctorCropColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: DoctorCropColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: DoctorCropColors.primary,
                                size: 12,
                              ),
                              SizedBox(width: 3),
                              Text(
                                "Verified",
                                style: TextStyle(
                                  color: DoctorCropColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Store is live and visible to registered farmers across Rwanda.",
                      style: TextStyle(
                        color: DoctorCropColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _pill(
                          Icons.location_on_outlined,
                          store.storeLocation,
                          DoctorCropColors.accent,
                        ),
                        const SizedBox(width: 6),
                        _pill(
                          Icons.phone_outlined,
                          store.storePhone,
                          DoctorCropColors.primary,
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

        // Business Performance Chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: DoctorCropTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "STORE REVENUE PERFORMANCE",
                          style: TextStyle(
                            color: DoctorCropColors.textMuted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "5-Month Actuals + 3-Month Projection",
                          style: TextStyle(
                            color: DoctorCropColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _legendDot(DoctorCropColors.primary, "Actual"),
                      const SizedBox(width: 10),
                      _legendDot(DoctorCropColors.accent, "Forecast"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(height: 150, child: _PerformanceChart()),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Info List
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: DoctorCropTheme.cardDecoration(),
          child: Column(
            children: [
              _row(
                Icons.store_outlined,
                "Store Name",
                store.storeName,
                DoctorCropColors.primary,
              ),
              _div(),
              _row(
                Icons.phone_outlined,
                "Official Phone",
                store.storePhone,
                DoctorCropColors.primary,
              ),
              _div(),
              _row(
                Icons.location_on_outlined,
                "Location / Region",
                store.storeLocation,
                DoctorCropColors.accent,
              ),
              _div(),
              _row(
                Icons.inventory_2_outlined,
                "Catalogued Products",
                "${store.products.length} items",
                DoctorCropColors.primary,
              ),
              _div(),
              _row(
                Icons.payments_outlined,
                "Total Inventory Valuation",
                "${_fmt(total.toDouble())} RWF",
                DoctorCropColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: DoctorCropColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: DoctorCropColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _div() => const Divider(height: 1, color: DoctorCropColors.borderLight);

  String _fmt(double v) {
    if (v >= 1000000) return "${(v / 1000000).toStringAsFixed(1)}M";
    if (v >= 1000) return "${(v / 1000).toStringAsFixed(0)}K";
    return v.toStringAsFixed(0);
  }
}

// ─────────────────────────────────────────────────────────────
//  PERFORMANCE CHART PAINTER
// ─────────────────────────────────────────────────────────────
class _PerformanceChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ChartPainter(), child: const SizedBox.expand());
}

class _ChartPainter extends CustomPainter {
  static const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
  ];
  static const vals = [120.0, 210, 175, 290, 340, 390, 430, 480];
  static const solid = 5;

  @override
  void paint(Canvas canvas, Size size) {
    const pL = 40.0, pR = 12.0, pT = 8.0, pB = 28.0;
    final w = size.width - pL - pR;
    final h = size.height - pT - pB;
    final maxV = vals.reduce(max) * 1.15;
    const gridN = 4;
    const lStyle = TextStyle(color: DoctorCropColors.textMuted, fontSize: 8.5);

    final gp = Paint()
      ..color = DoctorCropColors.borderLight
      ..strokeWidth = 0.8;
    for (int i = 0; i <= gridN; i++) {
      final y = pT + h - h * i / gridN;
      canvas.drawLine(Offset(pL, y), Offset(pL + w, y), gp);
      final tp = TextPainter(
        text: TextSpan(text: '${(maxV * i / gridN).round()}K', style: lStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final xS = w / (vals.length - 1);
    for (int i = 0; i < vals.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: lStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pL + i * xS - tp.width / 2, pT + h + 6));
    }

    final pts = [
      for (int i = 0; i < vals.length; i++)
        Offset(pL + i * xS, pT + h - h * vals[i] / maxV),
    ];

    // Solid line
    final sp = Paint()
      ..color = DoctorCropColors.primary
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..let((p) {
          for (int i = 1; i < solid; i++) p.lineTo(pts[i].dx, pts[i].dy);
          return p;
        }),
      sp,
    );

    // Fill
    final fp = Path()..moveTo(pts[0].dx, pT + h);
    for (int i = 0; i < solid; i++) fp.lineTo(pts[i].dx, pts[i].dy);
    fp
      ..lineTo(pts[solid - 1].dx, pT + h)
      ..close();
    canvas.drawPath(
      fp,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DoctorCropColors.primary.withOpacity(0.18),
            DoctorCropColors.primary.withOpacity(0.01),
          ],
        ).createShader(Rect.fromLTWH(0, pT, size.width, h))
        ..style = PaintingStyle.fill,
    );

    // Dotted forecast line
    final dp = Paint()
      ..color = DoctorCropColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int i = solid - 1; i < pts.length - 1; i++) {
      _dash(canvas, pts[i], pts[i + 1], dp);
    }

    // Dots solid
    for (int i = 0; i < solid; i++) {
      canvas.drawCircle(pts[i], 3.5, Paint()..color = DoctorCropColors.primary);
      canvas.drawCircle(
        pts[i],
        3.5,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
    // Dots forecast
    for (int i = solid; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 3.5, Paint()..color = DoctorCropColors.accent);
      canvas.drawCircle(
        pts[i],
        3.5,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _dash(Canvas canvas, Offset a, Offset b, Paint p) {
    const dl = 5.0, gl = 4.0;
    final dx = b.dx - a.dx, dy = b.dy - a.dy;
    final dist = sqrt(dx * dx + dy * dy);
    final ux = dx / dist, uy = dy / dist;
    double d = 0;
    bool draw = true;
    while (d < dist) {
      final e = min(d + (draw ? dl : gl), dist);
      if (draw)
        canvas.drawLine(
          Offset(a.dx + ux * d, a.dy + uy * d),
          Offset(a.dx + ux * e, a.dy + uy * e),
          p,
        );
      d = e;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

extension _PathEx on Path {
  Path let(Path Function(Path) fn) => fn(this);
}

// ═══════════════════════════════════════════════════════════════
//  STORE HOME PAGE
// ═══════════════════════════════════════════════════════════════
class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});
  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  String _search = "";
  String _cat = "All";

  List<StoreProduct> _filter(List<StoreProduct> all) => all.where((p) {
    final ms =
        p.productName.toLowerCase().contains(_search.toLowerCase()) ||
        p.description.toLowerCase().contains(_search.toLowerCase());
    final mc =
        _cat == "All" ||
        p.productName.toLowerCase().contains(_cat.toLowerCase()) ||
        p.description.toLowerCase().contains(_cat.toLowerCase());
    return ms && mc;
  }).toList();

  List<List<StoreProduct>> _chunk(List<StoreProduct> list) {
    final c = <List<StoreProduct>>[];
    for (int i = 0; i < list.length; i += 6) {
      c.add(list.sublist(i, min(i + 6, list.length)));
    }
    return c;
  }

  static const _titles = [
    "Your Catalogued Products",
    "Popular Treatments",
    "Seasonal Demand Items",
    "More Store Products",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      appBar: _buildAppBar(context, "Store Home"),
      body: ValueListenableBuilder<StoreSession?>(
        valueListenable: storeSessionNotifier,
        builder: (context, store, _) {
          if (store == null) return _noStoreView(context, "Store Home");
          final filtered = _filter(store.products);
          final chunks = _chunk(filtered);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DoctorCropColors.border,
                        width: 0.9,
                      ),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v.trim()),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: DoctorCropColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: DoctorCropColors.textMuted,
                          size: 20,
                        ),
                        hintText: "Search store inventory...",
                        hintStyle: TextStyle(
                          color: DoctorCropColors.textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: _catChips(_cat, (c) => setState(() => _cat = c)),
                ),
              ),
              if (filtered.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        "No products found matching criteria",
                        style: TextStyle(
                          color: DoctorCropColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                )
              else
                for (int ci = 0; ci < chunks.length; ci++) ...[
                  SliverToBoxAdapter(
                    child: _secTitle(
                      ci < _titles.length ? _titles[ci] : "More Products",
                    ),
                  ),
                  SliverToBoxAdapter(child: _row(context, chunks[ci])),
                ],
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: ValueListenableBuilder<StoreSession?>(
        valueListenable: storeSessionNotifier,
        builder: (_, store, __) {
          if (store == null) return const SizedBox();
          return FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Add product feature: connect camera or scanner"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            backgroundColor: DoctorCropColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              "Add Product",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _secTitle(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          t,
          style: const TextStyle(
            color: DoctorCropColors.textPrimary,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          "See all",
          style: TextStyle(
            color: DoctorCropColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _row(BuildContext context, List<StoreProduct> items) => SizedBox(
    height: 275,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) => _marketCard(
        context,
        items[i],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreProductDetailPage(product: items[i]),
            ),
          );
        },
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  STORE PRODUCT DETAIL PAGE
// ═══════════════════════════════════════════════════════════════
class StoreProductDetailPage extends StatelessWidget {
  final StoreProduct product;
  const StoreProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      appBar: _buildAppBar(context, product.productName),
      body: ListView(
        children: [
          Stack(
            children: [
              Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 220, color: DoctorCropColors.surfaceMuted),
              ),
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
              Positioned(
                top: 14,
                right: 14,
                child: _badge("${product.priceRwf} RWF", DoctorCropColors.accent),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  product.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PRODUCT DESCRIPTION",
                        style: TextStyle(
                          color: DoctorCropColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: DoctorCropColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  Column(
                    children: [
                      _dr(
                        Icons.payments_outlined,
                        "Retail Price",
                        "${product.priceRwf} RWF",
                        DoctorCropColors.accent,
                      ),
                      const Divider(height: 18),
                      _dr(
                        Icons.location_on_outlined,
                        "Designated Store",
                        product.location,
                        DoctorCropColors.primary,
                      ),
                      const Divider(height: 18),
                      _dr(
                        Icons.calendar_today_outlined,
                        "Registered Date",
                        "${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}",
                        DoctorCropColors.textMuted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DoctorCropColors.info.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: DoctorCropColors.info.withOpacity(0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: DoctorCropColors.info,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Genome AI can assist with dosage, dilution ratios, shelf storage, and active ingredients.",
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: DoctorCropColors.textSecondary,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Editing product details"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("Edit Product"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorCropColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StoreRecordingPage(),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart_checkout, size: 18),
              label: const Text("Record Sale"),
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorCropColors.accent,
                minimumSize: const Size(130, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: DoctorCropTheme.cardDecoration(),
    child: child,
  );

  Widget _dr(IconData icon, String label, String value, Color c) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: c.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: c),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(
          color: DoctorCropColors.textSecondary,
          fontSize: 12.5,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          color: DoctorCropColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _badge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  STORE RECORDING PAGE
// ═══════════════════════════════════════════════════════════════
class StoreRecordingPage extends StatefulWidget {
  const StoreRecordingPage({super.key});
  @override
  State<StoreRecordingPage> createState() => _StoreRecordingPageState();
}

class _StoreRecordingPageState extends State<StoreRecordingPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      appBar: _buildAppBar(context, "Record Store Sale"),
      body: ValueListenableBuilder<StoreSession?>(
        valueListenable: storeSessionNotifier,
        builder: (context, store, _) {
          if (store == null) return _noStoreView(context, "Store Recording");
          return IndexedStack(
            index: _tab,
            children: [
              _SaleForm(saleType: "direct", products: store.products),
              _SaleForm(saleType: "debt", products: store.products),
            ],
          );
        },
      ),
      bottomNavigationBar: _sharedBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: "Direct Sale",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty_rounded),
            activeIcon: Icon(Icons.hourglass_bottom_rounded),
            label: "On Debt",
          ),
        ],
      ),
    );
  }
}

class _SaleForm extends StatefulWidget {
  final String saleType;
  final List<StoreProduct> products;
  const _SaleForm({required this.saleType, required this.products});
  @override
  State<_SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends State<_SaleForm> {
  StoreProduct? _sel;
  final _qty = TextEditingController();
  final _cust = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();
  String _pay = "Cash";
  final List<String> _pays = ["Cash", "Mobile Money", "Bank Transfer"];
  bool _saving = false;

  int get _total => (_sel?.priceRwf ?? 0) * (int.tryParse(_qty.text) ?? 0);

  @override
  Widget build(BuildContext context) {
    final isDebt = widget.saleType == "debt";
    final accent = isDebt ? DoctorCropColors.accent : DoctorCropColors.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sec("1. Select Inventory Product"),
        _drop(),
        const SizedBox(height: 12),
        _field(
          _qty,
          "Quantity to Sell",
          Icons.numbers_rounded,
          accent,
          keyboard: TextInputType.number,
        ),

        const SizedBox(height: 20),
        _sec("2. Customer Information"),
        _field(_cust, "Farmer / Customer name", Icons.person_outline, accent),
        const SizedBox(height: 10),
        _field(
          _phone,
          "Customer phone number",
          Icons.phone_outlined,
          accent,
          keyboard: TextInputType.phone,
        ),

        const SizedBox(height: 20),
        _sec("3. Payment Method"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _pays.map((m) {
            final sel = _pay == m;
            return GestureDetector(
              onTap: () => setState(() => _pay = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: sel ? accent : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel ? accent : DoctorCropColors.border,
                  ),
                ),
                child: Text(
                  m,
                  style: TextStyle(
                    color: sel ? Colors.white : DoctorCropColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        _sec("4. Transaction Notes (Optional)"),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DoctorCropColors.border, width: 0.8),
          ),
          child: TextField(
            controller: _note,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 13.5,
              color: DoctorCropColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: "Add specific instructions, harvest notes, or payment terms...",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Total Amount Calculation Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: DoctorCropTheme.cardDecoration(hasShadow: true),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TOTAL SALE REVENUE",
                    style: TextStyle(
                      color: accent,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _qty,
                    builder: (_, __, ___) => Text(
                      _total > 0 ? "$_total RWF" : "0 RWF",
                      style: TextStyle(
                        color: DoctorCropColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (_sel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: DoctorCropColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${_sel!.priceRwf} × ${_qty.text.isEmpty ? 0 : _qty.text} units",
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _sel!.productName,
                        style: const TextStyle(
                          color: DoctorCropColors.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    await Future.delayed(const Duration(milliseconds: 600));
                    setState(() => _saving = false);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isDebt ? "Debt sale recorded in store ledger!" : "Sale recorded successfully!",
                        ),
                        backgroundColor: accent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            icon: Icon(
              isDebt
                  ? Icons.hourglass_bottom_rounded
                  : Icons.check_circle_outline,
              size: 18,
            ),
            label: Text(
              _saving
                  ? "Recording..."
                  : isDebt
                      ? "Record Debt Sale"
                      : "Confirm & Record Direct Sale",
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _drop() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: DoctorCropColors.border, width: 0.8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<StoreProduct>(
        value: _sel,
        hint: const Text(
          "Choose a product from store inventory",
          style: TextStyle(color: DoctorCropColors.textMuted, fontSize: 13),
        ),
        isExpanded: true,
        items: widget.products
            .map(
              (p) => DropdownMenuItem(
                value: p,
                child: Text(
                  "${p.productName}  •  ${p.priceRwf} RWF",
                  style: const TextStyle(
                    fontSize: 13,
                    color: DoctorCropColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (p) => setState(() => _sel = p),
      ),
    ),
  );

  Widget _sec(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
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

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    Color accent, {
    TextInputType keyboard = TextInputType.text,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: DoctorCropColors.border, width: 0.8),
    ),
    child: TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(
        fontSize: 13.5,
        color: DoctorCropColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: DoctorCropColors.textMuted,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, size: 18, color: accent),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  STORE TRANSACTIONS PAGE
// ═══════════════════════════════════════════════════════════════
class StoreTransactionsPage extends StatefulWidget {
  const StoreTransactionsPage({super.key});
  @override
  State<StoreTransactionsPage> createState() => _StoreTransactionsPageState();
}

class _StoreTransactionsPageState extends State<StoreTransactionsPage> {
  int _tab = 0;
  String _search = "";
  String _sort = "Newest";
  final List<String> _sortOpts = ["Newest", "Oldest", "Highest", "Lowest"];

  final List<_TxRecord> _sales = [
    _TxRecord(
      customer: "Alice Uwimana",
      product: "BIOCARB 50 SC",
      amount: 12000,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      method: "Cash",
      isDebt: false,
    ),
    _TxRecord(
      customer: "Jean Paul Habimana",
      product: "BROMEX F",
      amount: 10000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      method: "Mobile Money",
      isDebt: true,
    ),
    _TxRecord(
      customer: "Diane Mukamana",
      product: "GITENGE 50% WP",
      amount: 14000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      method: "Cash",
      isDebt: false,
    ),
    _TxRecord(
      customer: "Emmanuel Nkurunziza",
      product: "DELTA GOLD",
      amount: 8000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      method: "Bank Transfer",
      isDebt: false,
    ),
    _TxRecord(
      customer: "Alice Uwimana",
      product: "RIOMAX",
      amount: 8500,
      date: DateTime.now().subtract(const Duration(days: 4)),
      method: "Cash",
      isDebt: false,
    ),
  ];

  List<_TxRecord> _filteredSales() {
    var list = _sales
        .where(
          (tx) =>
              tx.customer.toLowerCase().contains(_search.toLowerCase()) ||
              tx.product.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
    switch (_sort) {
      case "Oldest":
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case "Highest":
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case "Lowest":
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      default:
        list.sort((a, b) => b.date.compareTo(a.date));
    }
    return list;
  }

  List<_TxRecord> _filteredCustomers() {
    final Map<String, _TxRecord> seen = {};
    for (final tx in _sales) seen.putIfAbsent(tx.customer, () => tx);
    return seen.values
        .where((c) => c.customer.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      appBar: _buildAppBar(context, "Ledger & Transactions"),
      body: ValueListenableBuilder<StoreSession?>(
        valueListenable: storeSessionNotifier,
        builder: (context, store, _) {
          if (store == null) return _noStoreView(context, "Transactions");
          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: DoctorCropColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: DoctorCropColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v.trim()),
                          style: const TextStyle(
                            fontSize: 13,
                            color: DoctorCropColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: DoctorCropColors.textMuted,
                              size: 18,
                            ),
                            hintText: "Search transaction or customer...",
                            hintStyle: TextStyle(
                              color: DoctorCropColors.textMuted,
                              fontSize: 12.5,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sortSheet(context),
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: DoctorCropColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: DoctorCropColors.primary.withOpacity(0.2),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.sort_rounded,
                          color: DoctorCropColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 0.9, color: DoctorCropColors.border),
              Expanded(
                child: IndexedStack(
                  index: _tab,
                  children: [_customersList(), _salesList()],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _sharedBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline_rounded),
            activeIcon: const Icon(Icons.people_rounded),
            label: "Customers (${_filteredCustomers().length})",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long_rounded),
            label: "Sales (${_filteredSales().length})",
          ),
        ],
      ),
    );
  }

  Widget _customersList() {
    final list = _filteredCustomers();
    if (list.isEmpty) {
      return const Center(
        child: Text("No customers found", style: TextStyle(color: DoctorCropColors.textMuted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final c = list[i];
        final all = _sales.where((s) => s.customer == c.customer).toList();
        final total = all.fold<int>(0, (s, tx) => s + tx.amount);
        final hasDebt = all.any((s) => s.isDebt);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: DoctorCropTheme.cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DoctorCropColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  c.customer.isNotEmpty ? c.customer[0] : "C",
                  style: const TextStyle(
                    color: DoctorCropColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.customer,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DoctorCropColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${all.length} registered transaction${all.length == 1 ? '' : 's'}",
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: DoctorCropColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$total RWF",
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: DoctorCropColors.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: hasDebt
                          ? DoctorCropColors.accentLight
                          : DoctorCropColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hasDebt ? "Has active debt" : "Fully cleared",
                      style: TextStyle(
                        fontSize: 10,
                        color: hasDebt
                            ? DoctorCropColors.accentDark
                            : DoctorCropColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _salesList() {
    final list = _filteredSales();
    if (list.isEmpty) {
      return const Center(
        child: Text("No transactions recorded", style: TextStyle(color: DoctorCropColors.textMuted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final tx = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: DoctorCropTheme.cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tx.isDebt
                      ? DoctorCropColors.accentLight
                      : DoctorCropColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  tx.isDebt
                      ? Icons.hourglass_bottom_rounded
                      : Icons.check_circle_outline_rounded,
                  color: tx.isDebt
                      ? DoctorCropColors.accent
                      : DoctorCropColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.product,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: DoctorCropColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          tx.customer,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: DoctorCropColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text("•", style: TextStyle(color: DoctorCropColors.textMuted)),
                        const SizedBox(width: 6),
                        Text(
                          tx.method,
                          style: const TextStyle(
                            fontSize: 11,
                            color: DoctorCropColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${tx.amount} RWF",
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: DoctorCropColors.accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _ago(tx.date),
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: DoctorCropColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _sortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      "Sort Records",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DoctorCropColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(
                        Icons.close_rounded,
                        color: DoctorCropColors.textMuted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              ..._sortOpts
                  .map(
                    (opt) => ListTile(
                      title: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: DoctorCropColors.textPrimary,
                          fontWeight: _sort == opt
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      trailing: _sort == opt
                          ? const Icon(
                              Icons.check_rounded,
                              color: DoctorCropColors.primary,
                              size: 18,
                            )
                          : null,
                      onTap: () {
                        setState(() => _sort = opt);
                        Navigator.pop(ctx);
                      },
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return "${d.inMinutes}m ago";
    if (d.inHours < 24) return "${d.inHours}h ago";
    return "${d.inDays}d ago";
  }
}

class _TxRecord {
  final String customer, product, method;
  final int amount;
  final DateTime date;
  final bool isDebt;
  _TxRecord({
    required this.customer,
    required this.product,
    required this.amount,
    required this.date,
    required this.method,
    required this.isDebt,
  });
}
