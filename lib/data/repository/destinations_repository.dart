import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_3012310037/data/model/review.dart';
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
      var uri = Uri.parse('http://192.168.1.4:8000/api/destinations');
      
      var request = http.MultipartRequest('POST', uri);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      request.fields['description'] = desc;
      request.fields['address'] = address;
      request.fields['latitude'] = '0.0';
      request.fields['longitude'] = '0.0';
      request.fields['avg_rating'] = '0.0';

      var pic = await http.MultipartFile.fromPath("cover_image", image.path);
      request.files.add(pic);

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitReview(int destinationId, double rating, String review) async {
    try {
      final data = {
        'destination_id': destinationId,
        'rating': rating,
        'review': review,
      };
      
      final response = await httpService.post('reviews', data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<Review>> getReviews(int destinationId) async {
    try {
      final response = await httpService.get('reviews', {'destination_id': destinationId.toString()});
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['data'] != null) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => Review.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateReview(int reviewId, String newComment, double newRating) async {
    try {
      final response = await httpService.put(
        'reviews/$reviewId',
        {
          'comment': newComment,
          'rating': newRating,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteReview(int reviewId) async {
    try {
      final response = await httpService.delete('reviews/$reviewId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}