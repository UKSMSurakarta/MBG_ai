import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

// ============================================================================
// 1. HALAMAN UTAMA REKAM MEDIS (LIST & TOGGLE FILTER)
// ============================================================================
class ProfilMedisClassScreen extends StatefulWidget {
  const ProfilMedisClassScreen({Key? key}) : super(key: key);

  @override
  State<ProfilMedisClassScreen> createState() => _ProfilMedisClassScreenState();
}

class _ProfilMedisClassScreenState extends State<ProfilMedisClassScreen> {
  // --- MOCKUP JSON DATA: REKAM MEDIS KELAS ---
  final String _dummyMedicalJson = '''
  {
    "class_info": {
      "name": "Kelas 7 B",
      "total_students": 32,
      "total_allergy": 3
    },
    "students": [
      {
        "id": "7b_01",
        "name": "Ahmad Fadil",
        "has_allergy": false,
        "blood_type": "O",
        "weight": 42,
        "height": 150,
        "allergies": [],
        "medical_history": "Tidak ada riwayat penyakit serius. Anak dalam kondisi sangat sehat."
      },
      {
        "id": "7b_02",
        "name": "Rayyan Alfarizi",
        "has_allergy": true,
        "blood_type": "A",
        "weight": 38,
        "height": 145,
        "allergies": [{"name": "Seafood", "color": "EF4444"}],
        "medical_history": "Memiliki asma ringan jika terlalu kelelahan olahraga. Pantangan mutlak makanan laut."
      },
      {
        "id": "7b_03",
        "name": "Budi Santoso",
        "has_allergy": false,
        "blood_type": "B",
        "weight": 45,
        "height": 152,
        "allergies": [],
        "medical_history": "Pernah dirawat karena tipes tahun lalu. Saat ini sehat."
      },
      {
        "id": "7b_04",
        "name": "Siti Khadijah",
        "has_allergy": true,
        "blood_type": "AB",
        "weight": 40,
        "height": 148,
        "allergies": [{"name": "Kacang", "color": "F59E0B"}],
        "medical_history": "Alergi kacang tingkat sedang. Bisa memicu gatal-gatal di kulit."
      },
      {
        "id": "7b_05",
        "name": "Cinta Kirana",
        "has_allergy": false,
        "blood_type": "O",
        "weight": 41,
        "height": 149,
        "allergies": [],
        "medical_history": "Sehat. Rutin minum vitamin."
      },
      {
        "id": "7b_06",
        "name": "Kevin Wijaya",
        "has_allergy": true,
        "blood_type": "A",
        "weight": 48,
        "height": 155,
        "allergies": [{"name": "Susu Sapi", "color": "EF4444"}, {"name": "Debu", "color": "8B5CF6"}],
        "medical_history": "Intoleransi laktosa tinggi. Perlu susu pengganti (soya/almond)."
      }
    ]
  }
  ''';

  late Map<String, dynamic> classData;
  List<dynamic> allStudents = [];
  bool isLoading = true;

  // State untuk Toggle Slider (false = Semua Anak/Sehat, true = Alergi Saja)
  bool showAllergyOnly = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final parsedData = jsonDecode(_dummyMedicalJson);
    setState(() {
      classData = parsedData;
      allStudents = parsedData['students'];
      isLoading = false;
    });
  }

  void _navigateToDetail(Map<String, dynamic> studentData) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MedicalDetailScreen(studentData: studentData),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)));
    }

    // Filter list berdasarkan toggle
    final displayList = showAllergyOnly 
        ? allStudents.where((s) => s['has_allergy'] == true).toList() 
        : allStudents;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(top: -50, right: -100, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x20F59E0B), shape: BoxShape.circle))),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 80.0,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Rekam Medis ${classData['class_info']['name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text('${classData['class_info']['total_allergy']} anak perlu pantauan khusus', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // --- SLIDING TOGGLE CONTROL ---
                      Container(
                        constraints: const BoxConstraints(minHeight: 52),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => showAllergyOnly = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  decoration: BoxDecoration(
                                    color: !showAllergyOnly ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: !showAllergyOnly ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))] : [],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.health_and_safety_rounded, size: 16, color: !showAllergyOnly ? const Color(0xFF14B8A6) : const Color(0xFF64748B)),
                                        const SizedBox(width: 6),
                                        Text('Semua Siswa', style: TextStyle(color: !showAllergyOnly ? const Color(0xFF0F172A) : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => showAllergyOnly = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  decoration: BoxDecoration(
                                    color: showAllergyOnly ? const Color(0xFFFEF2F2) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(22),
                                    border: showAllergyOnly ? Border.all(color: const Color(0xFFFECACA)) : null,
                                    boxShadow: showAllergyOnly ? [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))] : [],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.warning_rounded, size: 16, color: showAllergyOnly ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
                                        const SizedBox(width: 6),
                                        Text('Alergi Khusus', style: TextStyle(color: showAllergyOnly ? const Color(0xFFB91C1C) : const Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // --- DAFTAR SISWA (Animated Switcher untuk Transisi Halus) ---
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final student = displayList[index];
                      final isAllergy = student['has_allergy'];

                      return GestureDetector(
                        onTap: () => _navigateToDetail(student),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isAllergy ? const Color(0xFFFECACA) : const Color(0xFFF1F5F9), width: isAllergy ? 1.5 : 1),
                            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(color: isAllergy ? const Color(0xFFFEE2E2) : const Color(0xFFF0FDF4), shape: BoxShape.circle),
                                child: Center(
                                  child: Text(student['name'].substring(0, 1), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isAllergy ? const Color(0xFFEF4444) : const Color(0xFF16A34A))),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(student['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    if (isAllergy) 
                                      Wrap(
                                        spacing: 6,
                                        children: (student['allergies'] as List).map<Widget>((al) {
                                          Color badgeColor = Color(int.parse("0xFF${al['color']}"));
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                            child: Text(al['name'], style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w800)),
                                          );
                                        }).toList(),
                                      )
                                    else
                                      Row(
                                        children: const [
                                          Icon(Icons.check_circle_rounded, color: Color(0xFF14B8A6), size: 14),
                                          SizedBox(width: 4),
                                          Text('Sehat Normal', style: TextStyle(color: Color(0xFF14B8A6), fontSize: 12, fontWeight: FontWeight.w600)),
                                        ],
                                      )
                                  ],
                                ),
                              ),
                              // Icon Panah
                              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: displayList.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. HALAMAN DETAIL REKAM MEDIS
// ============================================================================
class MedicalDetailScreen extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const MedicalDetailScreen({Key? key, required this.studentData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAllergy = studentData['has_allergy'];
    final Color themeColor = isAllergy ? const Color(0xFFEF4444) : const Color(0xFF14B8A6);
    final Color bgColor = isAllergy ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Rekam Medis', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- HEADER: FOTO PROFIL & NAMA ---
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: themeColor.withOpacity(0.5), width: 3),
              ),
              child: Center(
                child: Text(studentData['name'].substring(0, 1), style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: themeColor)),
              ),
            ),
            const SizedBox(height: 16),
            Text(studentData['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('ID Siswa: ${studentData['id'].toUpperCase()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            
            const SizedBox(height: 32),

            // --- BENTO GRID: METRIK FISIK ---
            Row(
              children: [
                Expanded(child: _buildPhysicalStatCard('Gol. Darah', studentData['blood_type'], Icons.water_drop_rounded, const Color(0xFFEF4444))),
                const SizedBox(width: 12),
                Expanded(child: _buildPhysicalStatCard('Berat', '${studentData['weight']} kg', Icons.monitor_weight_rounded, const Color(0xFF0EA5E9))),
                const SizedBox(width: 12),
                Expanded(child: _buildPhysicalStatCard('Tinggi', '${studentData['height']} cm', Icons.height_rounded, const Color(0xFFF59E0B))),
              ],
            ),

            const SizedBox(height: 24),

            // --- BENTO CARD: STATUS ALERGI ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isAllergy ? const Color(0xFFFECACA) : const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(isAllergy ? Icons.warning_rounded : Icons.check_circle_rounded, color: themeColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text('Status Pantangan / Alergi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isAllergy ? const Color(0xFFB91C1C) : const Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isAllergy)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (studentData['allergies'] as List).map<Widget>((al) {
                        Color badgeColor = Color(int.parse("0xFF${al['color']}"));
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), border: Border.all(color: badgeColor.withOpacity(0.5)), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.block_rounded, color: badgeColor, size: 14),
                              const SizedBox(width: 6),
                              Text(al['name'], style: TextStyle(color: badgeColor, fontSize: 13, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text('Anak ini tidak memiliki alergi makanan. Porsi normal aman diberikan.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- BENTO CARD: RIWAYAT PENYAKIT (CATATAN DOKTER) ---
            Container(
              width: double.infinity,
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.note_alt_rounded, color: Color(0xFF0EA5E9), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Catatan Medis & Riwayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      studentData['medical_history'],
                      style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.6, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}