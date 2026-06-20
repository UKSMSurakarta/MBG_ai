import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

class ManajemenMenuAiView extends StatefulWidget {
  const ManajemenMenuAiView({Key? key}) : super(key: key);

  @override
  State<ManajemenMenuAiView> createState() => _ManajemenMenuAiViewState();
}

class _ManajemenMenuAiViewState extends State<ManajemenMenuAiView> {
  // --- STATE CONTROL ---
  int _currentTab = 0; // 0: Daftar Menu, 1: AI Generator
  bool isLoading = true;
  bool isGeneratingAI = false;
  bool hasGeneratedAI = false;

  // --- MOCKUP JSON DATA: MANAJEMEN MENU ---
  final String _dummyMenuJson = '''
  [
    {
      "id": "MNU-001",
      "name": "Nasi Tim Ayam Jamur",
      "category": "Makan Siang",
      "calories": 520,
      "protein": "24g",
      "cost": "Rp 12.500",
      "color": "0EA5E9"
    },
    {
      "id": "MNU-002",
      "name": "Sup Makaroni Daging Sapi",
      "category": "Makan Siang",
      "calories": 480,
      "protein": "28g",
      "cost": "Rp 15.000",
      "color": "F59E0B"
    },
    {
      "id": "MNU-003",
      "name": "Pancake Pisang Gandum",
      "category": "Sarapan",
      "calories": 310,
      "protein": "10g",
      "cost": "Rp 8.000",
      "color": "14B8A6"
    }
  ]
  ''';

  late List<dynamic> menuData;

  // Form Controllers untuk AI Generator
  final TextEditingController _budgetController = TextEditingController(text: "15000");
  final TextEditingController _caloriesController = TextEditingController(text: "500");
  final TextEditingController _daysController = TextEditingController(text: "5");

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      menuData = jsonDecode(_dummyMenuJson);
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _caloriesController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _generateAIMenu() async {
    // Validasi input sederhana
    if (_budgetController.text.isEmpty || _caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi parameter budget dan kalori.'), backgroundColor: Color(0xFFEF4444)));
      return;
    }

    setState(() {
      isGeneratingAI = true;
      hasGeneratedAI = false;
    });

    // Simulasi loading AI
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      isGeneratingAI = false;
      hasGeneratedAI = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Aesthetic (Purple AI Glow)
          Positioned(top: -50, right: -100, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x208B5CF6), shape: BoxShape.circle))),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

          Column(
            children: [
              // HEADER & TOGGLE TABS (Fixed at top)
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Manajemen Menu & AI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    const SizedBox(height: 20),
                    Container(
                      constraints: const BoxConstraints(minHeight: 52),
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
                                child: Center(child: Text('Daftar Menu', style: TextStyle(color: _currentTab == 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 13))),
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome_rounded, size: 14, color: _currentTab == 1 ? const Color(0xFF8B5CF6) : const Color(0xFF64748B)),
                                      const SizedBox(width: 6),
                                      Text('AI Generator', style: TextStyle(color: _currentTab == 1 ? const Color(0xFF8B5CF6) : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // SCROLLABLE CONTENT
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _currentTab == 0 ? _buildDaftarMenuTab() : _buildAIGeneratorTab(),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 1: DAFTAR MENU (MANAJEMEN)
  // ==========================================================================
  Widget _buildDaftarMenuTab() {
    return ListView.separated(
      key: const ValueKey('daftar_menu_tab'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120),
      itemCount: menuData.length + 1, // +1 untuk tombol tambah di akhir
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == menuData.length) {
          return Container(
            constraints: const BoxConstraints(minHeight: 56),
            child: OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buka form Tambah Menu Baru'))),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Menu Baru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          );
        }

        final menu = menuData[index];
        final Color accentColor = Color(int.parse("0xFF${menu['color']}"));

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Icon(Icons.fastfood_rounded, color: Color(0xFFCBD5E1), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(menu['category'], style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 6),
                        Text(menu['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF64748B)),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit ${menu['name']}'))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text('${menu['calories']} kcal', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      const Icon(Icons.fitness_center_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(menu['protein'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(menu['cost'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // TAB 2: AI GENERATOR MENU
  // ==========================================================================
  Widget _buildAIGeneratorTab() {
    return SingleChildScrollView(
      key: const ValueKey('ai_generator_tab'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BENTO: Form Input Parameter
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.tune_rounded, color: Color(0xFF8B5CF6), size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text('Parameter AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildInputBox('Budget/Porsi (Rp)', _budgetController, Icons.attach_money_rounded)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputBox('Target Kalori', _caloriesController, Icons.local_fire_department_rounded)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputBox('Durasi Menu (Hari)', _daysController, Icons.date_range_rounded),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 52),
                  child: ElevatedButton.icon(
                    onPressed: isGeneratingAI ? null : _generateAIMenu,
                    icon: isGeneratingAI 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                    label: Text(isGeneratingAI ? 'Menganalisis Komposisi...' : 'Generate Resep Optimal', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      elevation: 8,
                      shadowColor: const Color(0xFF8B5CF6).withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                )
              ],
            ),
          ),

          // HASIL GENERATE (Muncul setelah tombol ditekan)
          if (hasGeneratedAI) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF14B8A6), size: 20),
                const SizedBox(width: 8),
                const Text('Hasil Rekomendasi AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
              ],
            ),
            const SizedBox(height: 16),
            _buildAIResultMockup(),
          ]
        ],
      ),
    );
  }

  Widget _buildInputBox(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              suffixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIResultMockup() {
    return Column(
      children: [
        // Kartu Resep AI
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF14B8A6).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text('Alternatif Bahan Lokal Ditemukan', style: TextStyle(color: Color(0xFF5EEAD4), fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 16),
              const Text('Nasi Liwet Ikan Nila', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('Kombinasi protein ikan nila lokal dan rempah nasi liwet menekan cost hingga Rp 14.500/porsi (Aman alergi kacang).', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8), height: 1.4)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResultStat(Icons.local_fire_department_rounded, '510', 'Kalori'),
                  _buildResultStat(Icons.fitness_center_rounded, '26g', 'Protein'),
                  _buildResultStat(Icons.attach_money_rounded, '14.5K', 'Estimasi'),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Action Buttons Matrix
        Row(
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 50),
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text('Cetak Menu', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 50),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                  label: const Text('Ke Produksi', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildResultStat(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF94A3B8), size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
      ],
    );
  }
}