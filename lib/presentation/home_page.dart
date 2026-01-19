import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uas_3012310037/data/model/destinations.dart';
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/repository/destinations_repository.dart';
import 'package:uas_3012310037/data/usecase/response/get_places_response.dart';
import 'package:uas_3012310037/presentation/add_place.dart';
import 'package:uas_3012310037/presentation/profile_page.dart';
import 'package:uas_3012310037/presentation/detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DestinationsRepository _repository;
  int _selectedIndex = 0;
  final _searchCtr = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late Future<GetPlacesResponse> _placesFuture;

  final String _currentIp = "192.168.1.4";
  late final String _imageBaseUrl;

  @override
  void initState() {
    super.initState();
    final httpService = HttpService();
    _repository = DestinationsRepository(httpService: httpService);
    _imageBaseUrl = "http://$_currentIp:8000/storage/";
    _placesFuture = _repository.getDestinations();

    _searchCtr.addListener(() {
      setState(() {});
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _placesFuture = _repository.getDestinations();
    });
  }

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
        imageQuality: 50,
      );

      if (photo != null && mounted) {
        bool? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPlacePage(imageFile: photo),
          ),
        );

        if (result == true) {
          _refreshData();
        }
      }
    } catch (e) {
      debugPrint("Error camera: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerSection(),
          const SizedBox(height: 24),
          searchSection(),
          const SizedBox(height: 24),
          const Text(
            "Popular Places",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<GetPlacesResponse>(
              future: _placesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.places.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text("No places found")),
                      ],
                    ),
                  );
                }

                var places = snapshot.data!.places;
                String query = _searchCtr.text.toLowerCase();

                if (query.isNotEmpty) {
                  places = places.where((place) {
                    final nameLower = place.name.toLowerCase();
                    final addressLower = place.address.toLowerCase();
                    return nameLower.contains(query) ||
                        addressLower.contains(query);
                  }).toList();
                }

                if (places.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 50),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 50, color: Colors.grey),
                            const SizedBox(height: 10),
                            Text("No results for '${_searchCtr.text}'",
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshData,
                  color: const Color(0xFF6C63FF),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      String imageUrl;

                      if (place.image.startsWith('http')) {
                        imageUrl =
                            place.image.replaceAll('10.0.2.2', _currentIp);
                      } else {
                        String cleanPath = place.image
                            .replaceAll('public/', '')
                            .replaceAll('storage/', '');
                        imageUrl = _imageBaseUrl + cleanPath;
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailDestinationPage(
                                place: place,
                                imageUrl: imageUrl,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      height: 180,
                                      child: const Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      padding: const EdgeInsets.all(10),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.broken_image,
                                              color: Colors.grey, size: 40),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Gagal memuat:\n$imageUrl",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.red),
                                          ),
                                        ],
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
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      place.address,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      _buildHomeView(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: _openCamera,
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomNavSection(),
    );
  }

  Widget headerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "TripSnap",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Discover amazing places",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget searchSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: _searchCtr,
        decoration: const InputDecoration(
          hintText: "Search destinations...",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget bottomNavSection() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home_filled,
                  color: _selectedIndex == 0
                      ? const Color(0xFF6C63FF)
                      : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.person_outline,
                  color: _selectedIndex == 1
                      ? const Color(0xFF6C63FF)
                      : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}