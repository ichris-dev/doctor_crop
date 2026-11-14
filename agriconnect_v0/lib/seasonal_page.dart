import 'package:agriconnect_v0/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SeasonalPage extends StatefulWidget {
  const SeasonalPage({super.key});

  @override
  State<SeasonalPage> createState() => _SeasonalPageState();
}

class _SeasonalPageState extends State<SeasonalPage> {
  final List<SeasonModel> seasons = [
    SeasonModel(
      name: "Irish Potato Season",
      location: "Musanze, Rwanda",
      landSize: "2.5 hectares",
      crops: ["Irish Potato", "Maize"],
      cropType: "Food crop",
      plantedQuantity: "480 kg seeds",
      period: "Jan 2025 - Jun 2025",
      status: "Harvest Completed",
      predictedYield: 8200,
      actualYield: 7600,
      revenue: 3420000,
      buyers: 38,
      suppliedPlaces: [
        SupplierPlace(name: "Kigali Market", phone: "+250 788 120 345"),
        SupplierPlace(name: "Musanze Agro Store", phone: "+250 789 420 111"),
        SupplierPlace(name: "Nyabugogo Dealers", phone: "+250 782 909 800"),
      ],
      imageUrl:
          "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=1200",
      description:
          "This season focused on Irish potatoes and maize production. The farm performed well, although rainfall dropped during flowering. Market demand increased near harvest time, helping sales remain strong.",
      climateSummary:
          "Rain was strong during early growth, reduced during flowering, then stabilized during harvest. The crop recovered well because soil moisture was still enough during the final stage.",
      genomeInsight:
          "Genome AI noticed rising potato demand in Kigali and Musanze markets. Next season should start earlier and divide harvesting into phases to reduce market risk.",
      productionImages: [
        "https://images.unsplash.com/photo-1500595046743-cd271d694d30?w=900",
        "https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900",
        "https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?w=900",
        "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=900",
      ],
    ),
    SeasonModel(
      name: "Tomato Green Season",
      location: "Bugesera, Rwanda",
      landSize: "1.8 hectares",
      crops: ["Tomatoes", "Onions"],
      cropType: "Cash crop",
      plantedQuantity: "12,000 seedlings",
      period: "Aug 2024 - Dec 2024",
      status: "Harvest Completed",
      predictedYield: 5400,
      actualYield: 6100,
      revenue: 4280000,
      buyers: 51,
      suppliedPlaces: [
        SupplierPlace(name: "Kimironko Market", phone: "+250 788 440 290"),
        SupplierPlace(name: "Hotel Buyers", phone: "+250 781 223 940"),
        SupplierPlace(name: "Local Retailers", phone: "+250 790 333 128"),
      ],
      imageUrl:
          "https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=1200",
      description:
          "This season was mainly focused on tomato production for commercial sale. The outcome exceeded prediction because of better disease control, good irrigation, and stronger market demand.",
      climateSummary:
          "The season had low natural rainfall, but irrigation helped stabilize plant growth. The dry period also reduced some fungal disease pressure.",
      genomeInsight:
          "Genome AI recommended selling in weekly batches because tomato prices changed quickly across Kigali markets.",
      productionImages: [
        "https://images.unsplash.com/photo-1561136594-7f68413baa99?w=900",
        "https://images.unsplash.com/photo-1607305387299-a3d9611cd469?w=900",
        "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=900",
        "https://images.unsplash.com/photo-1524593166156-312f362cada0?w=900",
      ],
    ),
  ];

  void _openCreateSeason() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateSeasonPage(
          onCreate: (season) {
            setState(() => seasons.insert(0, season));
          },
        ),
      ),
    );
  }

  void _openDetails(SeasonModel season) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SeasonDetailsPage(season: season)),
    );
  }

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredSeasons = seasons.where((season) {
      final query = searchQuery.toLowerCase();

      return season.name.toLowerCase().contains(query) ||
          season.location.toLowerCase().contains(query) ||
          season.period.toLowerCase().contains(query) ||
          season.crops.join(" ").toLowerCase().contains(query);
    }).toList();

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
        title: const Text(
          "Farm Seasonal History",
          style: TextStyle(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSeason,
        backgroundColor: DoctorCropColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "New Season",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSeasonSearchHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSeasons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return SeasonHistoryCard(
                    season: filteredSeasons[index],
                    onTap: () => _openDetails(filteredSeasons[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: DoctorCropColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DoctorCropColors.border, width: 0.8),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: const TextStyle(
                  color: DoctorCropColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.search_rounded,
                    color: DoctorCropColors.textMuted,
                    size: 18,
                  ),
                  hintText: "Search seasons, crops, locations...",
                  hintStyle: TextStyle(
                    color: DoctorCropColors.textMuted,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                seasons.sort((a, b) => b.actualYield.compareTo(a.actualYield));
              });
            },
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: DoctorCropColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DoctorCropColors.primary.withOpacity(0.2),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.sort_rounded,
                color: DoctorCropColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SeasonHistoryCard extends StatelessWidget {
  final SeasonModel season;
  final VoidCallback onTap;

  const SeasonHistoryCard({
    super.key,
    required this.season,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 140,
        decoration: DoctorCropTheme.cardDecoration(hasShadow: true),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 130,
              height: double.infinity,
              child: Image.network(
                season.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: DoctorCropColors.surfaceMuted),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DoctorCropColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      season.period,
                      style: const TextStyle(
                        color: DoctorCropColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: DoctorCropColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            season.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: DoctorCropColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _SmallStatus(
                          text: season.status,
                          color: DoctorCropColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${season.actualYield.toInt()} kg yield",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: DoctorCropColors.accent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: DoctorCropColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeasonDetailsPage extends StatelessWidget {
  final SeasonModel season;

  const SeasonDetailsPage({super.key, required this.season});

  @override
  Widget build(BuildContext context) {
    final performance = ((season.actualYield / season.predictedYield) * 100)
        .toStringAsFixed(1);

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
          season.name,
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
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _TopImage(season: season),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle("Season Summary"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: DoctorCropTheme.cardDecoration(),
                  child: Text(
                    season.description,
                    style: const TextStyle(
                      color: DoctorCropColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _SectionTitle("Yield Performance & Products"),
                const SizedBox(height: 8),
                Container(
                  decoration: DoctorCropTheme.cardDecoration(),
                  clipBehavior: Clip.antiAlias,
                  child: _YieldProductTable(season: season, performance: performance),
                ),

                const SizedBox(height: 20),

                _SectionTitle("Distribution & Market Destinations"),
                const SizedBox(height: 8),
                Container(
                  decoration: DoctorCropTheme.cardDecoration(),
                  clipBehavior: Clip.antiAlias,
                  child: _SuppliedPlacesTable(places: season.suppliedPlaces),
                ),

                const SizedBox(height: 20),

                _SectionTitle("Farm Production Gallery"),
                const SizedBox(height: 8),
                _ProductionImageGrid(images: season.productionImages),

                const SizedBox(height: 24),

                _SectionTitle("Predicted vs. Actual Harvest Output"),
                const SizedBox(height: 4),
                const Text(
                  "Monthly growth progression tracking against expected yields.",
                  style: TextStyle(
                    color: DoctorCropColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: DoctorCropTheme.cardDecoration(),
                  child: SizedBox(
                    height: 260,
                    child: _YieldLineChart(season: season),
                  ),
                ),

                const SizedBox(height: 24),

                _SectionTitle("Rainfall & Sales Score Comparison"),
                const SizedBox(height: 4),
                const Text(
                  "Correlation between monthly precipitation and wholesale revenue score.",
                  style: TextStyle(
                    color: DoctorCropColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: DoctorCropTheme.cardDecoration(),
                  child: SizedBox(
                    height: 260,
                    child: _RainSalesBarChart(),
                  ),
                ),

                const SizedBox(height: 20),

                _InfoCard(
                  title: "Genome AI Market Exploration",
                  icon: Icons.auto_awesome_rounded,
                  color: DoctorCropColors.primary,
                  text: season.genomeInsight,
                ),

                const SizedBox(height: 12),

                _InfoCard(
                  title: "Climate Behavior Analysis",
                  icon: Icons.cloud_rounded,
                  color: DoctorCropColors.info,
                  text: season.climateSummary,
                ),

                const SizedBox(height: 16),

                _SeasonVideoCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopImage extends StatelessWidget {
  final SeasonModel season;

  const _TopImage({required this.season});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(season.imageUrl, fit: BoxFit.cover),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.transparent,
                  Colors.black.withOpacity(0.70),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            left: 14,
            top: 14,
            child: _ImageBadge(
              text: season.status,
              icon: Icons.check_circle_outline,
              color: DoctorCropColors.primary,
            ),
          ),

          Positioned(
            right: 14,
            top: 14,
            child: _ImageBadge(
              text: season.cropType,
              icon: Icons.eco_outlined,
              color: DoctorCropColors.accent,
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${season.period} • ${season.location}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _ImageBadge({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _YieldProductTable extends StatelessWidget {
  final SeasonModel season;
  final String performance;

  const _YieldProductTable({required this.season, required this.performance});

  @override
  Widget build(BuildContext context) {
    final rows = <TableRow>[
      _tableRow([
        "Product",
        "Type",
        "Quantity",
        "Buyers",
        "Perf.",
      ], isHeader: true),
      ...season.crops.map(
        (crop) => _tableRow([
          crop,
          season.cropType,
          crop == season.crops.first
              ? "${season.actualYield.toInt()} kg"
              : "Mixed",
          "${season.buyers}",
          "$performance%",
        ]),
      ),
      _tableRow(["Revenue", "Sales", "${season.revenue} RWF", "-", "-"]),
    ];

    return Table(
      border: TableBorder.all(color: DoctorCropColors.border, width: 0.8),
      columnWidths: const {
        0: FlexColumnWidth(1.25),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.15),
        3: FlexColumnWidth(.8),
        4: FlexColumnWidth(.8),
      },
      children: rows,
    );
  }
}

class _SuppliedPlacesTable extends StatelessWidget {
  final List<SupplierPlace> places;

  const _SuppliedPlacesTable({required this.places});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: DoctorCropColors.border, width: 0.8),
      columnWidths: const {0: FlexColumnWidth(1.4), 1: FlexColumnWidth(1.1)},
      children: [
        _tableRow(["Place", "Phone Contact"], isHeader: true),
        ...places.map((place) => _tableRow([place.name, place.phone])),
      ],
    );
  }
}

TableRow _tableRow(List<String> values, {bool isHeader = false}) {
  return TableRow(
    decoration: BoxDecoration(
      color: isHeader ? DoctorCropColors.surfaceMuted : Colors.white,
    ),
    children: values.map((value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          value,
          style: TextStyle(
            color: DoctorCropColors.textPrimary,
            fontSize: 12,
            fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      );
    }).toList(),
  );
}

class _ProductionImageGrid extends StatelessWidget {
  final List<String> images;

  const _ProductionImageGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    final shownImages = images.take(4).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shownImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(shownImages[index], fit: BoxFit.cover),
        );
      },
    );
  }
}

class _YieldLineChart extends StatelessWidget {
  final SeasonModel season;

  const _YieldLineChart({required this.season});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 9000,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: DoctorCropColors.border,
            strokeWidth: 0.6,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: DoctorCropColors.border,
            strokeWidth: 0.6,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: DoctorCropColors.border, width: 0.8),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              "Yield kg",
              style: TextStyle(fontSize: 10, color: DoctorCropColors.textMuted),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: 2000,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: DoctorCropColors.textMuted,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              "Growth Month",
              style: TextStyle(fontSize: 10, color: DoctorCropColors.textMuted),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  "M${value.toInt() + 1}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: DoctorCropColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 1200),
              const FlSpot(1, 2600),
              const FlSpot(2, 4200),
              const FlSpot(3, 6100),
              const FlSpot(4, 7600),
              FlSpot(5, season.predictedYield),
            ],
            isCurved: true,
            barWidth: 2.8,
            color: DoctorCropColors.primary,
            belowBarData: BarAreaData(
              show: true,
              color: DoctorCropColors.primary.withOpacity(0.12),
            ),
          ),
          LineChartBarData(
            spots: [
              const FlSpot(0, 1000),
              const FlSpot(1, 2300),
              const FlSpot(2, 3900),
              const FlSpot(3, 5600),
              const FlSpot(4, 7000),
              FlSpot(5, season.actualYield),
            ],
            isCurved: true,
            barWidth: 2.8,
            color: DoctorCropColors.info,
            belowBarData: BarAreaData(
              show: true,
              color: DoctorCropColors.info.withOpacity(0.10),
            ),
          ),
        ],
      ),
    );
  }
}

class _RainSalesBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 10,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: DoctorCropColors.border,
            strokeWidth: 0.6,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: DoctorCropColors.border, width: 0.8),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              "Score / 10",
              style: TextStyle(fontSize: 10, color: DoctorCropColors.textMuted),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: DoctorCropColors.textMuted,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              "Season Month",
              style: TextStyle(fontSize: 10, color: DoctorCropColors.textMuted),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  "M${value.toInt() + 1}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: DoctorCropColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: List.generate(6, (i) {
          final rain = [7, 9, 6, 4, 8, 5][i].toDouble();
          final sales = [2, 3, 4, 6, 8, 9][i].toDouble();

          return BarChartGroupData(
            x: i,
            barsSpace: 5,
            barRods: [
              BarChartRodData(
                toY: rain,
                width: 10,
                color: DoctorCropColors.info,
                borderRadius: BorderRadius.circular(3),
              ),
              BarChartRodData(
                toY: sales,
                width: 10,
                color: DoctorCropColors.accent,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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
      ),
    );
  }
}

class _SeasonVideoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F381E), Color(0xFF1E5B33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Seasonal Harvest Review",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: DoctorCropColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              "Watch full seasonal review, harvest story, and market performance recap.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: DoctorCropColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _SmallStatus extends StatelessWidget {
  final String text;
  final Color color;

  const _SmallStatus({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class CreateSeasonPage extends StatefulWidget {
  final Function(SeasonModel season) onCreate;

  const CreateSeasonPage({super.key, required this.onCreate});

  @override
  State<CreateSeasonPage> createState() => _CreateSeasonPageState();
}

class _CreateSeasonPageState extends State<CreateSeasonPage> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final landSizeController = TextEditingController();
  final cropsController = TextEditingController();
  final quantityController = TextEditingController();

  String cropType = "Food crop";

  void _save() {
    final season = SeasonModel(
      name: nameController.text.isEmpty ? "New Season" : nameController.text,
      location: locationController.text.isEmpty
          ? "Rwanda"
          : locationController.text,
      landSize: landSizeController.text.isEmpty
          ? "0 hectares"
          : landSizeController.text,
      crops: cropsController.text.isEmpty
          ? ["Maize"]
          : cropsController.text.split(",").map((e) => e.trim()).toList(),
      cropType: cropType,
      plantedQuantity: quantityController.text.isEmpty
          ? "Standard"
          : quantityController.text,
      period: "Upcoming Season",
      status: "Active Tracking",
      predictedYield: 6400,
      actualYield: 0,
      revenue: 0,
      buyers: 0,
      suppliedPlaces: [
        SupplierPlace(name: "Distribution pending", phone: "Pending"),
      ],
      imageUrl:
          "https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=1200",
      description:
          "This season has been recorded and will monitor crop growth, soil health, and market performance in Rwanda.",
      climateSummary:
          "Weather station records will be updated automatically as precipitation begins.",
      genomeInsight:
          "Genome AI is monitoring market trends and buyer demand across local markets.",
      productionImages: [
        "https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900",
        "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=900",
      ],
    );

    widget.onCreate(season);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              size: 16,
              color: DoctorCropColors.textPrimary,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Record New Season",
          style: TextStyle(
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: DoctorCropTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Input(controller: nameController, label: "Season Name"),
                _Input(controller: locationController, label: "Farm Location / District"),
                _Input(controller: landSizeController, label: "Land Size (e.g. 2 hectares)"),
                _Input(
                  controller: cropsController,
                  label: "Crops (e.g. Irish Potato, Maize)",
                ),
                _Input(controller: quantityController, label: "Planted Quantity"),
                const SizedBox(height: 6),
                const Text(
                  "Crop Classification",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: DoctorCropColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: cropType,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Food crop", child: Text("Food crop")),
                    DropdownMenuItem(value: "Cash crop", child: Text("Cash crop")),
                    DropdownMenuItem(value: "Mixed crop", child: Text("Mixed crop")),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => cropType = value);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text("Save Season Record"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _Input({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: DoctorCropColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: "Enter $label",
            ),
          ),
        ],
      ),
    );
  }
}

class SupplierPlace {
  final String name;
  final String phone;

  SupplierPlace({required this.name, required this.phone});
}

class SeasonModel {
  final String name;
  final String location;
  final String landSize;
  final List<String> crops;
  final String cropType;
  final String plantedQuantity;
  final String period;
  final String status;
  final double predictedYield;
  final double actualYield;
  final int revenue;
  final int buyers;
  final List<SupplierPlace> suppliedPlaces;
  final String imageUrl;
  final String description;
  final String climateSummary;
  final String genomeInsight;
  final List<String> productionImages;

  SeasonModel({
    required this.name,
    required this.location,
    required this.landSize,
    required this.crops,
    required this.cropType,
    required this.plantedQuantity,
    required this.period,
    required this.status,
    required this.predictedYield,
    required this.actualYield,
    required this.revenue,
    required this.buyers,
    required this.suppliedPlaces,
    required this.imageUrl,
    required this.description,
    required this.climateSummary,
    required this.genomeInsight,
    required this.productionImages,
  });
}
