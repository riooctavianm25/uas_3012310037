import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_3012310037/data/repository/destinations_repository.dart';
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/usecase/response/get_places_response.dart';
import 'package:uas_3012310037/presentation/login_page.dart'; // Pastikan import halaman login Anda

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late DestinationsRepository _repository;
  
  // Default values
  String _name = "Loading...";
  String _email = "Loading...";
  
  // Ganti IP sesuai laptop
  final String _currentIp = "192.168.1.4"; 
  late final String _imageBaseUrl;

  @override
  void initState() {
    super.initState();
    final httpService = HttpService();
    _repository = DestinationsRepository(httpService: httpService);
    _imageBaseUrl = "http://$_currentIp:8000/storage/";
    
    // Panggil fungsi load saat halaman dibuka
    _loadUserProfile();
  }

  // Fungsi untuk mengambil data dari SharedPreferences
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Mengambil data yang disimpan saat Login
      _name = prefs.getString('name') ?? "Guest User";
      _email = prefs.getString('email') ?? "guest@email.com";
    });
  }

  // Fungsi Logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data login
    
    if (!mounted) return;
    
    // Arahkan kembali ke halaman Login (Sesuaikan nama class Login page Anda)
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    
    // Atau tampilkan snackbar jika belum ada halaman login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil Logout")),
    );
    
    setState(() {
       _name = "Guest User";
       _email = "guest@email.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Tombol Logout di pojok kanan atas
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar Placeholder
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
              child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : "G",
                style: const TextStyle(fontSize: 40, color: Color(0xFF6C63FF)),
              ),
            ),
            const SizedBox(height: 16),
            // Nama User
            Text(
              _name,
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 8),
            // Email User
            Text(
              _email,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 1, indent: 20, endIndent: 20),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "My Recent Posts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // List Postingan
            Expanded(
              child: FutureBuilder<GetPlacesResponse>(
                future: _repository.getDestinations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.places.isEmpty) {
                    return const Center(child: Text("Belum ada postingan."));
                  }

                  // Ambil data dan reverse agar yang terbaru di atas
                  final places = snapshot.data!.places.reversed.toList();

                  return ListView.builder(
                    itemCount: places.length,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    itemBuilder: (context, index) {
                      final place = places[index];
                      
                      String imageUrl;
                      if (place.image.startsWith('http')) {
                        imageUrl = place.image.replaceAll('10.0.2.2', _currentIp);
                      } else {
                        String cleanPath = place.image
                            .replaceAll('public/', '')
                            .replaceAll('storage/', '');
                        imageUrl = _imageBaseUrl + cleanPath;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 180,
                                    child: const Center(child: CircularProgressIndicator()),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 180,
                                    width: double.infinity,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    place.address,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}