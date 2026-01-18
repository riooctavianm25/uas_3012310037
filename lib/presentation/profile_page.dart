import 'package:flutter/material.dart';
import 'package:uas_3012310037/data/model/destinations.dart';
import 'package:uas_3012310037/data/repository/destinations_repository.dart';
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/usecase/response/get_places_response.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late DestinationsRepository _repository;

  @override
  void initState() {
    super.initState();
    final httpService = HttpService();
    _repository = DestinationsRepository(httpService: httpService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
            ),
            const SizedBox(height: 10),
            const Text("User Pengguna", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("user@email.com", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("My Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: FutureBuilder<GetPlacesResponse>(
                future: _repository.getDestinations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.places.isEmpty) {
                    return const Center(child: Text("Belum ada postingan."));
                  }

                  final places = snapshot.data!.places;

                  return ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(place.image, width: 60, height: 60, fit: BoxFit.cover),
                        ),
                        title: Text(place.name),
                        subtitle: Text(place.address),
                        trailing: const Icon(Icons.more_vert),
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