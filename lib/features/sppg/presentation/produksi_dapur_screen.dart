import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

class ProduksiDapurView extends StatefulWidget {
  const ProduksiDapurView({Key? key}) : super(key: key);

  @override
  State<ProduksiDapurView> createState() => _ProduksiDapurViewState();
}

class _ProduksiDapurViewState extends State<ProduksiDapurView> {
  // Filter State: 'Semua', 'Antre', 'Diproses', 'Selesai'
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Antre', 'Diproses', 'Selesai'];

  // --- MOCKUP JSON DATA: DAFTAR PRODUKSI ---
  final String _dummyProductionJson = '''
  [
    {
      "batch_id": "PRD-2026-001",
      "school_name": "SDN 01 Surakarta",
      "target_time": "08:30 WIB",
      "qty_normal": 450,
      "qty_allergy": 12,
      "status": "Diproses",
      "menu": "Nasi Tim Ayam Jamur"
    },
    {
      "batch_id": "PRD-2026-002",
      "school_name": "SMPN 03 Surakarta",
      "target_time": "09:15 WIB",
      "qty_normal": 800,
      "qty_allergy": 5,
      "status": "Antre",
      "menu": "Sup Makaroni Daging"
    },
    {
      "batch_id": "PRD-2026-003",
      "school_name": "SD Muhammadiyah 1",
      "target_time": "07:45 WIB",
      "qty_normal": 600,
      "qty_allergy": 0,
      "status": "Selesai",
      "menu": "Nasi Tim Ayam Jamur"
    },
    {
      "batch_id": "PRD-2026-004",
      "school_name": "SD IT Nur Hidayah",
      "target_time": "10:00 WIB",
      "qty_normal": 350,
      "qty_allergy": 8,
      "status": "Antre",
      "menu": "Nasi Goreng Sayur"
    }
  ]
  ''';

  late List<dynamic> productionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      productionData = jsonDecode(_dummyProductionJson);
      isLoading = false;
    });
  }

  // Fungsi Logika Ganti Status (Simulasi Kanban)
  void _updateStatus(int index, String currentStatus) {
    setState(() {
      if (currentStatus == 'Antre') {
        productionData[index]['status'] = 'Diproses';
      } else if (currentStatus == 'Diproses') {
        productionData[index]['status'] = 'Selesai';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status batch ${productionData[index]['batch_id']} diperbarui!'),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)));
    }

    // Logika Filtering Data
    final filteredData = _selectedFilter == 'Semua' 
        ? productionData 
        : productionData.where((item) => item['status'] == _selectedFilter).toList();

    return Stack(
      children: [
        // Background Aesthetic (Warm Orange/Amber for Kitchen)
        Positioned(top: -50, left: -50, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x15F59E0B), shape: BoxShape.circle))),
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
              title: const Text('Antrean Produksi Dapur', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
              centerTitle: false,
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Metrik
                    _buildOverviewMetrics(),
                    const SizedBox(height: 24),
                    
                    // Filter Pills
                    _buildFilterPills(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ListView Daftar Produksi
            SliverPadding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
              sliver: filteredData.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text('Tidak ada pesanan dengan status $_selectedFilter', style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Karena index list builder berdasarkan filteredData, 
                          // kita butuh index asli dari productionData untuk update status.
                          final item = filteredData[index];
                          final realIndex = productionData.indexWhere((e) => e['batch_id'] == item['batch_id']);
                          
                          return _buildProductionCard(item, realIndex);
                        },
                        childCount: filteredData.length,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  // --- KOMPONEN: Metrik Rekap Atas ---
  Widget _buildOverviewMetrics() {
    int antre = productionData.where((e) => e['status'] == 'Antre').length;
    int proses = productionData.where((e) => e['status'] == 'Diproses').length;
    int selesai = productionData.where((e) => e['status'] == 'Selesai').length;

    return Row(
      children: [
        Expanded(child: _buildMetricBox('Antrean', antre.toString(), const Color(0xFFF59E0B))),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricBox('Memasak', proses.toString(), const Color(0xFF0EA5E9))),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricBox('Selesai', selesai.toString(), const Color(0xFF14B8A6))),
      ],
    );
  }

  Widget _buildMetricBox(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  // --- KOMPONEN: Filter Pills (Segmented) ---
  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- KOMPONEN: Kartu Batch Produksi ---
  Widget _buildProductionCard(Map<String, dynamic> item, int realIndex) {
    final status = item['status'];
    Color statusColor;
    IconData statusIcon;
    String actionText;
    Color actionColor;

    // Logika UI Berdasarkan Status Kanban
    if (status == 'Antre') {
      statusColor = const Color(0xFFF59E0B); // Amber
      statusIcon = Icons.pending_actions_rounded;
      actionText = 'Mulai Proses';
      actionColor = const Color(0xFF0EA5E9);
    } else if (status == 'Diproses') {
      statusColor = const Color(0xFF0EA5E9); // Sky Blue
      statusIcon = Icons.soup_kitchen_rounded;
      actionText = 'Tandai Selesai';
      actionColor = const Color(0xFF14B8A6);
    } else {
      statusColor = const Color(0xFF14B8A6); // Teal
      statusIcon = Icons.check_circle_rounded;
      actionText = ''; // Selesai tidak butuh tombol
      actionColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: status == 'Diproses' ? statusColor.withOpacity(0.5) : const Color(0xFFF1F5F9), width: status == 'Diproses' ? 1.5 : 1),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (ID & Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['batch_id'], style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 6),
                    Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Informasi Sekolah & Menu
          Text(item['school_name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.restaurant_menu_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(item['menu'], style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1.5),
          const SizedBox(height: 16),
          
          // Breakdown Porsi & Target Waktu
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Porsi', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('${item['qty_normal']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const Text(' Nor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                        const SizedBox(width: 8),
                        Text('${item['qty_allergy']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
                        const Text(' Khusus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Target Selesai', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF0F172A)),
                      const SizedBox(width: 4),
                      Text(item['target_time'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tombol Aksi (Jika bukan 'Selesai')
          if (status != 'Selesai') ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 48),
              child: ElevatedButton(
                onPressed: () => _updateStatus(realIndex, status),
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(actionText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ]
        ],
      ),
    );
  }
}