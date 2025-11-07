import 'dart:convert';
import 'package:http/http.dart' as http;
import '../parameters/netservices.dart';
import '../models/dog.dart';

class ApiDogs {

  final String _apiDogUrl = NS.apiDogJsonUrl;

  /// Fetch raw JSON string from API (for caching purposes)
  Future<String> fetchRawData() async {
    final response = await http.get(Uri.parse(_apiDogUrl));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error during loading data.');
    }
  }

  Future<List<Dog>> fetchData() async {
    final response = await http.get(Uri.parse(_apiDogUrl));

    if (response.statusCode == 200) {
      try {
        final String body = response.body;
        final List<dynamic> ldData  = json.decode(body);
        if (ldData.isNotEmpty) {
          return ldData.map((map) => Dog.fromMap(map)).toList();
        } else {
          throw Exception('Missing or not "success" status field in response.');
        }
      } catch (e) {
        throw Exception('Error during the process of data: $e');
      }
    } else {
      throw Exception('Error during loading data.');
    }
  }

}
