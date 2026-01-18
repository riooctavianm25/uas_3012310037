import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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

  Future<bool> addDestination(File image, String name, String desc, String address) async {
    try {
      var uri = Uri.parse('http://10.0.2.2:8000/api/destinations');
      
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = name;
      request.fields['description'] = desc;
      request.fields['address'] = address;
      request.fields['avg_rating'] = '4.5';

      var pic = await http.MultipartFile.fromPath("cover_image", image.path);
      request.files.add(pic);

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final respStr = await response.stream.bytesToString();
        print("Upload failed: ${response.statusCode} - $respStr");
        return false;
      }
    } catch (e) {
      print("Error upload: $e");
      return false;
    }
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