import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';


import 'absensi_digital_screen.dart';
import 'profil_medis_screen.dart';
import 'profil_guru_screen.dart';
import 'live_tracking_guru_screen.dart';
import 'laporan_guru_screen.dart';

// ============================================================================
// 1. MAIN LAYOUT (CANGKANG NAVBAR)
// ============================================================================
class GuruMainScreen extends StatefulWidget {
  const GuruMainScreen({Key? key}) : super(key: key);

  @override
  State<GuruMainScreen> createState() => _GuruMainScreenState();
}

class _GuruMainScreenState extends State<GuruMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

@override
  void initState() {
    super.initState();
    _pages = [
      // Index 0: Beranda (Menyambungkan fungsi pindah tab)
      BerandaGuruView(
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      // Index 1: Halaman Absensi Asli
      const AbsensiDigitalScreen(),
      
      // Index 2: Halaman Rekam Medis (Hapus kata 'const' dan gunakan nama yang benar)
      ProfilMedisClassScreen(), 
      
      // Index 3: Profil Guru
      const ProfilGuruScreen(),
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
      extendBody: true, // Konten membayang di balik navbar
      
      // Animasi transisi antar tab
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

  // --- WIDGET NAVBAR GLASSMORPHISM ---
  Widget _buildGlassNavbar() {
    final List<Map<String, dynamic>> navItems = [
      {'label': 'Beranda', 'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded, 'color': const Color(0xFF0EA5E9)},
      {'label': 'Absensi', 'icon': Icons.fact_check_outlined, 'activeIcon': Icons.fact_check_rounded, 'color': const Color(0xFF14B8A6)},
      {'label': 'Medis', 'icon': Icons.medical_information_outlined, 'activeIcon': Icons.medical_information_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Profil', 'icon': Icons.person_outline_rounded, 'activeIcon': Icons.person_rounded, 'color': const Color(0xFF8B5CF6)},
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            )
          ],
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
                          Icon(
                            isSelected ? item['activeIcon'] : item['icon'],
                            color: isSelected ? color : const Color(0xFF94A3B8),
                            size: 24,
                          ),
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
// 2. KONTEN BERANDA GURU
// ============================================================================
class BerandaGuruView extends StatefulWidget {
  // Parameter ini yang sebelumnya hilang/salah tempat
  final Function(int)? onNavigateToTab; 

  const BerandaGuruView({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  State<BerandaGuruView> createState() => _BerandaGuruViewState();
}

class _BerandaGuruViewState extends State<BerandaGuruView> {
  final String _dummyJsonResponse = '''
  {
    "user": {
      "name": "Budi Santoso",
      "role": "Wali Kelas 4A",
      "school": "SDN 01 Surakarta"
    },
    "todayMenu": {
      "title": "Nasi Tim Ayam Jamur",
      "subtitle": "Susu UHT & Buah Pisang",
      "calories": 520,
      "protein": 24
    },
    "delivery": {
      "status": "Sedang Di Jalan",
      "eta": "11:15 WIB",
      "progress": 0.65
    },
    "classSummary": {
      "present": 28,
      "total": 30,
      "special_portions": 3,
      "allergies": [
        {"name": "2 Seafood", "color": "EF4444"},
        {"name": "1 Kacang", "color": "F59E0B"}
      ]
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
      data = jsonDecode(_dummyJsonResponse);
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
        Positioned(
          top: -150,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(color: Color(0x200EA5E9), shape: BoxShape.circle),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox()),
        ),

        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(data['user']),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 140.0), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuBanner(data['todayMenu']),
                    const SizedBox(height: 28),
                    
                    const Text('Akses Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    
                    const SizedBox(height: 28),
                    _buildDeliveryStatus(data['delivery']),
                    
                    const SizedBox(height: 28),
                    _buildClassSummary(data['classSummary']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> user) {
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
                  Text(
                    'Halo, Pak ${user['name'].split(' ')[0]}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user['role']} • ${user['school']}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?img=11'), fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBanner(Map<String, dynamic> menu) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text('Menu Hari Ini', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  menu['title'],
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.2),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(menu['subtitle'], style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildNutrientIcon(Icons.local_fire_department_rounded, '${menu['calories']} kkal'),
                    const SizedBox(width: 16),
                    _buildNutrientIcon(Icons.fitness_center_rounded, '${menu['protein']}g Protein'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: const Icon(Icons.set_meal_rounded, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFCD34D), size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () {
              // TRIGGER: Geser ke tab Absensi (Index 1)
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(1);
              }
            },
            child: _buildActionCard(140, const Color(0xFF14B8A6), Icons.fact_check_rounded, 'Absensi\nDigital', 'Check-in kelas', false),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
  flex: 4,
  child: Column(
    children: [
      // --- TOMBOL LIVE TRACK DI SINI ---
      GestureDetector(
        onTap: () {
          // Push (Menumpuk) ke halaman Live Tracking secara full screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LiveTrackingGuruScreen()),
          );
        },
        child: _buildActionCard(62, Colors.white, Icons.map_rounded, 'Live Track', null, true, iconColor: const Color(0xFF0EA5E9)),
      ),
      const SizedBox(height: 16),

      // Tombol Laporan
      GestureDetector(
  onTap: () {
    // Navigasi push ke halaman Laporan (Pusat Bantuan)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LaporanGuruScreen()),
    );
  },
  child: _buildActionCard(62, Colors.white, Icons.report_problem_rounded, 'Laporan', null, true, iconColor: const Color(0xFFEF4444)),
),
    ],
  ),
),
      ],
    );
  }

  Widget _buildActionCard(double minHeight, Color color, IconData icon, String title, String? subtitle, bool isLight, {Color? iconColor}) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: isLight ? Border.all(color: const Color(0xFFF1F5F9)) : null,
        boxShadow: isLight ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))] : [],
      ),
      child: minHeight > 100
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.1)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                    ]
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
    );
  }

  Widget _buildDeliveryStatus(Map<String, dynamic> delivery) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
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
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.electric_moped_rounded, color: Color(0xFFF59E0B), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Status Kurir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20)),
                child: Text(delivery['status'], style: const TextStyle(color: Color(0xFFD97706), fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Color(0xFF64748B), size: 18),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  text: 'Estimasi Tiba: ',
                  style: const TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter', fontSize: 13),
                  children: [TextSpan(text: delivery['eta'], style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800))],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: delivery['progress'],
                child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(4))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassSummary(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Kelas Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.people_alt_rounded, color: Color(0xFF16A34A)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hadir', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                          Text('${summary['present']}/${summary['total']} Siswa', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.medical_information_rounded, color: Color(0xFFEF4444)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Porsi Khusus', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                          Text('${summary['special_portions']} Anak', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (summary['allergies'] as List).map<Widget>((allergy) {
              Color badgeColor = Color(int.parse("0xFF${allergy['color']}"));
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  border: Border.all(color: badgeColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_rounded, color: badgeColor, size: 14),
                    const SizedBox(width: 6),
                    Text(allergy['name'], style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}