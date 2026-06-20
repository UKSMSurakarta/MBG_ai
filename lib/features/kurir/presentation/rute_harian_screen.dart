import 'dart:ui';
import 'package:flutter/material.dart';
import 'navigasi_kurir_screen.dart';
import 'navigasi_kurir_screen.dart';
// ============================================================================
// 1. MAIN LAYOUT (CANGKANG NAVBAR KURIR)
// ============================================================================
class KurirMainScreen extends StatefulWidget {
  const KurirMainScreen({Key? key}) : super(key: key);

  @override
  State<KurirMainScreen> createState() => _KurirMainScreenState();
}

class _KurirMainScreenState extends State<KurirMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
    void initState() {
      super.initState();
      _pages = [
        // Index 0: Rute Harian
        RuteHarianView(
          onNavigate: (index) => setState(() => _currentIndex = index),
        ),

        // Index 1: Navigasi (GANTI BAGIAN INI)
        const NavigasiKurirView(), 

        // Index 2: Serah Terima (POD)
        const SerahTerimaView(),
      ];
    }

  Widget _buildDummyPage(String title, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true, // Konten tembus di balik navbar
      
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: _pages[_currentIndex],
      ),
      
      bottomNavigationBar: _buildGlassNavbar(),
    );
  }

  Widget _buildGlassNavbar() {
    final List<Map<String, dynamic>> navItems = [
      {'label': 'Rute', 'icon': Icons.route_outlined, 'activeIcon': Icons.route_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Navigasi', 'icon': Icons.map_outlined, 'activeIcon': Icons.map_rounded, 'color': const Color(0xFF0EA5E9)},
      {'label': 'Serah Terima', 'icon': Icons.qr_code_scanner_rounded, 'activeIcon': Icons.qr_code_rounded, 'color': const Color(0xFF14B8A6)},
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              color: Colors.white.withOpacity(0.85),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = _currentIndex == index;
                  final color = item['color'] as Color;

                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isSelected ? item['activeIcon'] : item['icon'], color: isSelected ? color : const Color(0xFF94A3B8), size: 24),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: isSelected ? null : 0,
                              child: Padding(
                                padding: EdgeInsets.only(left: isSelected ? 8.0 : 0.0),
                                child: Text(
                                  item['label'],
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. KONTEN: RUTE HARIAN (Bebas Emoji & Styling Diperbarui)
// ============================================================================
class RuteHarianView extends StatefulWidget {
  final Function(int)? onNavigate;

  const RuteHarianView({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<RuteHarianView> createState() => _RuteHarianViewState();
}

class _RuteHarianViewState extends State<RuteHarianView> {
  bool _isTrackingActive = false;

  final List<Map<String, dynamic>> _ruteSekolah = [
    {'nama': 'SDN 01 Surakarta', 'jarak': '1.2 km', 'normal': 120, 'khusus': 3, 'status': 'Menuju Lokasi', 'color': const Color(0xFFF59E0B)},
    {'nama': 'SMPN 03 Surakarta', 'jarak': '3.5 km', 'normal': 250, 'khusus': 7, 'status': 'Menunggu', 'color': const Color(0xFF94A3B8)},
    {'nama': 'SD Muhammadiyah 1', 'jarak': '5.0 km', 'normal': 180, 'khusus': 2, 'status': 'Selesai', 'color': const Color(0xFF14B8A6)},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -50, left: -100, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x20F59E0B), shape: BoxShape.circle))), // Amber background for courier
        Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildTrackingToggleBanner(),
                      const SizedBox(height: 20),
                      _buildCargoStatsBento(),
                      const SizedBox(height: 28),
                      const Text('Rute Distribusi Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120), // Padding Navbar
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSchoolRouteCard(_ruteSekolah[index]),
                    childCount: _ruteSekolah.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Gasss, Mas Bagus! ⚡', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
            SizedBox(height: 4),
            Text('Armada #04 • Dapur SPPG', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0), width: 2), image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?img=60'), fit: BoxFit.cover)),
        ),
      ],
    );
  }

  Widget _buildTrackingToggleBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isTrackingActive ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isTrackingActive ? Colors.transparent : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(_isTrackingActive ? 0.2 : 0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _isTrackingActive ? const Color(0xFFF59E0B).withOpacity(0.2) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: Icon(_isTrackingActive ? Icons.satellite_alt_rounded : Icons.location_off_rounded, color: _isTrackingActive ? const Color(0xFFFCD34D) : const Color(0xFF64748B), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isTrackingActive ? 'Radar Tracking Aktif' : 'Radar Sinyal Mati', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _isTrackingActive ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(_isTrackingActive ? 'Sekolah memantau ETA-mu' : 'Aktifkan GPS sebelum jalan', style: TextStyle(fontSize: 12, color: _isTrackingActive ? Colors.white60 : const Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Switch.adaptive(value: _isTrackingActive, activeColor: const Color(0xFFF59E0B), onChanged: (value) => setState(() => _isTrackingActive = value)),
        ],
      ),
    );
  }

  Widget _buildCargoStatsBento() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_rounded, size: 16, color: const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    const Text('Box Normal', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('550', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1)),
                const Text('Total porsi aman', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFECACA))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: const Color(0xFFDC2626)),
                    const SizedBox(width: 6),
                    const Text('Porsi Alergi', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('12', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFDC2626), letterSpacing: -1)),
                const Text('Pisahkan muatan!', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolRouteCard(Map<String, dynamic> sekolah) {
    final status = sekolah['status'];
    final baseColor = sekolah['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: status == 'Menuju Lokasi' ? baseColor : const Color(0xFFF1F5F9), width: status == 'Menuju Lokasi' ? 1.5 : 1),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sekolah['nama'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text('Jarak: ${sekolah['jarak']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: baseColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Text(status, style: TextStyle(color: baseColor, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 14),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildPortionBadge('${sekolah['normal']} Normal', const Color(0xFF475569)),
                  const SizedBox(width: 8),
                  if (sekolah['khusus'] > 0) _buildPortionBadge('${sekolah['khusus']} Alergi', const Color(0xFFEF4444)),
                ],
              ),
              
              if (status == 'Menuju Lokasi')
                ElevatedButton.icon(
                  onPressed: () {
                    // Trigger Navigasi Tab
                    if (widget.onNavigate != null) widget.onNavigate!(1);
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 14),
                  label: const Text('Navigasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else if (status == 'Menunggu')
                OutlinedButton(
                  onPressed: () => setState(() {
                    sekolah['status'] = 'Menuju Lokasi';
                    sekolah['color'] = const Color(0xFFF59E0B);
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Mulai Jalan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              else
                const Icon(Icons.check_circle_rounded, color: Color(0xFF14B8A6), size: 24),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPortionBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ============================================================================
// 3. KONTEN: SERAH TERIMA (POD)
// ============================================================================
class SerahTerimaView extends StatelessWidget {
  const SerahTerimaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -50, right: -100, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x2014B8A6), shape: BoxShape.circle))), // Teal BG
        Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Proof of Delivery', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                const SizedBox(height: 4),
                const Text('SDN 01 Surakarta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF14B8A6))),
                const SizedBox(height: 32),

                // Card 1: Scan QR
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDF4), shape: BoxShape.circle),
                        child: const Icon(Icons.qr_code_scanner_rounded, size: 40, color: Color(0xFF16A34A)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Scan QR Sekolah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      const Text('Pindai barcode dari aplikasi Guru', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 44),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14B8A6), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Buka Kamera', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      )
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 2: Foto Bukti Drop-off
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.add_a_photo_rounded, color: Color(0xFF0EA5E9), size: 20),
                          const SizedBox(width: 8),
                          const Text('Foto Bukti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFCBD5E1))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt_rounded, color: Color(0xFF94A3B8), size: 32),
                            SizedBox(height: 8),
                            Text('Ketuk untuk ambil foto', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 3: Tanda Tangan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.draw_rounded, color: Color(0xFFF59E0B), size: 20),
                          const SizedBox(width: 8),
                          const Text('Tanda Tangan Guru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFCBD5E1))),
                        child: const Center(child: Text('Area Tanda Tangan Digital', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500))),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Selesai
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Pengiriman selesai!'), backgroundColor: Color(0xFF14B8A6)));
                    },
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                    label: const Text('Selesaikan Pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: const Color(0xFF0F172A).withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}