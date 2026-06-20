import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'profil_anak_screen.dart';
import 'log_gizi_screen.dart';
import 'ai_gizi_screen.dart';

// ============================================================================
// 1. MAIN LAYOUT (CANGKANG NAVBAR ORANG TUA)
// ============================================================================
class OrtuMainScreen extends StatefulWidget {
  const OrtuMainScreen({Key? key}) : super(key: key);

  @override
  State<OrtuMainScreen> createState() => _OrtuMainScreenState();
}

class _OrtuMainScreenState extends State<OrtuMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

 @override
  void initState() {
    super.initState();
    _pages = [
      // Tab 0: Beranda
      BerandaOrtuView(
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      
      // Tab 1: Profil Anak
      const ProfilAnakView(), 
      
      // Tab 2: Log Gizi
      const LogGiziView(),
      // Tab 3: AI Gizi Dashboard
      const AIGiziView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true, // Konten tembus di balik navbar kaca
      
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
      {'label': 'Beranda', 'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Profil Anak', 'icon': Icons.child_care_rounded, 'activeIcon': Icons.child_care_rounded, 'color': const Color(0xFF14B8A6)},
      {'label': 'Log Gizi', 'icon': Icons.bar_chart_rounded, 'activeIcon': Icons.stacked_bar_chart_rounded, 'color': const Color(0xFF0EA5E9)},
      {'label': 'AI Gizi', 'icon': Icons.auto_awesome_outlined, 'activeIcon': Icons.auto_awesome_rounded, 'color': const Color(0xFF8B5CF6)},
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
                                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
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
// 2. KONTEN: BERANDA ORANG TUA
// ============================================================================
class BerandaOrtuView extends StatefulWidget {
  final Function(int)? onNavigate;
  const BerandaOrtuView({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<BerandaOrtuView> createState() => _BerandaOrtuViewState();
}

class _BerandaOrtuViewState extends State<BerandaOrtuView> {
  // --- MOCKUP JSON DATA: DASHBOARD ORTU ---
  final String _dummyBerandaJson = '''
  {
    "parent_name": "Mama Rayyan",
    "child": {
      "name": "Rayyan",
      "class": "4A",
      "school": "SDN 01 Surakarta",
      "avatar": "https://i.pravatar.cc/150?img=47"
    },
    "today_menu": {
      "title": "Nasi Tim Ayam Jamur",
      "subtitle": "Susu UHT & Buah Pisang",
      "calories": 520,
      "protein": 24,
      "fat": 12,
      "allergy_safe": true,
      "allergy_note": "Bebas Telur"
    },
    "menu_alert": {
      "has_alert": true,
      "message": "Menu diganti dari Telur Dadar ke Nasi Ayam menyesuaikan profil alergi anak Anda."
    },
    "delivery": {
      "status": "Makanan Tiba",
      "time": "11:15 WIB"
    },
    "yesterday_log": {
      "status": "Habis 100%",
      "waste": "0g"
    }
  }
  ''';

  late Map<String, dynamic> data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      data = jsonDecode(_dummyBerandaJson);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)));
    }

    return Stack(
      children: [
        Positioned(top: -100, left: -50, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x30F59E0B), shape: BoxShape.circle))),
        Positioned(bottom: 200, right: -100, child: Container(width: 250, height: 250, decoration: const BoxDecoration(color: Color(0x300EA5E9), shape: BoxShape.circle))),
        Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 120.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notifikasi Pergantian Menu (Alert Box)
                      if (data['menu_alert']['has_alert']) _buildMenuAlertBanner(),
                      if (data['menu_alert']['has_alert']) const SizedBox(height: 20),

                      _buildHeroMenuCard(),
                      const SizedBox(height: 28),
                      
                      const Text('Pantau Si Kecil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                      const SizedBox(height: 16),
                      _buildTrackingAndLogBento(),
                      
                      const SizedBox(height: 28),
                      _buildAIBanner(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Halo, ${data['parent_name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Siswa Kelas ${data['child']['class']} • ${data['child']['school']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0), width: 2), image: DecorationImage(image: NetworkImage(data['child']['avatar']), fit: BoxFit.cover)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFECACA))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.shield_rounded, color: Color(0xFFEF4444), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Penyesuaian Alergi Diterapkan', style: TextStyle(color: Color(0xFFB91C1C), fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(data['menu_alert']['message'], style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMenuCard() {
    final menu = data['today_menu'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image Placeholder (Gradient with Pattern)
          Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              gradient: LinearGradient(colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Stack(
              children: [
                Positioned(right: -10, bottom: -10, child: Icon(Icons.restaurant_rounded, size: 120, color: Colors.white.withOpacity(0.2))),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: const [
                        Icon(Icons.restaurant_menu_rounded, color: Color(0xFFF59E0B), size: 16),
                        SizedBox(width: 6),
                        Text('Menu Anak Hari Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(menu['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.add_circle_outline_rounded, size: 14, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Text(menu['subtitle'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (menu['allergy_safe'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFECACA))),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: Color(0xFFEF4444), size: 14),
                            const SizedBox(width: 6),
                            Text(menu['allergy_note'], style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1.5),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientStat(Icons.local_fire_department_rounded, '${menu['calories']}', 'Kalori'),
                    Container(width: 1.5, height: 35, color: const Color(0xFFF1F5F9)),
                    _buildNutrientStat(Icons.fitness_center_rounded, '${menu['protein']}g', 'Protein'),
                    Container(width: 1.5, height: 35, color: const Color(0xFFF1F5F9)),
                    _buildNutrientStat(Icons.water_drop_rounded, '${menu['fat']}g', 'Lemak'),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingAndLogBento() {
    return Row(
      children: [
        // Status Pengiriman
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 160),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6), // Teal
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF14B8A6).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['delivery']['status'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Diterima ${data['delivery']['time']}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Log Gizi Kemarin
        Expanded(
          child: GestureDetector(
            onTap: () { if (widget.onNavigate != null) widget.onNavigate!(2); }, // Ke Tab Log Gizi
            child: Container(
              constraints: const BoxConstraints(minHeight: 160),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.restaurant_rounded, color: Color(0xFF16A34A), size: 28),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Riwayat Konsumsi', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 4),
                          Text(data['yesterday_log']['status'], style: const TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIBanner() {
    return GestureDetector(
      onTap: () { if (widget.onNavigate != null) widget.onNavigate!(3); }, // Ke Tab AI Gizi
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)], begin: Alignment.bottomLeft, end: Alignment.topRight),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: Color(0xFFA78BFA), size: 14),
                        SizedBox(width: 6),
                        Text('AI Gizi Anak', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tanya AI Ahli Gizi', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Text('Buat meal plan, resep rumahan, & cek kebutuhan nutrisi harian anak.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2))),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 22),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
      ],
    );
  }
}