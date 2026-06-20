import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

class LogGiziView extends StatefulWidget {
  const LogGiziView({Key? key}) : super(key: key);

  @override
  State<LogGiziView> createState() => _LogGiziViewState();
}

class _LogGiziViewState extends State<LogGiziView> {
  // --- MOCKUP JSON DATA: LOG GIZI ---
  final String _dummyLogJson = '''
  {
    "summary": {
      "status": "Sangat Baik",
      "status_desc": "Asupan nutrisi minggu ini stabil dan sesuai target pertumbuhan.",
      "avg_calories": "1450 kcal",
      "avg_protein": "45g"
    },
    "weekly_chart": [
      {"day": "Sen", "cal_percent": 0.85, "prot_percent": 0.90},
      {"day": "Sel", "cal_percent": 0.95, "prot_percent": 0.85},
      {"day": "Rab", "cal_percent": 1.0, "prot_percent": 1.0},
      {"day": "Kam", "cal_percent": 0.60, "prot_percent": 0.50},
      {"day": "Jum", "cal_percent": 0.90, "prot_percent": 0.80}
    ],
    "food_waste": {
      "today": "0%",
      "yesterday": "15%",
      "trend": "Membaik",
      "note": "Anak menghabiskan seluruh porsi hari ini. Bagus sekali!"
    },
    "history": [
      {"date": "19 Jun 2026", "menu": "Nasi Tim Ayam Jamur", "status": "Habis 100%", "color": "14B8A6"},
      {"date": "18 Jun 2026", "menu": "Sup Makaroni Daging", "status": "Sisa Sedikit", "color": "F59E0B"},
      {"date": "17 Jun 2026", "menu": "Nasi Goreng Sayur", "status": "Habis 100%", "color": "14B8A6"}
    ]
  }
  ''';

  late Map<String, dynamic> data;
  bool isLoading = true;
  
  // Toggle untuk melihat grafik (0 = Kalori, 1 = Protein)
  int _selectedChart = 0; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      data = jsonDecode(_dummyLogJson);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)));
    }

    return Stack(
      children: [
        // Background Aesthetic (Sky Blue & Purple)
        Positioned(top: -50, right: -100, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x200EA5E9), shape: BoxShape.circle))),
        Positioned(bottom: 100, left: -50, child: Container(width: 250, height: 250, decoration: const BoxDecoration(color: Color(0x208B5CF6), shape: BoxShape.circle))),
        Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 70.0,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text('Log Nutrisi & Gizi', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
              centerTitle: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 120.0), // Padding bawah hindari navbar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNutritionSummary(),
                    const SizedBox(height: 28),
                    
                    const Text('Grafik Mingguan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildCustomChart(),
                    
                    const SizedBox(height: 28),
                    const Text('Food Waste Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildFoodWasteCard(),
                    
                    const SizedBox(height: 28),
                    const Text('Riwayat Konsumsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildHistoryList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionSummary() {
    final summary = data['summary'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF14B8A6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF14B8A6), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Status Gizi Anak', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(20)),
                child: Text(summary['status'], style: const TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(summary['status_desc'], style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1.5),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Rata-rata Kalori', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(summary['avg_calories'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0EA5E9))),
                ],
              ),
              Container(width: 1.5, height: 30, color: const Color(0xFFE2E8F0)),
              Column(
                children: [
                  const Text('Rata-rata Protein', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(summary['avg_protein'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6))),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCustomChart() {
    final chartData = data['weekly_chart'] as List;
    final isCalorie = _selectedChart == 0;
    final activeColor = isCalorie ? const Color(0xFF0EA5E9) : const Color(0xFF8B5CF6);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChart = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(color: isCalorie ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18), boxShadow: isCalorie ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : []),
                      child: Center(child: Text('Kalori', style: TextStyle(color: isCalorie ? const Color(0xFF0EA5E9) : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 13))),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChart = 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(color: !isCalorie ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18), boxShadow: !isCalorie ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : []),
                      child: Center(child: Text('Protein', style: TextStyle(color: !isCalorie ? const Color(0xFF8B5CF6) : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 13))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(minHeight: 160),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map<Widget>((dayData) {
                final double percentage = isCalorie ? dayData['cal_percent'] : dayData['prot_percent'];
                final bool isLow = percentage < 0.75;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${(percentage * 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isLow ? const Color(0xFFF59E0B) : activeColor)),
                    const SizedBox(height: 6),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(width: 32, height: 110, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8))),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          width: 32,
                          height: 110 * percentage,
                          decoration: BoxDecoration(
                            color: isLow ? const Color(0xFFF59E0B) : activeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(dayData['day'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodWasteCard() {
    final waste = data['food_waste'];
    final bool isPerfect = waste['today'] == "0%";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPerfect ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isPerfect ? const Color(0xFFBBF7D0) : const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(isPerfect ? Icons.sentiment_very_satisfied_rounded : Icons.delete_outline_rounded, color: isPerfect ? const Color(0xFF16A34A) : const Color(0xFFEF4444), size: 24),
                  const SizedBox(width: 10),
                  Text('Sisa Makanan Hari Ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isPerfect ? const Color(0xFF16A34A) : const Color(0xFF0F172A))),
                ],
              ),
              Text(waste['today'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isPerfect ? const Color(0xFF16A34A) : const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 12),
          Text(waste['note'], style: TextStyle(fontSize: 13, color: isPerfect ? const Color(0xFF15803D) : const Color(0xFF64748B), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final history = data['history'] as List;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = history[index];
        final badgeColor = Color(int.parse("0xFF${item['color']}"));

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.restaurant_rounded, color: Color(0xFF94A3B8), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['menu'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item['date'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(item['status'], style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        );
      },
    );
  }
}