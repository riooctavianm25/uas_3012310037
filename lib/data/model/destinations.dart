class TourismPlace {
  final String name;
  final String description;
  final String imageUrl;

  TourismPlace({
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory TourismPlace.fromJson(Map<String, dynamic> json) {
    return TourismPlace(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}