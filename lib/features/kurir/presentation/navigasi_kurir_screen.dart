import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigasiKurirView extends StatefulWidget {
  const NavigasiKurirView({Key? key}) : super(key: key);

  @override
  State<NavigasiKurirView> createState() => _NavigasiKurirViewState();
}

class _NavigasiKurirViewState extends State<NavigasiKurirView> {
  // --- MOCKUP JSON DATA: INFO RUTE ---
  final String _dummyRouteJson = '''
  {
    "route_info": {
      "destination_name": "SDN 01 Surakarta",
      "address": "Jl. Slamet Riyadi No. 123",
      "distance": "5.2 km",
      "eta": "14 Menit",
      "traffic": "Lancar",
      "next_turn": "Belok Kiri ke Jl. Jend. Sudirman",
      "distance_to_turn": "300 meter"
    }
  }
  ''';

  late Map<String, dynamic> routeData;
  bool isLoading = true;
  bool isNavigating = false; // Toggle untuk status navigasi aktif

  // --- GOOGLE MAPS SETUP ---
  final Completer<GoogleMapController> _mapController = Completer();

  // Koordinat Dapur (Start) & Sekolah (End)
  static const LatLng _startLocation = LatLng(-7.5581, 110.8286);
  static const LatLng _endLocation = LatLng(-7.5666, 110.8283);

  // Kamera awal difokuskan di tengah-tengah rute
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-7.5623, 110.8284),
    zoom: 15.0,
  );

  // Marker Setup
  // --- HAPUS KATA 'const' DI DEPAN 'Marker' ---
  final Set<Marker> _markers = {
    Marker( // <-- Tidak ada kata const di sini
      markerId: const MarkerId('start_location'),
      position: _startLocation,
      infoWindow: const InfoWindow(title: 'Dapur SPPG Pusat'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Ini penyebabnya, dia tidak bisa const
    ),
    Marker( // <-- Tidak ada kata const di sini
      markerId: const MarkerId('end_location'),
      position: _endLocation,
      infoWindow: const InfoWindow(title: 'SDN 01 Surakarta'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  };

  // Garis Rute (Polyline Mockup)
  final Set<Polyline> _polylines = {
    const Polyline(
      polylineId: PolylineId('route_1'),
      color: Color(0xFF0EA5E9), // Sky Blue
      width: 5,
      points: [
        LatLng(-7.5581, 110.8286), // Titik 1
        LatLng(-7.5600, 110.8290), // Titik 2
        LatLng(-7.5630, 110.8280), // Titik 3
        LatLng(-7.5650, 110.8285), // Titik 4
        LatLng(-7.5666, 110.8283), // Titik Akhir
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      routeData = jsonDecode(_dummyRouteJson);
      isLoading = false;
    });
  }

  // Fungsi untuk memusatkan kamera kembali ke rute
  Future<void> _recenterMap() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)));
    }

    final info = routeData['route_info'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // --- 1. FULLSCREEN GOOGLE MAPS ---
          Positioned.fill(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            ),
          ),

          // --- 2. TOP FLOATING BAR (Instruksi Arah) ---
          if (isNavigating)
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.9), // Dark Modern
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.turn_left_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(info['distance_to_turn'], style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text(info['next_turn'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // --- 3. MAP CONTROLS (Kanan Tengah) ---
          Positioned(
            right: 20,
            bottom: 240,
            child: Column(
              children: [
                _buildMapFloatingButton(icon: Icons.my_location_rounded, onTap: _recenterMap),
                const SizedBox(height: 12),
                _buildMapFloatingButton(icon: Icons.traffic_rounded, onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Info lalu lintas diaktifkan!'), backgroundColor: Color(0xFF14B8A6)));
                }),
              ],
            ),
          ),

          // --- 4. BOTTOM BENTO CARD (Info Rute & Aksi) ---
          Positioned(
            left: 20,
            right: 20,
            bottom: 110, // Hindari tertimpa Navbar utama kurir
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(info['destination_name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                                const SizedBox(height: 4),
                                Text(info['address'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
                            child: Text(info['traffic'], style: const TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE2E8F0), height: 1),
                      const SizedBox(height: 16),

                      // Metrics
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.timer_rounded, color: Color(0xFF0EA5E9), size: 24),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Estimasi', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                    Text(info['eta'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.route_rounded, color: Color(0xFFF59E0B), size: 24),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Jarak', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                    Text(info['distance'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isNavigating = !isNavigating;
                            });
                            if (isNavigating) _recenterMap();
                          },
                          icon: Icon(isNavigating ? Icons.stop_rounded : Icons.navigation_rounded, color: Colors.white),
                          label: Text(isNavigating ? 'Hentikan Navigasi' : 'Mulai Jalan Sekarang', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isNavigating ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9),
                            elevation: 8,
                            shadowColor: (isNavigating ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9)).withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk tombol kontrol peta
  Widget _buildMapFloatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: const Color(0xFF0F172A), size: 24),
          ),
        ),
      ),
    );
  }
}