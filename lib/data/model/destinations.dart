class destinations {
  final int id;
  final String name;
  final String description;
  final String address;
  final String image;
  final double rating;

  destinations({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.image,
    required this.rating,
  });

  factory destinations.fromJson(Map<String, dynamic> json) {
    return destinations(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      description: json['description'] ?? '',
      address: json['address'] ?? 'Unknown Location',
      image: json['cover_image'] != null
          ? 'http://10.0.2.2:8000/storage/${json['cover_image']}'
          : 'https://via.placeholder.com/150',
      rating: (json['avg_rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'cover_image': image,
      'avg_rating': rating,
    };
  }
}