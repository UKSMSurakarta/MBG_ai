import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';

// ============================================================================
// 1. HALAMAN UTAMA PROFIL GURU
// ============================================================================
class ProfilGuruScreen extends StatefulWidget {
  const ProfilGuruScreen({Key? key}) : super(key: key);

  @override
  State<ProfilGuruScreen> createState() => _ProfilGuruScreenState();
}

class _ProfilGuruScreenState extends State<ProfilGuruScreen> {
  // --- MOCKUP JSON DATA: PROFIL USER ---
  final String _dummyProfileJson = '''
  {
    "user": {
      "name": "Budi Santoso",
      "nip": "19850723 201001 1 015",
      "role": "Wali Kelas 4A",
      "school": "SDN 01 Surakarta",
      "phone": "0812-3456-7890",
      "email": "budi.santoso@guru.sdn01.id",
      "avatar": "https://i.pravatar.cc/150?img=11"
    },
    "settings": {
      "push_notifications": true,
      "dark_mode": false
    }
  }
  ''';

  late Map<String, dynamic> profileData;
  bool isLoading = true;

  // Local state untuk toggle switch
  bool isNotifEnabled = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final parsedData = jsonDecode(_dummyProfileJson);
    setState(() {
      profileData = parsedData;
      isNotifEnabled = parsedData['settings']['push_notifications'];
      isDarkMode = parsedData['settings']['dark_mode'];
      isLoading = false;
    });
  }

  // Animasi Navigasi ke Halaman Detail di dalam file yang sama
  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
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

    final user = profileData['user'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(top: -50, right: -100, child: Container(width: 300, height: 300, decoration: const BoxDecoration(color: Color(0x208B5CF6), shape: BoxShape.circle))), // Soft Purple
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 60.0,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const Text('Profil Akun', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
                centerTitle: false,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 140.0), // Padding bawah untuk Navbar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 1. HERO HEADER: INFO GURU ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                                image: DecorationImage(image: NetworkImage(user['avatar']), fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(user['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                            const SizedBox(height: 4),
                            Text('${user['role']} • ${user['school']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                              child: Text('NIP: ${user['nip']}', style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w700)),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      const Text('Pengaturan Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 16),

                      // --- 2. MENU BENTO: DATA DIRI & KEAMANAN ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            _buildMenuTile(
                              icon: Icons.person_outline_rounded,
                              iconColor: const Color(0xFF0EA5E9),
                              title: 'Edit Data Diri',
                              subtitle: 'Perbarui nomor HP & Email',
                              onTap: () => _navigateTo(EditProfilScreen(user: user)),
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 64),
                            _buildMenuTile(
                              icon: Icons.lock_outline_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              title: 'Ubah Password',
                              subtitle: 'Ganti kata sandi demi keamanan',
                              onTap: () => _navigateTo(const UbahPasswordScreen()),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Text('Preferensi Sistem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 16),

                      // --- 3. MENU BENTO: PREFERENSI (SWITCHES) ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              icon: Icons.notifications_active_outlined,
                              iconColor: const Color(0xFF14B8A6),
                              title: 'Notifikasi Kurir',
                              subtitle: 'Peringatan saat makanan tiba',
                              value: isNotifEnabled,
                              onChanged: (val) => setState(() => isNotifEnabled = val),
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 64),
                            _buildSwitchTile(
                              icon: Icons.dark_mode_outlined,
                              iconColor: const Color(0xFF8B5CF6),
                              title: 'Mode Gelap (Dark Mode)',
                              subtitle: 'Tampilan ramah mata di malam hari',
                              value: isDarkMode,
                              onChanged: (val) {
                                setState(() => isDarkMode = val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tema gelap akan tersedia di update berikutnya! 🚀'), backgroundColor: Color(0xFF8B5CF6), behavior: SnackBarBehavior.floating),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- 4. TOMBOL LOGOUT ---
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 56),
                        child: TextButton.icon(
                          onPressed: () {
                            // Arahkan kembali ke halaman login global
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                          label: const Text('Keluar Aplikasi', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.w800)),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF2F2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFFECACA))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER: Widget Menu Bisa Di-klik ---
  Widget _buildMenuTile({required IconData icon, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 24),
          ],
        ),
      ),
    );
  }

  // --- HELPER: Widget Menu dengan Toggle Switch ---
  Widget _buildSwitchTile({required IconData icon, required Color iconColor, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: iconColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. HALAMAN DETAIL: EDIT DATA DIRI
// ============================================================================
class EditProfilScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditProfilScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user['phone']);
    _emailController = TextEditingController(text: widget.user['email']);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Data Diri', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Static
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Nama dan NIP hanya dapat diubah melalui admin SPPG Pusat.', style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w600, height: 1.4))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Editable Forms
            _buildGlassInput(label: 'Nomor Handphone (WhatsApp)', controller: _phoneController, icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildGlassInput(label: 'Alamat Email', controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 56),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Data diri berhasil diperbarui!'), backgroundColor: Color(0xFF14B8A6), behavior: SnackBarBehavior.floating));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassInput({required String label, required TextEditingController controller, required IconData icon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 3. HALAMAN DETAIL: UBAH PASSWORD
// ============================================================================
class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({Key? key}) : super(key: key);

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Ubah Password', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildPasswordInput(label: 'Password Lama', isObscured: _obscureOld, onToggle: () => setState(() => _obscureOld = !_obscureOld)),
            const SizedBox(height: 20),
            _buildPasswordInput(label: 'Password Baru', isObscured: _obscureNew, onToggle: () => setState(() => _obscureNew = !_obscureNew)),
            
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 56),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔒 Password berhasil diubah!'), backgroundColor: Color(0xFFF59E0B), behavior: SnackBarBehavior.floating));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B), // Gunakan Amber untuk aksi security
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Update Keamanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordInput({required String label, required bool isObscured, required VoidCallback onToggle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextFormField(
            obscureText: isObscured,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
              suffixIcon: IconButton(
                icon: Icon(isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: const Color(0xFF94A3B8), size: 20),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}