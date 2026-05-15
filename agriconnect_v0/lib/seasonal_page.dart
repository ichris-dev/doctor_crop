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
      status: "Done",
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
      status: "Done",
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
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSeason,
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Season"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSeasonSearchHeader(),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: filteredSeasons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
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
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(color: Colors.black.withAlpha(200)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(24)),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white70, size: 18),
                  hintText: "Search seasons, crops, location...",
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                seasons.sort((a, b) => b.actualYield.compareTo(a.actualYield));
              });
            },
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(24),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(26)),
              ),
              child: const Icon(
                Icons.sort_rounded,
                color: Colors.white,
                size: 23,
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 135,
              height: double.infinity,
              child: Image.network(season.imageUrl, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      season.period,
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      season.location,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _SmallStatus(
                          text: season.status,
                          color: const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${season.actualYield.toInt()} kg output",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFF97316),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF9CA3AF),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(200),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          season.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 26),
        children: [
          _TopImage(season: season),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle("Season Description"),
                const SizedBox(height: 6),
                Text(
                  season.description,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 20),

                _SectionTitle("Yield and Products"),
                const SizedBox(height: 8),
                _YieldProductTable(season: season, performance: performance),

                const SizedBox(height: 22),

                _SectionTitle("Supplied Places"),
                const SizedBox(height: 8),
                _SuppliedPlacesTable(places: season.suppliedPlaces),

                const SizedBox(height: 22),

                _SectionTitle("Production Images"),
                const SizedBox(height: 8),
                _ProductionImageGrid(images: season.productionImages),

                const SizedBox(height: 24),

                _SectionTitle("Predicted vs Actual Yield"),
                const SizedBox(height: 4),
                const Text(
                  "Mountain-style growth comparison across the season.",
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(height: 285, child: _YieldLineChart(season: season)),

                const SizedBox(height: 26),

                _SectionTitle("Rain and Sales Performance"),
                const SizedBox(height: 4),
                const Text(
                  "Rain and sales score comparison by season month.",
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(height: 285, child: _RainSalesBarChart()),

                const SizedBox(height: 24),

                _InfoCard(
                  title: "Genome AI Market Exploration",
                  icon: Icons.auto_awesome,
                  color: const Color(0xFF16A34A),
                  text: season.genomeInsight,
                ),

                const SizedBox(height: 14),

                _InfoCard(
                  title: "Climate Behavior",
                  icon: Icons.cloud,
                  color: const Color(0xFF2563EB),
                  text: season.climateSummary,
                ),

                const SizedBox(height: 18),

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
      height: 225,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(season.imageUrl, fit: BoxFit.cover),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withAlpha(120),
                  Colors.black.withAlpha(35),
                  Colors.black.withAlpha(135),
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
              color: const Color(0xFF16A34A),
            ),
          ),

          Positioned(
            right: 14,
            top: 14,
            child: _ImageBadge(
              text: season.cropType,
              icon: Icons.eco_outlined,
              color: const Color(0xFFF97316),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${season.period} • ${season.location}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
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
      border: TableBorder.all(color: const Color(0xFFE5E7EB)),
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
      border: TableBorder.all(color: const Color(0xFFE5E7EB)),
      columnWidths: const {0: FlexColumnWidth(1.4), 1: FlexColumnWidth(1.1)},
      children: [
        _tableRow(["Place", "Phone"], isHeader: true),
        ...places.map((place) => _tableRow([place.name, place.phone])),
      ],
    );
  }
}

TableRow _tableRow(List<String> values, {bool isHeader = false}) {
  return TableRow(
    decoration: BoxDecoration(
      color: isHeader ? const Color(0xFFF9FAFB) : Colors.white,
    ),
    children: values.map((value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          value,
          style: TextStyle(
            color: const Color(0xFF111827),
            fontSize: 12,
            fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
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
          borderRadius: BorderRadius.circular(8),
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
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              "Yield kg",
              style: TextStyle(fontSize: 11),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 2000,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              "Growth Month",
              style: TextStyle(fontSize: 11),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  "M${value.toInt() + 1}",
                  style: const TextStyle(fontSize: 10),
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
            barWidth: 3,
            color: const Color(0xFF16A34A),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF16A34A).withAlpha(35),
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
            barWidth: 3,
            color: const Color(0xFF2563EB),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2563EB).withAlpha(28),
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
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              "Score / 10",
              style: TextStyle(fontSize: 11),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              "Season Month",
              style: TextStyle(fontSize: 11),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  "M${value.toInt() + 1}",
                  style: const TextStyle(fontSize: 10),
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
                width: 11,
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(3),
              ),
              BarChartRodData(
                toY: sales,
                width: 11,
                color: const Color(0xFFF97316),
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
        color: color.withAlpha(14),
        border: Border.all(color: color.withAlpha(50)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: color.withAlpha(28),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 13,
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
      margin: const EdgeInsets.only(bottom: 42),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(22),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withAlpha(35),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                "Season Review",
                style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(45),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),

          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              "Watch seasonal review, harvest story, market performance, and farm output summary.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.35,
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
    Color color = const Color(0xFF111827);

    if (text.contains("Yield") || text.contains("Description")) {
      color = const Color(0xFF16A34A);
    } else if (text.contains("Rain") || text.contains("Supplied")) {
      color = const Color(0xFF2563EB);
    } else if (text.contains("Images")) {
      color = const Color(0xFFF97316);
    }

    return Text(
      text,
      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
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
          ? "Unknown"
          : locationController.text,
      landSize: landSizeController.text.isEmpty
          ? "0 hectares"
          : landSizeController.text,
      crops: cropsController.text.isEmpty
          ? ["Maize"]
          : cropsController.text.split(",").map((e) => e.trim()).toList(),
      cropType: cropType,
      plantedQuantity: quantityController.text.isEmpty
          ? "Unknown"
          : quantityController.text,
      period: "Upcoming Season",
      status: "Prediction Active",
      predictedYield: 6400,
      actualYield: 0,
      revenue: 0,
      buyers: 0,
      suppliedPlaces: [
        SupplierPlace(name: "Not supplied yet", phone: "No phone"),
      ],
      imageUrl:
          "https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=1200",
      description:
          "This new season has been created and will begin collecting crop, weather, price, and market performance data.",
      climateSummary:
          "Climate tracking will begin after rainfall and temperature data is collected.",
      genomeInsight:
          "Genome AI will monitor market prices, harvest timing, demand, and possible buyers.",
      productionImages: [
        "https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900",
        "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=900",
        "https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?w=900",
        "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=900",
      ],
    );

    widget.onCreate(season);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(200),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Season",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Input(controller: nameController, label: "Season name"),
          _Input(controller: locationController, label: "Farm location"),
          _Input(controller: landSizeController, label: "Land size"),
          _Input(
            controller: cropsController,
            label: "Crops, separated by comma",
          ),
          _Input(controller: quantityController, label: "Planting quantity"),
          DropdownButtonFormField<String>(
            value: cropType,
            decoration: _inputDecoration("Crop type"),
            items: const [
              DropdownMenuItem(value: "Food crop", child: Text("Food crop")),
              DropdownMenuItem(value: "Cash crop", child: Text("Cash crop")),
              DropdownMenuItem(value: "Mixed crop", child: Text("Mixed crop")),
            ],
            onChanged: (value) {
              if (value != null) setState(() => cropType = value);
            },
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text("Create Season"),
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
      padding: const EdgeInsets.only(bottom: 13),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
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
