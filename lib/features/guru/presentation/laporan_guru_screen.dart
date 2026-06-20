import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

class LaporanGuruScreen extends StatefulWidget {
  const LaporanGuruScreen({Key? key}) : super(key: key);

  @override
  State<LaporanGuruScreen> createState() => _LaporanGuruScreenState();
}

class _LaporanGuruScreenState extends State<LaporanGuruScreen> {
  // --- STATE UNTUK TOGGLE TAB ---
  // 0 = Buat Laporan, 1 = Riwayat Laporan
  int _currentTab = 0;

  // --- STATE UNTUK FORM LAPORAN ---
  String _selectedCategory = 'Porsi Kurang';
  final List<String> _categories = ['Porsi Kurang', 'Makanan Rusak', 'Keterlambatan', 'Lainnya'];
  final TextEditingController _descController = TextEditingController();
  bool _hasUploadedImage = false; // Mockup status upload gambar

  // --- MOCKUP JSON DATA: RIWAYAT LAPORAN ---
  final String _dummyHistoryJson = '''
  [
    {
      "id": "TKT-2606-001",
      "date": "19 Juni 2026 • 11:30 WIB",
      "category": "Makanan Rusak",
      "description": "Satu box nasi tim ayam tutupnya terbuka dan isinya tumpah di dalam kantong plastik.",
      "status": "diproses",
      "status_label": "Sedang Diproses"
    },
    {
      "id": "TKT-2505-089",
      "date": "25 Mei 2026 • 11:45 WIB",
      "category": "Porsi Kurang",
      "description": "Porsi yang datang hanya 28, padahal total siswa hadir 30 anak.",
      "status": "selesai",
      "status_label": "Masalah Selesai"
    }
  ]
  ''';

  late List<dynamic> historyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      historyData = jsonDecode(_dummyHistoryJson);
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  // --- FUNGSI MOCKUP SUBMIT ---
  void _submitReport() {
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tuliskan deskripsi kendala terlebih dahulu!'), backgroundColor: Color(0xFFEF4444)));
      return;
    }

    // Simulasi sukses
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Laporan berhasil dikirim ke Dapur SPPG!'), backgroundColor: Color(0xFF14B8A6)));
    
    setState(() {
      _descController.clear();
      _hasUploadedImage = false;
      _currentTab = 1; // Otomatis pindah ke tab riwayat
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pusat Bantuan', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Aesthetic (Soft Red/Orange for alerts)
          Positioned(top: -50, right: -50, child: Container(width: 250, height: 250, decoration: const BoxDecoration(color: Color(0x20EF4444), shape: BoxShape.circle))),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

          Column(
            children: [
              // --- SLIDING TOGGLE TAB ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0).withOpacity(0.5), borderRadius: BorderRadius.circular(26)),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentTab = 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: _currentTab == 0 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: _currentTab == 0 ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))] : [],
                            ),
                            child: Center(
                              child: Text('Buat Laporan', style: TextStyle(color: _currentTab == 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 13)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentTab = 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: _currentTab == 1 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: _currentTab == 1 ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))] : [],
                            ),
                            child: Center(
                              child: Text('Riwayat Laporan', style: TextStyle(color: _currentTab == 1 ? const Color(0xFF0F172A) : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 13)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- KONTEN UTAMA (ANIMATED SWITCHER) ---
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.05, 0.0), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _currentTab == 0 ? _buildFormTab() : _buildHistoryTab(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 1: FORM BUAT LAPORAN
  // ==========================================================================
  Widget _buildFormTab() {
    return SingleChildScrollView(
      key: const ValueKey('form_tab'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori Kendala', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          
          // Chips Kategori
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0EA5E9) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? const Color(0xFF0EA5E9) : const Color(0xFFE2E8F0)),
                    boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 28),
          const Text('Deskripsi Detail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          
          // Text Area Deskripsi
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TextField(
              controller: _descController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
              decoration: const InputDecoration(
                hintText: 'Jelaskan kendala yang terjadi di lapangan secara detail...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 28),
          const Text('Lampirkan Bukti Foto (Wajib)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          
          // Area Upload Bukti (Dashed Mockup)
          GestureDetector(
            onTap: () {
              // Simulasi pilih foto
              setState(() => _hasUploadedImage = !_hasUploadedImage);
            },
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: _hasUploadedImage ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                // Menggunakan border biasa karena dashed border butuh package tambahan, kita buat style rapi
                border: Border.all(color: _hasUploadedImage ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1), width: 2, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _hasUploadedImage ? const Color(0xFF16A34A) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Icon(
                      _hasUploadedImage ? Icons.check_rounded : Icons.camera_alt_rounded,
                      color: _hasUploadedImage ? Colors.white : const Color(0xFF64748B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _hasUploadedImage ? 'Bukti Foto Berhasil Dilampirkan' : 'Ketuk untuk mengambil foto makanan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _hasUploadedImage ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
          
          // Tombol Kirim
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 56),
            child: ElevatedButton.icon(
              onPressed: _submitReport,
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              label: const Text('Kirim Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                elevation: 10,
                shadowColor: const Color(0xFF0F172A).withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 2: RIWAYAT LAPORAN
  // ==========================================================================
  Widget _buildHistoryTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)));
    }

    return ListView.separated(
      key: const ValueKey('history_tab'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      itemCount: historyData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final ticket = historyData[index];
        final isDone = ticket['status'] == 'selesai';
        
        Color statusColor = isDone ? const Color(0xFF14B8A6) : const Color(0xFFF59E0B);
        Color bgColor = isDone ? const Color(0xFFF0FDF4) : const Color(0xFFFEF3C7);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status & ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ticket['id'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(ticket['status_label'], style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Kategori
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF0F172A), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(ticket['category'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 12),
              
              // Deskripsi
              Text(ticket['description'], style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5, fontWeight: FontWeight.w500)),
              
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
              const SizedBox(height: 16),
              
              // Tanggal
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(ticket['date'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}