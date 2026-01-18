import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uas_3012310037/data/model/destinations.dart';
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/repository/destinations_repository.dart';
import 'package:uas_3012310037/data/usecase/response/get_places_response.dart';
import 'package:uas_3012310037/presentation/add_place.dart';



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

  @override
  void initState() {
    super.initState();
    final httpService = HttpService();
    _repository = DestinationsRepository(httpService: httpService);
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
        imageQuality: 50,
      );

      if (photo != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPlacePage(imageFile: photo),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerSection(),
              const SizedBox(height: 24),
              searchSection(),
            ],
          ),
        ),
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
              icon: Icon(Icons.home_filled, color: _selectedIndex == 0 ? const Color(0xFF6C63FF) : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.search, color: _selectedIndex == 1 ? const Color(0xFF6C63FF) : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.favorite_border, color: _selectedIndex == 2 ? const Color(0xFF6C63FF) : Colors.grey),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(Icons.person_outline, color: _selectedIndex == 3 ? const Color(0xFF6C63FF) : Colors.grey),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}