import 'package:dio/dio.dart';
import 'package:parts_adda/core/api/api_endpoints.dart';
import '../../parts/domain/models/part_model.dart';
import '../domain/models/category_model.dart';
import '../presentation/providers/catalog_provider.dart';

class CatalogRepository {
  final Dio dio;

  CatalogRepository({required this.dio});

  /// Get part detail
  Future<PartModel> getPartById(String partId) async {
    try {
      final response = await dio.get(ApiEndpoints.partById(partId));

      return PartModel.fromJson(response.data['data']['part']);
    } catch (e, stack) {
      print("PART DETAIL ERROR: $e");
      print(stack);
      throw Exception('Failed to load part');
    }
  }

  /// Get parts by category with pagination
  Future<PaginatedResult<PartModel>> getPartsByCategory({
    required String categoryId,
    required int page,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.partsByCategory(categoryId),
        queryParameters: {"page": page, ...?filters},
      );

      final data = response.data["data"];

      final List partsJson = data["parts"];

      final items = partsJson.map((e) => PartModel.fromJson(e)).toList();

      return PaginatedResult<PartModel>(
        items: items,
        total: items.length,
        hasMore: false,
      );
    } catch (e, stack) {
      print("PARTS API ERROR: $e");
      print(stack);
      rethrow;
    }
  }

  /// Get all categories
  Future<List<CategoryModel>> getRootCategories() async {
    try {
      final response = await dio.get(ApiEndpoints.rootCategories);

      final list = response.data["data"] as List;

      return list.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<CategoryModel>> getSubCategories(String parentId) async {
    try {
      final response = await dio.get(ApiEndpoints.subCategories(parentId));
      if (response.statusCode == 200 && response.data["success"] == true) {
        final List list = response.data["data"];

        return list.map((e) => CategoryModel.fromJson(e)).toList();
      }

      throw Exception("Failed to load sub categories");
    } catch (e) {
      throw Exception("Failed to load sub categories: $e");
    }
  }
}
