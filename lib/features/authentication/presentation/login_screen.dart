import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../guru/presentation/beranda_guru_screen.dart';
import '../../orang_tua/presentation/beranda_ortu_screen.dart';
import '../../kurir/presentation/rute_harian_screen.dart';
import '../../sppg/presentation/dashboard_sppg_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'Guru';
  String? _errorMessage;

  // Data role untuk UI Selector
  final List<Map<String, dynamic>> _roles = [
    {'name': 'Guru', 'icon': Icons.school_rounded},
    {'name': 'Orang Tua', 'icon': Icons.family_restroom_rounded},
    {'name': 'Kurir', 'icon': Icons.electric_moped_rounded},
    {'name': 'SPPG', 'icon': Icons.soup_kitchen_rounded},
  ];

  // --- DATA DUMMY FORMAT JSON ---
  // Mensimulasikan response dari database/API backend
  final String _dummyDatabaseJson = '''
  {
    "users": [
      {
        "role": "Guru",
        "id": "guru@mail.com",
        "password": "guru123",
        "target_route": "/guru/beranda"
      },
      {
        "role": "Orang Tua",
        "id": "ortu@mail.com",
        "password": "ortu123",
        "target_route": "/ortu/beranda"
      },
      {
        "role": "Kurir",
        "id": "kurir@mail.com",
        "password": "kurir123",
        "target_route": "/kurir/rute"
      },
      {
        "role": "SPPG",
        "id": "sppg@mail.com",
        "password": "sppg123",
        "target_route": "/sppg/dashboard"
      }
    ]
  }
  ''';

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulasi jeda network API (1 detik)
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final inputId = _identifierController.text.trim();
    final inputPassword = _passwordController.text;

    // 1. Validasi Input Kosong
    if (inputId.isEmpty || inputPassword.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Oops! Identitas & Password nggak boleh kosong nih ✌️";
      });
      return;
    }

    // 2. Parsing JSON Data
    final Map<String, dynamic> parsedData = jsonDecode(_dummyDatabaseJson);
    final List<dynamic> users = parsedData['users'];

    bool isSuccess = false;
    String routeTarget = '';

    // 3. Pencocokan Data (Validasi)
    for (var user in users) {
      if (user['role'] == _selectedRole && 
          user['id'] == inputId && 
          user['password'] == inputPassword) {
        isSuccess = true;
        routeTarget = user['target_route'];
        break; // Hentikan perulangan jika data sudah cocok
      }
    }

    setState(() => _isLoading = false);

    // 4. Eksekusi Routing
    if (isSuccess) {
      _identifierController.clear();
      _passwordController.clear();

      Widget? targetScreen;
      switch (routeTarget) {
        case '/guru/beranda':
          targetScreen = const GuruMainScreen();
          break;
        case '/ortu/beranda':
          targetScreen = const OrtuMainScreen();
          break;
        case '/kurir/rute':
          targetScreen = const KurirMainScreen();
          break;
        case '/sppg/dashboard':
          targetScreen = const SppgMainScreen();
          break;
      }

      if (targetScreen != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetScreen!),
        );
      } else {
        Navigator.pushReplacementNamed(context, routeTarget);
      }
    } else {
      setState(() {
        _errorMessage = "Akses ditolak! Cek lagi ID, Password, atau Role yang dipilih 🧐";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // --- 1. MESH GRADIENT BACKGROUND ---
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: const BoxDecoration(
                color: Color(0x400EA5E9), // Soft Sky Blue
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: const BoxDecoration(
                color: Color(0x30F59E0B), // Soft Warm Amber
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox(),
            ),
          ),

          // --- 2. KONTEN UTAMA ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: const Icon(Icons.restaurant_menu_rounded, size: 40, color: Color(0xFF0EA5E9)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome to\nMy MBG Gue ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih peranmu untuk mulai beraksi hari ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569).withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- 3. DYNAMIC ROLE SELECTOR ---
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _roles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final role = _roles[index];
                          final isSelected = _selectedRole == role['name'];
                          
                          return GestureDetector(
                            onTap: () => setState(() => _selectedRole = role['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              width: isSelected ? 100 : 85,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0EA5E9) : Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected ? const Color(0xFF0EA5E9).withOpacity(0.4) : Colors.transparent,
                                    blurRadius: isSelected ? 16 : 0,
                                    offset: isSelected ? const Offset(0, 8) : const Offset(0, 0),
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    role['icon'],
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    size: isSelected ? 32 : 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    role['name'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- 4. ERROR SNACKBAR ---
                    if (_errorMessage != null) ...[
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_rounded, color: Color(0xFFEF4444), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // --- 5. GLASSMORPHISM INPUT FIELDS ---
                    _buildGlassTextField(
                      label: 'ID / Username / Email',
                      hint: 'spid3r@mail.com',
                      controller: _identifierController,
                      icon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 20),
                    _buildGlassTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      icon: Icons.lock_outline_rounded,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0EA5E9),
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: const Text(
                          'Lupa Password?',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 6. NEON GLOW CTA BUTTON ---
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      height: 56, 
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Let\'s Go!',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- 7. MODERN QR LOGIN BUTTON ---
                    SizedBox(
                      height: 56,
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF0F172A)),
                        label: const Text(
                          'Scan QR Sekolah',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KUSTOM: Input Field Ala Glassmorphism ---
  Widget _buildGlassTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
              prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 22),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: const Color(0xFF64748B),
                        size: 22,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}