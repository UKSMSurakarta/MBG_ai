import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // IMPORT PACKAGE GOOGLE MAPS

class LiveTrackingGuruScreen extends StatefulWidget {
  const LiveTrackingGuruScreen({Key? key}) : super(key: key);

  @override
  State<LiveTrackingGuruScreen> createState() => _LiveTrackingGuruScreenState();
}

class _LiveTrackingGuruScreenState extends State<LiveTrackingGuruScreen> {
  // --- MOCKUP JSON DATA: STATUS PENGIRIMAN ---
  final String _dummyTrackingJson = '''
  {
    "order_id": "MBG-20260620-7B",
    "status_code": "on_the_way",
    "eta": "11:15 WIB",
    "courier": {
      "name": "Bagus Satrio",
      "vehicle": "Motor Roda 3 Box Khusus",
      "plate": "AD 4562 XY",
      "avatar": "https://i.pravatar.cc/150?img=60",
      "rating": 4.9
    },
    "timeline": [
      {"title": "Dapur SPPG: Selesai Dimasak", "time": "09:00 WIB", "status": "done"},
      {"title": "Pesanan Di-packing & Quality Control", "time": "10:00 WIB", "status": "done"},
      {"title": "Kurir Mengambil Pesanan", "time": "10:30 WIB", "status": "done"},
      {"title": "Sedang Menuju Sekolah", "time": "10:45 WIB", "status": "active"},
      {"title": "Tiba di SDN 01 Surakarta", "time": "Estimasi 11:15 WIB", "status": "pending"}
    ]
  }
  ''';

  late Map<String, dynamic> trackData;
  bool isLoading = true;

  // --- GOOGLE MAPS CONTROLLER & SETUP ---
  final Completer<GoogleMapController> _mapController = Completer();

  // Koordinat Awal: Kota Surakarta (Solo)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-7.5666, 110.8283),
    zoom: 14.5,
  );

  // Set Penanda (Markers) di Peta
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('courier_location'),
      position: LatLng(-7.5600, 110.8210), // Koordinat Dummy Kurir (Jalan Slamet Riyadi)
      infoWindow: InfoWindow(title: 'Kurir SPPG', snippet: 'AD 4562 XY'),
      // Nanti bisa diganti icon custom motor pakai BitmapDescriptor
    ),
    const Marker(
      markerId: MarkerId('school_location'),
      position: LatLng(-7.5666, 110.8283), // Koordinat SDN 01 Surakarta
      infoWindow: InfoWindow(title: 'SDN 01 Surakarta', snippet: 'Tujuan Pengiriman'),
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 600)); 
    setState(() {
      trackData = jsonDecode(_dummyTrackingJson);
      isLoading = false;
    });
  }

  // --- MODAL: TAMPILKAN QR CODE SERAH TERIMA ---
  void _showQRCodeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 6, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                const Text('Scan Untuk Menerima', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                const Text('Tunjukkan barcode ini kepada kurir sebagai bukti serah terima makanan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                const SizedBox(height: 32),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF0EA5E9), width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, size: 200, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                Text('ID: ${trackData['order_id']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 56),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Tutup', style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Color(0xFFF8FAFC), body: Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white.withOpacity(0.7),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
              ),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // --- 1. GOOGLE MAPS ASLI (Setengah Layar Atas) ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              markers: _markers,
              myLocationEnabled: true, // Opsional: Tampilkan lokasi HP saat ini
              zoomControlsEnabled: false, // Matikan tombol zoom default agar UI tetap bersih
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            ),
          ),

          // --- 2. BOTTOM SHEET INFO (Melengkung ke atas) ---
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4 - 30,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Estimasi Tiba', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              Text(trackData['eta'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0EA5E9), letterSpacing: -1)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(16)),
                            child: const Text('Sedang Di Jalan', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w800, fontSize: 12)),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      _buildCourierInfoCard(),
                      
                      const SizedBox(height: 32),
                      const Text('Detail Perjalanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 16),
                      _buildTimeline(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // --- 3. FLOATING ACTION BUTTON ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          child: ElevatedButton.icon(
            onPressed: _showQRCodeModal,
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
            label: const Text('Tampilkan Barcode Serah Terima', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              elevation: 10,
              shadowColor: const Color(0xFF0F172A).withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourierInfoCard() {
    final courier = trackData['courier'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(courier['avatar']), fit: BoxFit.cover)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courier['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${courier['vehicle']} • ${courier['plate']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 4),
                    Text('${courier['rating']} Penilaian', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
                  ],
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.phone_rounded, color: Color(0xFF16A34A), size: 24),
          )
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final List timelineData = trackData['timeline'];
    return Column(
      children: List.generate(timelineData.length, (index) {
        final step = timelineData[index];
        final bool isDone = step['status'] == 'done';
        final bool isActive = step['status'] == 'active';
        final bool isLast = index == timelineData.length - 1;

        Color dotColor = const Color(0xFFE2E8F0);
        if (isDone) dotColor = const Color(0xFF14B8A6); 
        if (isActive) dotColor = const Color(0xFF0EA5E9); 

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : dotColor,
                    shape: BoxShape.circle,
                    border: isActive ? Border.all(color: dotColor, width: 4) : null,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 40, color: isDone ? const Color(0xFF14B8A6) : const Color(0xFFE2E8F0)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isDone || isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(step['time'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}