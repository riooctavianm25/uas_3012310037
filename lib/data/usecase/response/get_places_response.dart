import 'package:uas_3012310037/data/model/tourism_place.dart';

class GetPlacesResponse {
  final List<TourismPlace> places;

  GetPlacesResponse({required this.places});

  factory GetPlacesResponse.fromJson(Map<String, dynamic> json) {
    List<TourismPlace> places = [];
    if (json['places'] != null) {
      places = (json['places'] as List)
          .map((place) => TourismPlace.fromJson(place))
          .toList();
    }
    return GetPlacesResponse(places: places);
  }

  Map<String, dynamic> toJson() {
    return {
      'places': places.map((place) => place.toJson()).toList(),
    };
  }
}