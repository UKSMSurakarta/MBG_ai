import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

// ============================================================================
// 1. HALAMAN UTAMA (DAFTAR KELAS & KELOMPOK ALERGI)
// ============================================================================
class AbsensiDigitalScreen extends StatefulWidget {
  const AbsensiDigitalScreen({Key? key}) : super(key: key);

  @override
  State<AbsensiDigitalScreen> createState() => _AbsensiDigitalScreenState();
}

class _AbsensiDigitalScreenState extends State<AbsensiDigitalScreen> {
  // --- MOCKUP JSON DATA: DAFTAR KELAS ---
  final String _dummyClassesJson = '''
  {
    "allergy_group": {
      "id": "alergi_all",
      "name": "Kelas Porsi Khusus",
      "description": "Gabungan anak alergi 7A - 9C",
      "total_students": 12,
      "color": "EF4444"
    },
    "regular_classes": [
      {"id": "7a", "name": "Kelas 7 A", "total_students": 32, "color": "0EA5E9"},
      {"id": "7b", "name": "Kelas 7 B", "total_students": 30, "color": "0EA5E9"},
      {"id": "8a", "name": "Kelas 8 A", "total_students": 34, "color": "14B8A6"},
      {"id": "8b", "name": "Kelas 8 B", "total_students": 32, "color": "14B8A6"},
      {"id": "9a", "name": "Kelas 9 A", "total_students": 28, "color": "8B5CF6"},
      {"id": "9b", "name": "Kelas 9 B", "total_students": 30, "color": "8B5CF6"}
    ]
  }
  ''';

  late Map<String, dynamic> classData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      classData = jsonDecode(_dummyClassesJson);
      isLoading = false;
    });
  }

  void _navigateToDetail(Map<String, dynamic> data, bool isAllergyMode) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AbsensiDetailScreen(
          classData: data,
          isAllergyMode: isAllergyMode,
        ),
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

    final allergyGroup = classData['allergy_group'];
    final regularClasses = classData['regular_classes'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x200EA5E9), shape: BoxShape.circle))),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
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
                      children: const [
                        Text('Pilih Kelas Absensi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                        SizedBox(height: 4),
                        Text('Ketuk kartu untuk memulai check-in', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToDetail(allergyGroup, true),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFB91C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.medical_information_rounded, color: Colors.white, size: 24),
                                  ),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 20),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(allergyGroup['name'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Text(allergyGroup['description'], style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                child: Text('${allergyGroup['total_students']} Anak Dipantau', style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12, fontWeight: FontWeight.w800)),
                              )
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      const Text('Kelas Reguler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cls = regularClasses[index];
                      final baseColor = Color(int.parse("0xFF${cls['color']}"));
                      
                      return GestureDetector(
                        onTap: () => _navigateToDetail(cls, false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: baseColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.meeting_room_rounded, color: baseColor, size: 24),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cls['name'], style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('Total: ${cls['total_students']} Murid', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: regularClasses.length,
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
// 2. HALAMAN DETAIL (DAFTAR ANAK + PENCARIAN)
// ============================================================================
class AbsensiDetailScreen extends StatefulWidget {
  final Map<String, dynamic> classData;
  final bool isAllergyMode;

  const AbsensiDetailScreen({Key? key, required this.classData, required this.isAllergyMode}) : super(key: key);

  @override
  State<AbsensiDetailScreen> createState() => _AbsensiDetailScreenState();
}

class _AbsensiDetailScreenState extends State<AbsensiDetailScreen> {
  List<dynamic> studentsList = [];
  List<dynamic> filteredStudents = []; // State khusus untuk hasil pencarian
  
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  int totalHadir = 0;
  int totalAbsen = 0;

  @override
  void initState() {
    super.initState();
    _fetchStudentsMock();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchStudentsMock() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    int count = widget.classData['total_students'];
    List<dynamic> dummyStudents = List.generate(count, (index) {
      bool isHadir = index % 5 != 0;
      return {
        "id": "${widget.classData['id']}_${index + 1}",
        "name": widget.isAllergyMode ? "Anak Alergi ${index + 1}" : "Siswa Reguler ${index + 1}",
        "status": isHadir ? "hadir" : "absen",
        "allergy_note": widget.isAllergyMode ? (index % 2 == 0 ? "Seafood" : "Kacang") : "",
      };
    });

    setState(() {
      studentsList = dummyStudents;
      filteredStudents = List.from(studentsList); // Inisialisasi daftar yang ditampilkan
      _calculateAttendance();
      isLoading = false;
    });
  }

  void _calculateAttendance() {
    totalHadir = studentsList.where((s) => s['status'] == 'hadir').length;
    totalAbsen = studentsList.where((s) => s['status'] == 'absen').length;
  }

  // Logika pencarian Real-Time
  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents = List.from(studentsList);
      } else {
        filteredStudents = studentsList.where((student) {
          final nameLower = student['name'].toString().toLowerCase();
          final idLower = student['id'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return nameLower.contains(searchLower) || idLower.contains(searchLower);
        }).toList();
      }
    });
  }

  // Toggle absen menggunakan pencocokan ID agar pencarian dan data utama tetap sinkron
  void _toggleAttendance(String studentId) {
    setState(() {
      final index = studentsList.indexWhere((s) => s['id'] == studentId);
      if (index != -1) {
        studentsList[index]['status'] = studentsList[index]['status'] == 'hadir' ? 'absen' : 'hadir';
        _calculateAttendance();
        _filterStudents(_searchController.text); // Refresh hasil pencarian
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isAllergyMode ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC);
    final themeColor = widget.isAllergyMode ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(widget.classData['name'], style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800)),
            Text('${widget.classData['total_students']} Murid', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : Column(
              children: [
                // 1. Metrik Hadir / Absen
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                  child: Row(
                    children: [
                      Expanded(child: _buildMetricCard(totalHadir.toString(), 'Hadir', const Color(0xFF14B8A6), Icons.how_to_reg_rounded)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMetricCard(totalAbsen.toString(), 'Tidak Hadir', const Color(0xFFF59E0B), Icons.person_off_rounded)),
                    ],
                  ),
                ),
                
                // 2. Kolom Pencarian (Search Bar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterStudents,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau ID murid...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8), size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterStudents('');
                                  FocusScope.of(context).unfocus(); // Tutup keyboard saat dihapus
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                
                // 3. Daftar Siswa
                Expanded(
                  child: filteredStudents.isEmpty 
                    ? const Center(
                        child: Text('Murid tidak ditemukan 🧐', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w600)),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                        itemCount: filteredStudents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          final isPresent = student['status'] == 'hadir';

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isPresent ? themeColor.withOpacity(0.3) : const Color(0xFFE2E8F0)),
                              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: isPresent ? themeColor.withOpacity(0.1) : const Color(0xFFF1F5F9), shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(student['name'].substring(0, 1), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isPresent ? themeColor : const Color(0xFF64748B))),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(student['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                                      if (widget.isAllergyMode) ...[
                                        const SizedBox(height: 2),
                                        Text('Pantangan: ${student['allergy_note']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                                      ] else ...[
                                        const SizedBox(height: 2),
                                        Text('ID: ${student['id'].toUpperCase()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
                                      ]
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _toggleAttendance(student['id']), // MENGGUNAKAN ID, BUKAN INDEX LAGI
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isPresent ? themeColor : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isPresent ? 'Hadir' : 'Absen',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isPresent ? Colors.white : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading ? null : FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context); // Kembali ke menu utama
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Absensi ${widget.classData['name']} tersimpan!'),
              backgroundColor: const Color(0xFF14B8A6),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: themeColor,
        elevation: 8,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        label: const Text('Konfirmasi Data', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }

  Widget _buildMetricCard(String count, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color, height: 1)),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}