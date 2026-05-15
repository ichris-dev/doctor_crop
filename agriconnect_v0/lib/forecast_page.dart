import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:http/http.dart' as http;

// ──────────────────────────────────────────────────────────────────────────────
//  WeatherForecastPage
// ──────────────────────────────────────────────────────────────────────────────
class WeatherForecastPage extends StatefulWidget {
  const WeatherForecastPage({super.key});

  @override
  State<WeatherForecastPage> createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  // ── Design tokens ────────────────────────────────────────────────────────
  static const Color _ink = Color(0xFF111111);
  static const Color _subText = Color(0xFF999999);
  static const Color _surface = Color(0xFFFAFAF8);
  static const Color _border = Color(0xFFEEEEEA);
  static const Color _green = Color(0xFF40B37A);
  static const Color _orange = Color(0xFFF97316);
  static const Color _dark = Color(0xFF1A1A1A);

  // Add these to your state variables
  Map<String, dynamic>? _liveWeather;
  bool _loadingWeather = true;

  // Weather code → icon + label
  Map<String, dynamic> _decodeWeatherCode(int code) {
    if (code == 0) return {"icon": Icons.wb_sunny_outlined, "label": "Clear"};
    if (code <= 2)
      return {"icon": Icons.wb_cloudy_outlined, "label": "Partly Cloudy"};
    if (code <= 3) return {"icon": Icons.cloud_outlined, "label": "Overcast"};
    if (code <= 49) return {"icon": Icons.foggy, "label": "Foggy"};
    if (code <= 59) return {"icon": Icons.grain_outlined, "label": "Drizzle"};
    if (code <= 69) return {"icon": Icons.grain_outlined, "label": "Rain"};
    if (code <= 79) return {"icon": Icons.ac_unit_outlined, "label": "Snow"};
    if (code <= 82)
      return {"icon": Icons.grain_outlined, "label": "Rain Showers"};
    if (code <= 99)
      return {"icon": Icons.thunderstorm_outlined, "label": "Thunderstorm"};
    return {"icon": Icons.cloud_outlined, "label": "Unknown"};
  }

  // Call this in initState
  Future<void> fetchLiveWeather({
    double lat = -1.9441,
    double lon = 30.0619,
  }) async {
    setState(() => _loadingWeather = true);
    try {
      final response = await http.get(
        Uri.parse("http://192.168.50.36:8000/weather?lat=$lat&lon=$lon"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _liveWeather = data;
            _loadingWeather = false;
          });
        }
      }
    } catch (e) {
      print("Weather fetch error: $e");
      setState(() => _loadingWeather = false);
    }
  }

  int _forecastTab = 0;
  final List<String> _tabs = ["Tomorrow", "Week", "Month", "Year"];

  // ── Forecast data ────────────────────────────────────────────────────────
  final Map<int, List<_ForecastItem>> _forecastData = {
    0: [
      _ForecastItem("6 AM", Icons.wb_sunny_outlined, "Sunny", 22, 0),
      _ForecastItem("9 AM", Icons.wb_sunny_outlined, "Clear", 24, 0),
      _ForecastItem("12 PM", Icons.cloud_outlined, "Part. Cloudy", 27, 10),
      _ForecastItem("3 PM", Icons.thunderstorm_outlined, "Thunder", 25, 70),
      _ForecastItem("6 PM", Icons.grain_outlined, "Light Rain", 23, 55),
      _ForecastItem("9 PM", Icons.cloud_outlined, "Cloudy", 21, 20),
    ],
    1: [
      _ForecastItem("Mon", Icons.wb_sunny_outlined, "Sunny", 26, 5),
      _ForecastItem("Tue", Icons.cloud_outlined, "Cloudy", 24, 30),
      _ForecastItem("Wed", Icons.grain_outlined, "Rain", 22, 75),
      _ForecastItem("Thu", Icons.thunderstorm_outlined, "Storm", 21, 85),
      _ForecastItem("Fri", Icons.grain_outlined, "Drizzle", 23, 60),
      _ForecastItem("Sat", Icons.wb_sunny_outlined, "Clear", 25, 10),
      _ForecastItem("Sun", Icons.wb_cloudy_outlined, "Overcast", 24, 25),
    ],
    2: [
      _ForecastItem("Wk 1", Icons.grain_outlined, "Rainy", 23, 70),
      _ForecastItem("Wk 2", Icons.wb_sunny_outlined, "Sunny", 26, 15),
      _ForecastItem("Wk 3", Icons.thunderstorm_outlined, "Storms", 22, 80),
      _ForecastItem("Wk 4", Icons.grain_outlined, "Wet", 21, 65),
    ],
    3: [
      _ForecastItem("Jan", Icons.grain_outlined, "Rainy", 22, 80),
      _ForecastItem("Feb", Icons.grain_outlined, "Wet", 23, 70),
      _ForecastItem("Mar", Icons.wb_sunny_outlined, "Sunny", 25, 20),
      _ForecastItem("Apr", Icons.grain_outlined, "Heavy Rain", 21, 90),
      _ForecastItem("May", Icons.cloud_outlined, "Cloudy", 22, 45),
      _ForecastItem("Jun", Icons.wb_sunny_outlined, "Dry", 24, 10),
      _ForecastItem("Jul", Icons.wb_sunny_outlined, "Dry", 25, 5),
      _ForecastItem("Aug", Icons.wb_sunny_outlined, "Clear", 25, 8),
      _ForecastItem("Sep", Icons.cloud_outlined, "Mild", 23, 30),
      _ForecastItem("Oct", Icons.grain_outlined, "Rainy", 22, 75),
      _ForecastItem("Nov", Icons.thunderstorm_outlined, "Storms", 21, 85),
      _ForecastItem("Dec", Icons.grain_outlined, "Wet", 22, 65),
    ],
  };

  final Map<int, List<double>> _precipData = {
    0: [0, 0, 10, 70, 55, 20],
    1: [5, 30, 75, 85, 60, 10, 25],
    2: [70, 15, 80, 65],
    3: [80, 70, 20, 90, 45, 10, 5, 8, 30, 75, 85, 65],
  };

  // ── Map regions – orange for sunny, green for rain, grey for cloud ───────
  final List<_MapRegion> _regions = [
    _MapRegion(
      "Kigali",
      0.50,
      0.46,
      Icons.wb_sunny_outlined,
      27,
      Color(0xFFF97316),
    ),
    _MapRegion(
      "Musanze",
      0.28,
      0.22,
      Icons.grain_outlined,
      19,
      Color(0xFF40B37A),
    ),
    _MapRegion(
      "Rubavu",
      0.13,
      0.33,
      Icons.thunderstorm_outlined,
      18,
      Color(0xFF777777),
    ),
    _MapRegion("Huye", 0.44, 0.75, Icons.cloud_outlined, 22, Color(0xFF777777)),
    _MapRegion(
      "Nyagatare",
      0.74,
      0.20,
      Icons.wb_sunny_outlined,
      29,
      Color(0xFFF97316),
    ),
    _MapRegion(
      "Rusizi",
      0.17,
      0.70,
      Icons.grain_outlined,
      20,
      Color(0xFF40B37A),
    ),
    _MapRegion(
      "Rwamagana",
      0.68,
      0.42,
      Icons.wb_sunny_outlined,
      26,
      Color(0xFFF97316),
    ),
    _MapRegion(
      "Muhanga",
      0.38,
      0.54,
      Icons.cloud_outlined,
      23,
      Color(0xFF777777),
    ),
  ];

  // ── News (Unsplash agriculture images) ───────────────────────────────────
  final List<_NewsItem> _news = [
    _NewsItem(
      "Heavy Rains Expected in Northern Rwanda",
      "Meteorologists warn of above-average rainfall in Musanze and Rubavu districts next week. Farmers advised to protect crops and harvest early.",
      "2h ago",
      "Weather Alert",
      Color(0xFFF97316),
      "https://images.unsplash.com/photo-1534274988757-a28bf1a57c17?w=800",
    ),
    _NewsItem(
      "Rwanda Agricultural Season B Planting Guide 2025",
      "MINAGRI releases updated guidelines for Season B. Maize and potato farmers in highland areas should prepare soil before the rains begin.",
      "5h ago",
      "MINAGRI",
      Color(0xFF40B37A),
      "https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800",
    ),
    _NewsItem(
      "El Niño Effect on East African Harvests",
      "Climate scientists project a 15% reduction in sorghum and bean yields across East Africa due to irregular rainfall patterns.",
      "1d ago",
      "Climate",
      Color(0xFF777777),
      "https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?w=800",
    ),
    _NewsItem(
      "New Drought-Resistant Maize Varieties Released",
      "Rwanda Agriculture Board introduces three new maize varieties suited to drier Eastern Province with up to 30% higher yield.",
      "2d ago",
      "RAB Update",
      Color(0xFF40B37A),
      "https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=800",
    ),
    _NewsItem(
      "Coffee Harvest Forecast: Record Output Expected",
      "Favorable temperatures across volcanic highlands are expected to boost arabica coffee cherry yields by 18% vs last year.",
      "3d ago",
      "Export Crops",
      Color(0xFFF97316),
      "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800",
    ),
  ];
  @override
  void initState() {
    super.initState();
    fetchLiveWeather(lat: -1.4990, lon: 29.6340);
  }

  // ────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          _buildTodayCard(),
          _buildForecastTabs(),
          _buildForecastRow(),
          _buildRwandaMap(),
          _buildPrecipChart(),
          _buildNewsSection(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ── TODAY CARD  (dark, no blue) ───────────────────────────────────────────
  Widget _buildTodayCard() {
    // Use live data if available, fallback to static
    final temp = _liveWeather?["current"]?["temperature"]?.round() ?? 27;
    final humidity = _liveWeather?["current"]?["humidity"] ?? 68;
    final wind = _liveWeather?["current"]?["wind_speed"] ?? 14;
    final rainChance = _liveWeather?["current"]?["rain_chance"] ?? 20;
    final code = _liveWeather?["current"]?["weather_code"] ?? 1;
    final weather = _decodeWeatherCode(code);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: _loadingWeather
          ? const SizedBox(
              height: 140,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white54,
                  strokeWidth: 2,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white54,
                          size: 13,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Kigali, Rwanda",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      _todayDate(),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$temp°",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 66,
                        fontWeight: FontWeight.w200,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(weather["icon"], color: _orange, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                weather["label"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _statPill(
                      Icons.water_drop_outlined,
                      "Humidity",
                      "$humidity%",
                    ),
                    const SizedBox(width: 8),
                    _statPill(Icons.air_outlined, "Wind", "$wind km/h"),
                    const SizedBox(width: 8),
                    _statPill(Icons.umbrella_outlined, "Rain", "$rainChance%"),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _statPill(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.10), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white38, size: 13),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FORECAST TABS ─────────────────────────────────────────────────────────
  Widget _buildForecastTabs() {
    return Container(
      height: 36,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final sel = _forecastTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _forecastTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: EdgeInsets.only(right: i < _tabs.length - 1 ? 8 : 0),
                decoration: BoxDecoration(
                  color: sel ? _green : _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? _green : _border, width: 0.9),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    color: sel ? Colors.white : const Color(0xFF444444),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── FORECAST SCROLL ROW ───────────────────────────────────────────────────
  Widget _buildForecastRow() {
    final items = _forecastData[_forecastTab]!;
    return SizedBox(
      height: 128,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final it = items[i];
          final wet = it.precip > 50;
          return Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 0.9),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  it.label,
                  style: const TextStyle(
                    color: _subText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  it.icon,
                  color: wet ? const Color(0xFF777777) : _orange,
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  "${it.temp}°",
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.water_drop_outlined, color: _green, size: 9),
                    const SizedBox(width: 2),
                    Text(
                      "${it.precip}%",
                      style: const TextStyle(
                        color: _green,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
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

  // ── RWANDA MAP ────────────────────────────────────────────────────────────
  Widget _buildRwandaMap() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Weather Map · Rwanda",
                  style: TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Today",
                    style: TextStyle(
                      color: _green,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Map with pinned weather labels
          LayoutBuilder(
            builder: (context, constraints) {
              final mapW = constraints.maxWidth;
              const mapH = 270.0;
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: SizedBox(
                  height: mapH,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _RwandaMapPainter()),
                      ),
                      ..._regions.map((r) {
                        // Pin box is ~62 wide × 60 tall total
                        final px = (r.x * mapW - 31).clamp(0, mapW - 62);
                        final py = (r.y * mapH - 54).clamp(0, mapH - 62);
                        return Positioned(
                          left: px.toDouble(),
                          top: py.toDouble(),
                          child: _mapPinWidget(r),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _mapPinWidget(_MapRegion r) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: r.color.withOpacity(0.45), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(r.icon, color: r.color, size: 13),
              const SizedBox(height: 2),
              Text(
                "${r.temp}°",
                style: TextStyle(
                  color: r.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                r.name,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(width: 1.5, height: 7, color: r.color.withOpacity(0.55)),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
        ),
      ],
    );
  }

  // ── PRECIPITATION LINE+AREA CHART ─────────────────────────────────────────
  Widget _buildPrecipChart() {
    final data = _precipData[_forecastTab]!;
    final labels = _forecastData[_forecastTab]!.map((e) => e.label).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Precipitation Performance",
                style: TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.water_drop_outlined, color: _green, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      "% chance",
                      style: TextStyle(
                        color: _green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart row: y-labels + line painter
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: ["100", "75", "50", "25", "0"].map((v) {
                    return Text(
                      v,
                      style: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: CustomPaint(
                    painter: _PrecipLinePainter(
                      data: data,
                      lineColor: _green,
                      fillColorTop: _green.withOpacity(0.20),
                      fillColorBottom: _green.withOpacity(0.01),
                      gridColor: _border,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // X-axis labels
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 8),
            child: Row(
              children: List.generate(
                labels.length,
                (i) => Expanded(
                  child: Center(
                    child: Text(
                      labels[i],
                      style: const TextStyle(
                        color: _subText,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── NEWS SECTION ──────────────────────────────────────────────────────────
  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Agriculture & Weather News",
                style: TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                "See all",
                style: TextStyle(
                  color: _green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ..._news.map((n) => _newsCard(n)),
      ],
    );
  }

  Widget _newsCard(_NewsItem n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _dark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(
            n.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF222222)),
          ),

          // Gradient: transparent → near-black
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xBB000000),
                  Color(0xF0000000),
                ],
                stops: [0.0, 0.50, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Text content pinned bottom
          Positioned(
            left: 24,
            right: 24,
            bottom: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: n.accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        n.source,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      n.time,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  n.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  n.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const d = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return "${d[now.weekday - 1]}, ${m[now.month - 1]} ${now.day}";
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Rwanda Map CustomPainter
// ──────────────────────────────────────────────────────────────────────────────
class _RwandaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background – light warm grey to contrast the green fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFE4EDE5),
    );

    // Rwanda outline polygon (approximate, normalised coords)
    final pts = <Offset>[
      Offset(0.20 * w, 0.06 * h),
      Offset(0.32 * w, 0.03 * h),
      Offset(0.48 * w, 0.02 * h),
      Offset(0.62 * w, 0.04 * h),
      Offset(0.76 * w, 0.08 * h),
      Offset(0.86 * w, 0.15 * h),
      Offset(0.94 * w, 0.24 * h),
      Offset(0.97 * w, 0.36 * h),
      Offset(0.96 * w, 0.48 * h),
      Offset(0.92 * w, 0.58 * h),
      Offset(0.90 * w, 0.68 * h),
      Offset(0.84 * w, 0.79 * h),
      Offset(0.75 * w, 0.88 * h),
      Offset(0.63 * w, 0.95 * h),
      Offset(0.49 * w, 0.97 * h),
      Offset(0.36 * w, 0.95 * h),
      Offset(0.23 * w, 0.90 * h),
      Offset(0.13 * w, 0.82 * h),
      Offset(0.06 * w, 0.70 * h),
      Offset(0.04 * w, 0.57 * h),
      Offset(0.04 * w, 0.44 * h),
      Offset(0.06 * w, 0.32 * h),
      Offset(0.11 * w, 0.20 * h),
      Offset(0.15 * w, 0.12 * h),
      Offset(0.20 * w, 0.06 * h),
    ];

    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length - 1; i++) {
      final mid = Offset(
        (pts[i].dx + pts[i + 1].dx) / 2,
        (pts[i].dy + pts[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }
    path.close();

    // Land fill – green gradient
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, 0), Offset(w, h), [
          const Color(0xFFBEDEC2),
          const Color(0xFF9ECBA4),
        ])
        ..style = PaintingStyle.fill,
    );

    // Lake Kivu (west edge) – grey, no blue
    final lakePath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(0.065 * w, 0.43 * h),
          width: 0.050 * w,
          height: 0.22 * h,
        ),
      );
    canvas.drawPath(
      lakePath,
      Paint()
        ..color = const Color(0xFFADB5BB).withOpacity(0.70)
        ..style = PaintingStyle.fill,
    );

    // Province dividers (faint dashed feel via two offset lines)
    final divP = Paint()
      ..color = const Color(0xFF7CB87F).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;
    canvas.drawLine(
      Offset(0.50 * w, 0.05 * h),
      Offset(0.50 * w, 0.95 * h),
      divP,
    );
    canvas.drawLine(
      Offset(0.06 * w, 0.46 * h),
      Offset(0.94 * w, 0.46 * h),
      divP,
    );
    // Kigali zone diagonal
    canvas.drawLine(
      Offset(0.38 * w, 0.34 * h),
      Offset(0.62 * w, 0.58 * h),
      divP,
    );

    // Outline stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF3A8C42).withOpacity(0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ──────────────────────────────────────────────────────────────────────────────
//  Precipitation Line + Shaded Area Painter
// ──────────────────────────────────────────────────────────────────────────────
class _PrecipLinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor, fillColorTop, fillColorBottom, gridColor;

  const _PrecipLinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColorTop,
    required this.fillColorBottom,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final w = size.width;
    final h = size.height;

    // Horizontal grid lines at 0 / 25 / 50 / 75 / 100 %
    final gridP = Paint()
      ..color = gridColor
      ..strokeWidth = 0.6;
    for (final frac in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final y = h - frac * h;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridP);
    }

    // Build smooth cubic path through data points
    final count = data.length;
    final pts = <Offset>[
      for (int i = 0; i < count; i++)
        Offset(i / (count - 1) * w, h - data[i] / 100 * h),
    ];

    final linePath = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      linePath.cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        pts[i + 1].dx,
        pts[i + 1].dy,
      );
    }

    // Fill area below line
    final fillPath = Path()..addPath(linePath, Offset.zero);
    fillPath
      ..lineTo(pts.last.dx, h)
      ..lineTo(pts.first.dx, h)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, 0), Offset(0, h), [
          fillColorTop,
          fillColorBottom,
        ])
        ..style = PaintingStyle.fill,
    );

    // Line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots at each point
    for (final pt in pts) {
      canvas.drawCircle(pt, 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(pt, 3.0, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(_PrecipLinePainter o) => o.data != data;
}

// ──────────────────────────────────────────────────────────────────────────────
//  Data models
// ──────────────────────────────────────────────────────────────────────────────
class _ForecastItem {
  final String label, condition;
  final IconData icon;
  final int temp, precip;
  const _ForecastItem(
    this.label,
    this.icon,
    this.condition,
    this.temp,
    this.precip,
  );
}

class _MapRegion {
  final String name;
  final double x, y;
  final IconData icon;
  final int temp;
  final Color color;
  const _MapRegion(this.name, this.x, this.y, this.icon, this.temp, this.color);
}

class _NewsItem {
  final String title, body, time, source, imageUrl;
  final Color accentColor;
  const _NewsItem(
    this.title,
    this.body,
    this.time,
    this.source,
    this.accentColor,
    this.imageUrl,
  );
}
