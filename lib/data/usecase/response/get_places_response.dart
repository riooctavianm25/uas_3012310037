import 'package:uas_3012310037/data/model/destinations.dart';

class GetPlacesResponse {
  final List<destinations> places;

  GetPlacesResponse({required this.places});

  factory GetPlacesResponse.fromJson(Map<String, dynamic> json) {
    List<destinations> places = [];

    var data = json['data'];

    if (data != null) {
      if (data is List) {
        places = data.map((e) => destinations.fromJson(e)).toList();
      } else if (data is Map<String, dynamic> && data['data'] != null && data['data'] is List) {
        places = (data['data'] as List).map((e) => destinations.fromJson(e)).toList();
      }
    }

    return GetPlacesResponse(places: places);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': places.map((place) => place.toJson()).toList(),
    };
  }
}