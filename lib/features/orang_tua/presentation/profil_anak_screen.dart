import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

class ProfilAnakView extends StatefulWidget {
  const ProfilAnakView({Key? key}) : super(key: key);

  @override
  State<ProfilAnakView> createState() => _ProfilAnakViewState();
}

class _ProfilAnakViewState extends State<ProfilAnakView> {
  // --- MOCKUP JSON DATA: PROFIL & MEDIS ANAK ---
  final String _dummyChildJson = '''
  {
    "child": {
      "name": "Rayyan Alfarizi",
      "birth_date": "15 Agustus 2017",
      "age": "8 Tahun 10 Bulan",
      "avatar": "https://i.pravatar.cc/150?img=47",
      "blood_type": "A"
    },
    "physical": {
      "height": 132,
      "weight": 28,
      "last_updated": "10 Jun 2026",
      "bmi_status": "Ideal"
    },
    "medical": {
      "history": "Pernah dirawat karena asma ringan pada tahun 2024. Saat ini kondisi stabil dan tidak memerlukan inhaler rutin saat di sekolah.",
      "allergies": [
        {"name": "Seafood", "color": "EF4444"},
        {"name": "Kacang Tanah", "color": "F59E0B"}
      ],
      "doctor_note": {
        "is_uploaded": true,
        "filename": "Surat_Dokter_Alergi_RS_Kasih.pdf",
        "upload_date": "12 Jan 2026"
      }
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
      data = jsonDecode(_dummyChildJson);
      isLoading = false;
    });
  }

  // --- MOCKUP UPDATE DATA BOTTOM SHEET ---
  void _showUpdateDataSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 24),
                const Text('Update Fisik Anak', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                const Text('Perbarui data tinggi dan berat badan secara berkala agar AI Gizi dapat memberikan rekomendasi yang akurat.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
                const SizedBox(height: 24),
                
                // Form Input Mockup
                Row(
                  children: [
                    Expanded(
                      child: _buildInputForm('Tinggi Badan (cm)', data['physical']['height'].toString(), Icons.height_rounded),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputForm('Berat Badan (kg)', data['physical']['weight'].toString(), Icons.monitor_weight_rounded),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Data fisik berhasil diperbarui!'), backgroundColor: Color(0xFF14B8A6), behavior: SnackBarBehavior.floating),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Simpan Pembaruan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputForm(String label, String initialValue, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            initialValue: initialValue,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF14B8A6)));
    }

    return Stack(
      children: [
        // Background Aesthetic (Teal & Sky Blue)
        Positioned(top: -50, right: -100, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x2014B8A6), shape: BoxShape.circle))),
        Positioned(bottom: 100, left: -50, child: Container(width: 250, height: 250, decoration: const BoxDecoration(color: Color(0x200EA5E9), shape: BoxShape.circle))),
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
              title: const Text('Profil & Medis Anak', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
              centerTitle: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 120.0), // Padding bawah hindari navbar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroProfile(),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Data Fisik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                        GestureDetector(
                          onTap: _showUpdateDataSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: const [
                                Icon(Icons.edit_rounded, color: Color(0xFF0EA5E9), size: 14),
                                SizedBox(width: 4),
                                Text('Update', style: TextStyle(color: Color(0xFF0EA5E9), fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPhysicalStats(),
                    
                    const SizedBox(height: 28),
                    const Text('Riwayat Medis & Alergi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    _buildAllergySection(),
                    const SizedBox(height: 16),
                    _buildMedicalHistory(),
                    const SizedBox(height: 16),
                    _buildDoctorNoteSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- KOMPONEN: Hero Profile ---
  Widget _buildHeroProfile() {
    final childData = data['child'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 4),
              image: DecorationImage(image: NetworkImage(childData['avatar']), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          Text(childData['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cake_rounded, color: Color(0xFF64748B), size: 16),
              const SizedBox(width: 6),
              Text(childData['age'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bloodtype_rounded, color: Color(0xFFEF4444), size: 14),
                    const SizedBox(width: 6),
                    Text('Gol. Darah: ${childData['blood_type']}', style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.health_and_safety_rounded, color: Color(0xFF16A34A), size: 14),
                    const SizedBox(width: 6),
                    Text('BMI: ${data['physical']['bmi_status']}', style: const TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN: Data Fisik Bento ---
  Widget _buildPhysicalStats() {
    final physical = data['physical'];
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.height_rounded, color: Color(0xFF0EA5E9), size: 24),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(physical['height'].toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1)),
                    const Padding(padding: EdgeInsets.only(bottom: 2, left: 4), child: Text('cm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Tinggi Badan', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.monitor_weight_rounded, color: Color(0xFFF59E0B), size: 24),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(physical['weight'].toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1)),
                    const Padding(padding: EdgeInsets.only(bottom: 2, left: 4), child: Text('kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Berat Badan', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- KOMPONEN: Alergi ---
  Widget _buildAllergySection() {
    final allergies = data['medical']['allergies'] as List;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 8),
              Text('Pantangan Makanan (Alergi)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C))),
            ],
          ),
          const SizedBox(height: 16),
          if (allergies.isEmpty)
            const Text('Tidak ada riwayat alergi makanan.', style: TextStyle(fontSize: 14, color: Color(0xFF475569)))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergies.map<Widget>((al) {
                Color badgeColor = Color(int.parse("0xFF${al['color']}"));
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: badgeColor.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
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
            ),
        ],
      ),
    );
  }

  // --- KOMPONEN: Riwayat Medis ---
  Widget _buildMedicalHistory() {
    return Container(
      width: double.infinity,
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
                decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.history_edu_rounded, color: Color(0xFF0EA5E9), size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Catatan Medis Umum', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data['medical']['history'],
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN: Surat Dokter ---
  Widget _buildDoctorNoteSection() {
    final note = data['medical']['doctor_note'];
    final bool isUploaded = note['is_uploaded'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5), // Plain border mockup instead of dashed
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.verified_rounded, color: Color(0xFF14B8A6), size: 20),
                  SizedBox(width: 8),
                  Text('Validasi Medis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isUploaded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note['filename'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('Diunggah: ${note['upload_date']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sync_rounded, color: Color(0xFF0EA5E9)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih dokumen baru untuk diunggah.'), backgroundColor: Color(0xFF0EA5E9)));
                    },
                  )
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload Surat Keterangan Dokter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0EA5E9),
                  side: const BorderSide(color: Color(0xFF0EA5E9)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}