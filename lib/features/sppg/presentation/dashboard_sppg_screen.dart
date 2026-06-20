import 'dart:ui';
import 'package:flutter/material.dart';
import 'produksi_dapur_screen.dart';
import 'inventory_mobile_screen.dart';
import 'manajemen_menu_ai_screen.dart';

// ============================================================================
// 1. MAIN LAYOUT (CANGKANG NAVBAR SPPG)
// ============================================================================
class SppgMainScreen extends StatefulWidget {
  const SppgMainScreen({Key? key}) : super(key: key);

  @override
  State<SppgMainScreen> createState() => _SppgMainScreenState();
}

class _SppgMainScreenState extends State<SppgMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardSppgView(onNavigate: (index) => setState(() => _currentIndex = index)),
      const ProduksiDapurView(),
      const InventoryMobileView(),
      const ManajemenMenuAiView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true,
      
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.02, 0.0), end: Offset.zero).animate(animation),
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
      {'label': 'Beranda', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard_rounded, 'color': const Color(0xFF0EA5E9)},
      {'label': 'Produksi', 'icon': Icons.soup_kitchen_outlined, 'activeIcon': Icons.soup_kitchen_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Gudang', 'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2_rounded, 'color': const Color(0xFF14B8A6)},
      {'label': 'Menu & AI', 'icon': Icons.restaurant_menu_rounded, 'activeIcon': Icons.restaurant_rounded, 'color': const Color(0xFF8B5CF6)},
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
              color: Colors.white.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = _currentIndex == index;
                  final color = item['color'] as Color;

                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
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
                            duration: const Duration(milliseconds: 300),
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
// 2. KONTEN: DASHBOARD SPPG (BERANDA)
// ============================================================================
class DashboardSppgView extends StatelessWidget {
  final Function(int)? onNavigate;
  const DashboardSppgView({Key? key, this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -80, left: -80, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x2014B8A6), shape: BoxShape.circle))),
        Positioned(bottom: 100, right: -100, child: Container(width: 250, height: 250, decoration: const BoxDecoration(color: Color(0x200EA5E9), shape: BoxShape.circle))),
        Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCriticalAlerts(),
                      const SizedBox(height: 24),
                      
                      _buildProductionHero(context),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _buildTodayMenuBento(context)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFleetStatusBento()),
                        ],
                      ),
                      const SizedBox(height: 28),

                      const Text('Modul Khusus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                      const SizedBox(height: 16),
                      _buildSpecialModulesGrid(context),
                      
                      const SizedBox(height: 120), // Spacing Navbar
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

  Widget _buildSliverAppBar(BuildContext context) {
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
                children: const [
                  Text('Halo, Kepala Dapur', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                  SizedBox(height: 4),
                  Text('SPPG Pusat Surakarta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE2E8F0), width: 2), image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?img=33'), fit: BoxFit.cover)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalAlerts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFECACA))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Stok Telur Menipis', style: TextStyle(color: Color(0xFFB91C1C), fontSize: 14, fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('Sisa 2 tray di gudang. Segera restock via sistem.', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionHero(BuildContext context) {
    const int totalTarget = 2500;
    const int finished = 1850;
    const double progress = finished / totalTarget;

    return GestureDetector(
      onTap: () { if (onNavigate != null) onNavigate!(1); }, // Navigasi ke tab Produksi
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.soup_kitchen_rounded, color: Colors.white, size: 20)),
                    const SizedBox(width: 12),
                    const Text('Target Hari Ini', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF14B8A6).withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('Sedang Memasak', style: TextStyle(color: Color(0xFF5EEAD4), fontSize: 11, fontWeight: FontWeight.w700)))
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text('1850', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -2, height: 1)),
                Padding(padding: EdgeInsets.only(bottom: 6.0, left: 4.0), child: Text('/ 2500 Porsi', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(height: 8, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)]), borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 2))])),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('74% Selesai dipacking • Estimasi selesai 10:30 WIB', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMenuBento(BuildContext context) {
    return GestureDetector(
      onTap: () { if (onNavigate != null) onNavigate!(3); }, // Navigasi ke tab Menu
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFFD97706), size: 24)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Menu Masak', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Nasi Tim\nAyam Jamur', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800, height: 1.2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetStatusBento() {
    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.electric_moped_rounded, color: Color(0xFF16A34A), size: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Armada Kurir', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('12', style: TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900, height: 1)),
                  Padding(padding: EdgeInsets.only(bottom: 2.0, left: 2.0), child: Text('/15', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w700))),
                ],
              ),
              const Text('Sedang Jalan', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialModulesGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildModuleCard(
            title: 'Monitoring\nAlergi Anak',
            icon: Icons.health_and_safety_rounded,
            color: const Color(0xFFEF4444),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka daftar pantangan sekolah...'))),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModuleCard(
            title: 'Quality\nControl (QC)',
            icon: Icons.fact_check_rounded,
            color: const Color(0xFF14B8A6),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka form validasi suhu & higienitas...'))),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9)), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 26)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w800, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

