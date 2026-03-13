import 'package:dio/dio.dart';
import 'package:parts_adda/core/api/api_endpoints.dart';
import '../../parts/domain/models/part_model.dart';

class SearchRepository {
  final Dio dio;

  SearchRepository({required this.dio});

  Future<SearchResult> search({
    required String query,
    required int page,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.search,
        queryParameters: {'q': query, 'page': page, ...?filters},
      );

      final data = response.data;

      final list = (data['data'] ?? []) as List;

      final items = list
          .map((e) => PartModel.fromJson(e))
          .toList();

      final pagination = data['pagination'];
      return SearchResult(
        items: items,
        total: pagination['total'] ?? items.length,
        hasMore: pagination['hasMore'] ?? false,
      );
    } catch (e) {
      print(e);
      throw Exception('Search failed');
    }
  }

  /// Autocomplete suggestions
  Future<List<String>> getSuggestions(String input) async {
    try {
      final response = await dio.get(
        ApiEndpoints.searchSuggestions,
        queryParameters: {'q': input},
      );

      final suggestions = response.data['suggestions'] as List;

      return suggestions.map((e) => e['name'].toString()).toList();
    } catch (e) {
      throw Exception('Failed to fetch suggestions');
    }
  }
}

class SearchResult {
  final List<PartModel> items;
  final int total;
  final bool hasMore;

  const SearchResult({
    required this.items,
    required this.total,
    required this.hasMore,
  });
}
