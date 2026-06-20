import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

class InventoryMobileView extends StatefulWidget {
  const InventoryMobileView({Key? key}) : super(key: key);

  @override
  State<InventoryMobileView> createState() => _InventoryMobileViewState();
}

class _InventoryMobileViewState extends State<InventoryMobileView> {
  // --- MOCKUP JSON DATA: INVENTORY & STOCK ALERTS ---
  final String _dummyInventoryJson = '''
  {
    "stock_metrics": {
      "total_items": 42,
      "low_stock_count": 3,
      "expired_alert_count": 2
    },
    "critical_alerts": [
      {
        "id": "INV-091",
        "name": "Daging Ayam Fillet",
        "type": "expired",
        "days_left": 1,
        "date_label": "Sisa 1 Hari (21 Juni 2026)",
        "color": "EF4444"
      },
      {
        "id": "INV-023",
        "name": "Beras Cianjur",
        "type": "low_stock",
        "current_stock": "50 kg",
        "min_stock": "200 kg",
        "date_label": "Stok di bawah batas minimum",
        "color": "F59E0B"
      }
    ],
    "recent_logs": [
      {"time": "10:15 WIB", "item": "Susu UHT Plain", "qty": "+10 Karton", "type": "masuk", "color": "14B8A6"},
      {"time": "08:30 WIB", "item": "Daging Ayam Fillet", "qty": "-45 kg", "type": "keluar", "color": "64748B"},
      {"time": "06:00 WIB", "item": "Sayur Wortel Lokal", "qty": "-20 kg", "type": "keluar", "color": "64748B"},
      {"time": "Kemarin", "item": "Minyak Goreng Sawit", "qty": "+50 Liter", "type": "masuk", "color": "14B8A6"}
    ]
  }
  ''';

  late Map<String, dynamic> invData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  void _loadInventoryData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      invData = jsonDecode(_dummyInventoryJson);
      isLoading = false;
    });
  }

  // Simulasi Fungsi QR Scanner Bahan Baku
  void _openQRScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Membuka kamera untuk pemindaian QR bahan baku...'),
          ],
        ),
        backgroundColor: Color(0xFF14B8A6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6)));
    }

    final metrics = invData['stock_metrics'];
    final alerts = invData['critical_alerts'] as List;
    final logs = invData['recent_logs'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Glow Tint (Teal Gudang)
          Positioned(top: -60, right: -60, child: Container(width: 280, height: 280, decoration: const BoxDecoration(color: Color(0x2014B8A6), shape: BoxShape.circle))),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 70.0,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const Text('Gudang & Logistik', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
                centerTitle: false,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 120.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 1. QUICK ACTIONS GRID (SCAN & MUTASI) ---
                      _buildQuickActionsRow(),
                      const SizedBox(height: 28),

                      // --- 2. SUMMARY METRICS BENTO ---
                      const Text('Ringkasan Inventaris', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      _buildMetricsBento(metrics),
                      const SizedBox(height: 28),

                      // --- 3. CRITICAL ALERTS LIST (STOK & EXPIRED) ---
                      if (alerts.isNotEmpty) ...[
                        const Text('Perhatian Khusus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFEF4444), letterSpacing: -0.5)),
                        const SizedBox(height: 12),
                        _buildAlertsList(alerts),
                        const SizedBox(height: 28),
                      ],

                      // --- 4. RECENT MUTATION LOGS ---
                      const Text('Log Mutasi Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      _buildMutationLogs(logs),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN: Baris Tombol Scanner & Log Mutasi ---
  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _openQRScanner,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0D9488)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF14B8A6).withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text('Scan QR Bahan', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_box_outlined, color: Color(0xFF0F172A)),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pencatatan Barang Masuk'))),
                ),
                Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                IconButton(
                  icon: const Icon(Icons.indeterminate_check_box_outlined, color: Color(0xFF0F172A)),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pencatatan Barang Keluar'))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- KOMPONEN: Bento Grid Metrik Ringkas ---
  Widget _buildMetricsBento(Map<String, dynamic> metrics) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total SKU', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('${metrics['total_items']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stok Tipis', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('${metrics['low_stock_count']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kedaluwarsa', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('${metrics['expired_alert_count']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- KOMPONEN: Daftar Peringatan Bahaya ---
  Widget _buildAlertsList(List<dynamic> alerts) {
    return Column(
      children: alerts.map<Widget>((alert) {
        final Color accentColor = Color(int.parse("0xFF${alert['color']}"));
        final bool isExpired = alert['type'] == 'expired';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(isExpired ? Icons.running_with_errors_rounded : Icons.inventory_2_rounded, color: accentColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text(alert['date_label'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor)),
                  ],
                ),
              ),
              if (!isExpired)
                Text(alert['current_stock'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)))
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- KOMPONEN: Log Perubahan Mutasi ---
  Widget _buildMutationLogs(List<dynamic> logs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: logs.length,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Divider(color: Color(0xFFF1F5F9), height: 1),
        ),
        itemBuilder: (context, index) {
          final log = logs[index];
          final Color typeColor = Color(int.parse("0xFF${log['color']}"));
          final bool isMasuk = log['type'] == 'masuk';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(isMasuk ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: typeColor, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log['item'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text(log['time'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Text(
                  log['qty'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isMasuk ? typeColor : const Color(0xFF0F172A)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}