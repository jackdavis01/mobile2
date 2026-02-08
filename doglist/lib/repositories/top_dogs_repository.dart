import '../models/top_dogs_response.dart';
import '../services/top_dogs_api_client.dart';

class TopDogsRepository {
  final TopDogsApiClient _apiClient = TopDogsApiClient();

  Future<TopDogsResponse> getTop3Dogs() async {
    return await _apiClient.getTop3Dogs();
  }
}
