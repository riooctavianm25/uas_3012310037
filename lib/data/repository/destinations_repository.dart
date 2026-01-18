import 'dart:convert';
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/usecase/response/get_places_response.dart';

class DestinationsRepository {
  final HttpService httpService;

  DestinationsRepository({required this.httpService});

  Future<GetPlacesResponse> getDestinations({int page = 1}) async {
    final response = await httpService.get('destinations', {'page': page.toString()});
    return GetPlacesResponse.fromJson(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> getDestinationDetail(int id) async {
    final response = await httpService.get('destinations/$id', {});
    return jsonDecode(response.body);
  }

  Future<GetPlacesResponse> searchDestinations(String query) async {
    final response = await httpService.get('destinations', {'search': query});
    return GetPlacesResponse.fromJson(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> getUserFavorites() async {
    final response = await httpService.get('favorites', {});
    return jsonDecode(response.body);
  }

  Future<void> addFavorite(int destinationId) async {
    await httpService.post('favorites', {'destination_id': destinationId});
  }

  Future<void> removeFavorite(int destinationId) async {
    await httpService.delete('favorites/$destinationId');
  }

  Future<void> submitReview(int destinationId, Map<String, dynamic> reviewData) async {
    final data = {
      'destination_id': destinationId,
      ...reviewData,
    };
    await httpService.post('reviews', data);
  }

  Future<Map<String, dynamic>> getReviews(int destinationId) async {
    final response = await httpService.get('reviews', {'destination_id': destinationId.toString()});
    return jsonDecode(response.body);
  }
}