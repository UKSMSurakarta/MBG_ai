import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

class AIGiziView extends StatefulWidget {
  const AIGiziView({Key? key}) : super(key: key);

  @override
  State<AIGiziView> createState() => _AIGiziViewState();
}

class _AIGiziViewState extends State<AIGiziView> {
  // --- MOCKUP JSON DATA: AI DASHBOARD ---
  final String _dummyAIJson = '''
  {
    "child_context": {
      "name": "Rayyan",
      "age": "8 Tahun",
      "weight": "28 kg",
      "activity": "Aktif",
      "allergy": "Telur, Kacang"
    },
    "analysis": {
      "calories_target": "1600",
      "protein_target": "45g",
      "vitamin_status": "Butuh Vit C Extra",
      "mineral_status": "Kalsium Aman"
    },
    "recommended_recipes": [
      {
        "id": "r1",
        "type": "Sarapan",
        "name": "Pancake Gandum Pisang",
        "calories": 320,
        "protein": "12g",
        "time": "15 mnt",
        "cost": "Rp 15.000",
        "safe_tags": ["Bebas Telur", "Bebas Kacang"]
      },
      {
        "id": "r2",
        "type": "Makan Malam",
        "name": "Sup Salmon Kuah Bening",
        "calories": 410,
        "protein": "28g",
        "time": "30 mnt",
        "cost": "Rp 35.000",
        "safe_tags": ["Bebas Telur", "Omega 3"]
      },
      {
        "id": "r3",
        "type": "Camilan",
        "name": "Smoothie Berry Yoghurt",
        "calories": 180,
        "protein": "8g",
        "time": "5 mnt",
        "cost": "Rp 12.000",
        "safe_tags": ["Bebas Kacang", "Probiotik"]
      }
    ],
    "suggested_prompts": [
      "Menu makan malam tanpa telur?",
      "Camilan untuk tambah berat badan",
      "Cara atasi anak susah makan sayur"
    ]
  }
  ''';

  late Map<String, dynamic> data;
  bool isLoading = true;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      data = jsonDecode(_dummyAIJson);
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  // Aksi Chat AI
  void _submitChat(String prompt) {
    _chatController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('AI sedang menyusun resep untukmu...'),
          ],
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
    }

    return Stack(
      children: [
        // Background Aesthetic (Purple Magic Glow)
        Positioned(top: -100, right: -50, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x308B5CF6), shape: BoxShape.circle))),
        Positioned(bottom: 100, left: -100, child: Container(width: 250, height: 250, decoration: const BoxDecoration(color: Color(0x200EA5E9), shape: BoxShape.circle))),
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
              title: const Text('AI Gizi Assistant', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
              centerTitle: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Konteks Anak
                    _buildContextBadge(),
                    const SizedBox(height: 24),
                    
                    // Chat Input Box
                    _buildAIChatBox(),
                    const SizedBox(height: 28),

                    // Analisis Kebutuhan Nutrisi
                    const Text('Analisis Kebutuhan Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildNutritionAnalysisCard(),

                    const SizedBox(height: 28),

                    // AI Meal Planner
                    const Text('AI Meal Planner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildMealPlannerActions(),

                    const SizedBox(height: 28),

                    // Rekomendasi Resep AI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ide Resep Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Text('Generated by AI', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRecipeList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- KOMPONEN: Badge Konteks Profil ---
  Widget _buildContextBadge() {
    final ctx = data['child_context'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9)), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_search_rounded, color: Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Menyesuaikan Profil Anak:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('${ctx['name']} • ${ctx['age']} • ${ctx['weight']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN: Kotak Chat & Prompt ---
  Widget _buildAIChatBox() {
    final prompts = data['suggested_prompts'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(hintText: 'Tanya gizi atau minta resep...', hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500), border: InputBorder.none),
                  onSubmitted: _submitChat,
                ),
              ),
              GestureDetector(
                onTap: () => _submitChat(_chatController.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Chips Rekomendasi
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: prompts.map((prompt) {
              return GestureDetector(
                onTap: () => _submitChat(prompt),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Text(prompt, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  // --- KOMPONEN: Analisis Bento Card ---
  Widget _buildNutritionAnalysisCard() {
    final analysis = data['analysis'];
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
          Row(
            children: [
              Expanded(child: _buildMetricTile(Icons.local_fire_department_rounded, const Color(0xFFF59E0B), 'Kalori', '${analysis['calories_target']} kcal')),
              Container(width: 1.5, height: 40, color: const Color(0xFFF1F5F9)),
              Expanded(child: _buildMetricTile(Icons.fitness_center_rounded, const Color(0xFF0EA5E9), 'Protein', analysis['protein_target'])),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1.5),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricTile(Icons.medication_rounded, const Color(0xFF14B8A6), 'Vitamin', analysis['vitamin_status'])),
              Container(width: 1.5, height: 40, color: const Color(0xFFF1F5F9)),
              Expanded(child: _buildMetricTile(Icons.water_drop_rounded, const Color(0xFF8B5CF6), 'Mineral', analysis['mineral_status'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }

  // --- KOMPONEN: Meal Planner Actions ---
  Widget _buildMealPlannerActions() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyusun Jadwal 7 Hari...'), backgroundColor: Color(0xFF14B8A6)));
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 100),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                  ),
                  const Text('Buat Jadwal 7 Hari', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daftar belanja PDF sedang disiapkan!'), backgroundColor: Color(0xFF0F172A)));
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 100),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.shopping_cart_checkout_rounded, color: Color(0xFF0F172A), size: 20),
                  ),
                  const Text('Daftar\nBelanja', style: TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w800, height: 1.2)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- KOMPONEN: Resep List ---
  Widget _buildRecipeList() {
    final recipes = data['recommended_recipes'] as List;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
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
                  // Image Placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.restaurant_rounded, color: Color(0xFFCBD5E1), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recipe['type'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0EA5E9))),
                        const SizedBox(height: 4),
                        Text(recipe['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text('${recipe['calories']} kcal', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                            const SizedBox(width: 12),
                            const Icon(Icons.timer_rounded, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(recipe['time'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8,
                    children: (recipe['safe_tags'] as List).map<Widget>((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                        child: Text(tag, style: const TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.w700)),
                      );
                    }).toList(),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membuka resep ${recipe['name']}...'), backgroundColor: const Color(0xFF0F172A)));
                    },
                    child: Row(
                      children: const [
                        Text('Lihat Resep', style: TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w800)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF0F172A), size: 12),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}