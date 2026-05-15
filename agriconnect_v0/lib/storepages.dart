import 'dart:math';
import 'package:flutter/material.dart';
import 'package:agriconnect_v0/notifier.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
const Color _ink = Color(0xFF111111);
const Color _sub = Color(0xFF999999);
const Color _surface = Color(0xFFFAFAF8);
const Color _border = Color(0xFFEEEEEA);
const Color _green = Color(0xFF40B37A);
const Color _orange = Color(0xFFF97316);

// ─────────────────────────────────────────────────────────────
//  SHARED: back button with background
// ─────────────────────────────────────────────────────────────
Widget _backBtn(BuildContext context) {
  return GestureDetector(
    onTap: () => Navigator.pop(context),
    child: SizedBox(
      width: 36,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E0), width: 0.6),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 5),
            Icon(Icons.arrow_back_ios, color: Colors.orange, size: 18),
          ],
        ),
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
    leadingWidth: 60,
    leading: Center(child: _backBtn(context)),
    title: Text(
      title,
      style: const TextStyle(
        color: _ink,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 0.8, color: _border),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  SHARED BottomNav  (WidgetTree style)
// ─────────────────────────────────────────────────────────────
Widget _sharedBottomNav({
  required int currentIndex,
  required ValueChanged<int> onTap,
  required List<BottomNavigationBarItem> items,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black54,
      boxShadow: [
        BoxShadow(
          color: _orange.withOpacity(0.09),
          blurRadius: 10,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black54,
      selectedItemColor: Colors.greenAccent.shade200,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      elevation: 0,
      items: items,
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  SHARED: No-store locked view
// ─────────────────────────────────────────────────────────────
Widget _noStoreView(BuildContext context, String pageName) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 34,
              color: _orange,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "$pageName Unavailable",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You don't have a store linked to your account.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  SHARED: marketplace-style product card
// ─────────────────────────────────────────────────────────────
Widget _marketCard(
  BuildContext context,
  StoreProduct p, {
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 180,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(5),
      ),
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
                color: const Color(0xFFF0F0EC),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              height: 130,
              color: const Color(0xFFF0F0EC),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Color(0xFFCCCCCC),
              ),
            ),
          ),
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
                    p.location,
                    style: const TextStyle(
                      color: _green,
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
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _sub,
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
    height: 33,
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: sel ? _green : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? _green : const Color(0xFFE2E2E0)),
            ),
            alignment: Alignment.center,
            child: Text(
              cat,
              style: TextStyle(
                color: sel ? Colors.white : const Color(0xFF444444),
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

// ═══════════════════════════════════════════════════════════════
//  STORE INFO PAGE
// ═══════════════════════════════════════════════════════════════
class StoreInfoPage extends StatelessWidget {
  const StoreInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(
        context,
        "Store Info",
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _ink),
            onPressed: () {},
          ),
        ],
      ),
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
        // ── Header banner — soft warm tint ────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // warm off-white with a green left accent stripe feel
            gradient: const LinearGradient(
              colors: [Color(0xFFF0FAF5), Color(0xFFFFF8F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _green.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              // Store icon with green ring
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _green.withOpacity(0.35), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: _green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
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
                              color: _ink,
                              fontSize: 15,
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
                            color: _green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified,
                                color: _green,
                                size: 11,
                              ),
                              const SizedBox(width: 3),
                              const Text(
                                "Verified",
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Your store is active and visible to buyers.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _pill(
                          Icons.location_on_outlined,
                          store.storeLocation,
                          _orange,
                        ),
                        const SizedBox(width: 6),
                        _pill(Icons.phone_outlined, store.storePhone, _green),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Business Chart ────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PERFORMANCE",
                          style: TextStyle(
                            color: _sub,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "5-month history + 3-month forecast",
                          style: TextStyle(
                            color: _ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _legendDot(_green, "Actual"),
                      const SizedBox(width: 10),
                      _legendDot(_orange, "Forecast"),
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

        // ── Info list ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _row(Icons.store_outlined, "Store Name", store.storeName, _green),
              _div(),
              _row(Icons.phone_outlined, "Phone", store.storePhone, _green),
              _div(),
              _row(
                Icons.location_on_outlined,
                "Location",
                store.storeLocation,
                _orange,
              ),
              _div(),
              _row(
                Icons.inventory_outlined,
                "Total Products",
                "${store.products.length} items",
                _green,
              ),
              _div(),
              _row(
                Icons.payments_outlined,
                "Total Value",
                "${_fmt(total.toDouble())} Rwf",
                _orange,
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
        borderRadius: BorderRadius.circular(20),
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
            style: const TextStyle(color: Color(0xFF888888), fontSize: 12.5),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _div() => const Divider(height: 1, color: Color(0xFFF5F5F3));

  String _fmt(double v) {
    if (v >= 1_000_000) return "${(v / 1_000_000).toStringAsFixed(1)}M";
    if (v >= 1_000) return "${(v / 1_000).toStringAsFixed(0)}K";
    return v.toStringAsFixed(0);
  }
}

// ─────────────────────────────────────────────────────────────
//  PERFORMANCE CHART
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
    const lStyle = TextStyle(color: _sub, fontSize: 8);

    // Grid
    final gp = Paint()
      ..color = _border
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

    // X labels
    final xS = w / (vals.length - 1);
    for (int i = 0; i < vals.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: lStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pL + i * xS - tp.width / 2, pT + h + 6));
    }

    // Points
    final pts = [
      for (int i = 0; i < vals.length; i++)
        Offset(pL + i * xS, pT + h - h * vals[i] / maxV),
    ];

    // Solid line
    final sp = Paint()
      ..color = _green
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
          colors: [_green.withOpacity(0.18), _green.withOpacity(0.01)],
        ).createShader(Rect.fromLTWH(0, pT, size.width, h))
        ..style = PaintingStyle.fill,
    );

    // Dotted forecast
    final dp = Paint()
      ..color = _orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int i = solid - 1; i < pts.length - 1; i++) {
      _dash(canvas, pts[i], pts[i + 1], dp);
    }

    // Dots solid
    for (int i = 0; i < solid; i++) {
      canvas.drawCircle(pts[i], 3.5, Paint()..color = _green);
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
      canvas.drawCircle(pts[i], 3.5, Paint()..color = _orange);
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
    "Your Products",
    "Popular Items",
    "Special Offers",
    "More Products",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(
        context,
        "Store Home",
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _ink),
            onPressed: () {},
          ),
        ],
      ),
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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E5E0),
                        width: 0.8,
                      ),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: const TextStyle(fontSize: 13.5, color: _ink),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF999999),
                          size: 20,
                        ),
                        hintText: "Search products...",
                        hintStyle: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
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
              SliverToBoxAdapter(child: Container(height: 0.8, color: _border)),
              if (filtered.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(color: _sub, fontSize: 13),
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
            onPressed: () {},
            backgroundColor: _green,
            icon: const Icon(Icons.add, color: Colors.white),
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
            color: _ink,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          "See all",
          style: const TextStyle(
            color: _green,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _row(BuildContext context, List<StoreProduct> items) => SizedBox(
    height: 280,
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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(
        context,
        product.productName,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _ink),
            onPressed: () {},
          ),
        ],
      ),
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
                    Container(height: 220, color: const Color(0xFFF0F0EC)),
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
                top: 16,
                right: 16,
                child: _badge("${product.priceRwf} Rwf", _orange),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  product.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                        "DESCRIPTION",
                        style: TextStyle(
                          color: _sub,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF333333),
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
                        "Price",
                        "${product.priceRwf} Rwf",
                        _orange,
                      ),
                      const Divider(height: 18),
                      _dr(
                        Icons.location_on_outlined,
                        "Location",
                        product.location,
                        _green,
                      ),
                      const Divider(height: 18),
                      _dr(
                        Icons.calendar_today_outlined,
                        "Added",
                        "${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}",
                        _sub,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF2563EB).withOpacity(0.15),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Genome AI can explain this product's usage, risks, storage, and market value.",
                          style: TextStyle(fontSize: 12.5, height: 1.4),
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
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("Edit Product"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_checkout, size: 18),
              label: const Text("Record Sale"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(130, 48),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _dr(IconData icon, String label, String value, Color c) => Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: c.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: c),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12.5),
      ),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          color: _ink,
          fontSize: 13,
          fontWeight: FontWeight.w600,
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
//  STORE RECORDING PAGE  — modern green/orange
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
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: _buildAppBar(
        context,
        "Store Recording",
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _ink),
            onPressed: () => _menu(context),
          ),
        ],
      ),
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

  void _menu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tile(context, Icons.download_outlined, "Export Records", _green),
            _tile(context, Icons.filter_list, "Filter by Date", _orange),
            _tile(context, Icons.print_outlined, "Print Report", _ink),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, String label, Color color) =>
      ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: _ink,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () => Navigator.pop(ctx),
      );
}

// ─────────────────────────────────────────────────────────────
//  Sale Form  — modern with green/orange
// ─────────────────────────────────────────────────────────────
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
    final accent = isDebt ? _orange : _green;
    final accentL = isDebt
        ? _orange.withOpacity(0.08)
        : _green.withOpacity(0.08);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Top accent banner ────────────────────────────────
        _sec("Select Product"),
        _drop(),
        const SizedBox(height: 10),
        _field(
          _qty,
          "Quantity",
          Icons.numbers_rounded,
          accent,
          keyboard: TextInputType.number,
        ),

        const SizedBox(height: 20),
        _sec("Customer Info"),
        _field(_cust, "Customer name", Icons.person_outline, accent),
        const SizedBox(height: 10),
        _field(
          _phone,
          "Phone number",
          Icons.phone_outlined,
          accent,
          keyboard: TextInputType.phone,
        ),
        if (isDebt) ...[
          const SizedBox(height: 10),
          _field(
            TextEditingController(),
            "Due date",
            Icons.calendar_today_outlined,
            accent,
          ),
        ],

        const SizedBox(height: 20),
        _sec("Payment Method"),
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
                    color: sel ? accent : const Color(0xFFE5E5E0),
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: accent.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  m,
                  style: TextStyle(
                    color: sel ? Colors.white : const Color(0xFF555555),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        _sec("Notes (optional)"),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
          ),
          child: TextField(
            controller: _note,
            maxLines: 3,
            style: const TextStyle(fontSize: 13.5, color: _ink),
            decoration: const InputDecoration(
              hintText: "Add notes...",
              hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),

        const SizedBox(height: 20),
        // ── Total preview ─────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TOTAL AMOUNT",
                    style: TextStyle(
                      color: accent.withOpacity(0.65),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _qty,
                    builder: (_, __, ___) => Text(
                      _total > 0 ? "$_total Rwf" : "— Rwf",
                      style: TextStyle(
                        color: accent,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: accent.withOpacity(0.15), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${_sel!.priceRwf} × ${_qty.text.isEmpty ? 0 : _qty.text} units",
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _sel!.productName,
                        style: const TextStyle(color: _sub, fontSize: 10),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        GestureDetector(
          onTap: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  await Future.delayed(const Duration(milliseconds: 900));
                  setState(() => _saving = false);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isDebt ? "Debt sale recorded!" : "Sale recorded!",
                      ),
                      backgroundColor: accent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withOpacity(0.80)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDebt
                            ? Icons.hourglass_bottom_rounded
                            : Icons.check_circle_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDebt ? "Record Debt Sale" : "Record Direct Sale",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _drop() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<StoreProduct>(
        value: _sel,
        hint: const Text(
          "Choose a product",
          style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
        ),
        isExpanded: true,
        items: widget.products
            .map(
              (p) => DropdownMenuItem(
                value: p,
                child: Text(
                  "${p.productName}  •  ${p.priceRwf} Rwf",
                  style: const TextStyle(fontSize: 13, color: _ink),
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
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFFAAAAAA),
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
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
      border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
    ),
    child: TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 13.5, color: _ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: accent),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(
        context,
        "Transactions",
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _ink),
            onPressed: () => _menu(context),
          ),
        ],
      ),
      body: ValueListenableBuilder<StoreSession?>(
        valueListenable: storeSessionNotifier,
        builder: (context, store, _) {
          if (store == null) return _noStoreView(context, "Transactions");
          return Column(
            children: [
              // ── Search + Sort bar ─────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE5E5E0),
                            width: 0.8,
                          ),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          style: const TextStyle(fontSize: 13, color: _ink),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: _sub,
                              size: 18,
                            ),
                            hintText: "Search...",
                            hintStyle: TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 12.5,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort button
                    GestureDetector(
                      onTap: () => _sortSheet(context),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE5E5E0),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.sort_rounded,
                          color: _ink,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 0.8, color: _border),
              // ── List ─────────────────────────────────────────
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
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: "Customers (${_filteredCustomers().length})",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
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
        child: Text("No customers found", style: TextStyle(color: _sub)),
      );
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final c = list[i];
        final all = _sales.where((s) => s.customer == c.customer).toList();
        final total = all.fold<int>(0, (s, tx) => s + tx.amount);
        final hasDebt = all.any((s) => s.isDebt);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _border, width: 0.8)),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    c.customer[0],
                    style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${all.length} purchase${all.length == 1 ? '' : 's'}",
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$total Rwf",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _orange,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: hasDebt
                          ? _orange.withOpacity(0.10)
                          : _green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hasDebt ? "Has debt" : "Cleared",
                      style: TextStyle(
                        fontSize: 10,
                        color: hasDebt ? _orange : _green,
                        fontWeight: FontWeight.w600,
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
        child: Text("No sales found", style: TextStyle(color: _sub)),
      );
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final tx = list[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _border, width: 0.8)),
          ),
          child: Row(
            children: [
              // Type indicator
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tx.isDebt
                      ? _orange.withOpacity(0.10)
                      : _green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  tx.isDebt
                      ? Icons.hourglass_bottom_rounded
                      : Icons.check_circle_outline,
                  color: tx.isDebt ? _orange : _green,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 11,
                          color: Color(0xFFAAAAAA),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          tx.customer,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCCCCCC),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tx.method,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFBBBBBB),
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
                    "${tx.amount} Rwf",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _orange,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _ago(tx.date),
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFFBBBBBB),
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
                      "Sort by",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _sub,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              ..._sortOpts
                  .map(
                    (opt) => ListTile(
                      leading: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _sort == opt
                              ? _green.withOpacity(0.10)
                              : const Color(0xFFF5F5F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          opt == "Newest"
                              ? Icons.arrow_downward_rounded
                              : opt == "Oldest"
                              ? Icons.arrow_upward_rounded
                              : opt == "Highest"
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 17,
                          color: _sort == opt ? _green : _sub,
                        ),
                      ),
                      title: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: _ink,
                          fontWeight: _sort == opt
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      trailing: _sort == opt
                          ? const Icon(
                              Icons.check_rounded,
                              color: _green,
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

  void _menu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuTile(
              context,
              Icons.download_outlined,
              "Export Transactions",
              _green,
            ),
            _menuTile(context, Icons.print_outlined, "Print Report", _orange),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
  ) => ListTile(
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
    title: Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        color: _ink,
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: () => Navigator.pop(ctx),
  );

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
