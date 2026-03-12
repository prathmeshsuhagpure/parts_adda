import 'package:flutter/foundation.dart';
import '../../data/catalog_repository.dart';
import '../../domain/models/part_model.dart';

enum CatalogStatus { initial, loading, loaded, error }

class CatalogProvider extends ChangeNotifier {
  final CatalogRepository _repo;

  CatalogProvider({required CatalogRepository repo}) : _repo = repo;

  // ── Part Detail
  CatalogStatus _detailStatus = CatalogStatus.initial;
  PartModel? _selectedPart;

  // ── Category listing
  CatalogStatus _listStatus = CatalogStatus.initial;
  List<PartModel> _parts = [];
  List<CategoryModel> _categories = [];
  int _totalParts = 0;
  int _currentPage = 1;
  bool _hasMore = true;

  // ── Error
  String? _error;

  // ── Getters
  CatalogStatus get detailStatus => _detailStatus;

  PartModel? get selectedPart => _selectedPart;

  CatalogStatus get listStatus => _listStatus;

  List<PartModel> get parts => _parts;

  List<CategoryModel> get categories => _categories;

  int get totalParts => _totalParts;

  bool get hasMore => _hasMore;

  bool get isDetailLoading => _detailStatus == CatalogStatus.loading;

  bool get isListLoading =>
      _listStatus == CatalogStatus.loading && _parts.isEmpty;

  bool get isLoadingMore =>
      _listStatus == CatalogStatus.loading && _parts.isNotEmpty;

  String? get error => _error;

  // ─────────────────────────────────────────────────────────
  // Load Part Detail
  // ─────────────────────────────────────────────────────────
  Future<void> loadPartDetail(String partId) async {
    _detailStatus = CatalogStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _selectedPart = await _repo.getPartById(partId);
      _detailStatus = CatalogStatus.loaded;
    } catch (e) {
      _detailStatus = CatalogStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Load category listing (first page)
  // ─────────────────────────────────────────────────────────
  Future<void> loadCategory({
    required String categoryId,
    Map<String, dynamic>? filters,
  }) async {
    _listStatus = CatalogStatus.loading;
    _parts = [];
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repo.getPartsByCategory(
        categoryId: categoryId,
        page: 1,
        filters: filters,
      );
      _parts = result.items;
      _totalParts = result.total;
      _hasMore = result.hasMore;
      _listStatus = CatalogStatus.loaded;
    } catch (e) {
      _listStatus = CatalogStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Load more (pagination)
  // ─────────────────────────────────────────────────────────
  Future<void> loadMore({
    required String categoryId,
    Map<String, dynamic>? filters,
  }) async {
    if (!_hasMore || _listStatus == CatalogStatus.loading) return;
    _listStatus = CatalogStatus.loading;
    notifyListeners();
    try {
      _currentPage++;
      final result = await _repo.getPartsByCategory(
        categoryId: categoryId,
        page: _currentPage,
        filters: filters,
      );
      _parts.addAll(result.items);
      _hasMore = result.hasMore;
      _listStatus = CatalogStatus.loaded;
    } catch (e) {
      _currentPage--;
      _listStatus = CatalogStatus.loaded;
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Load all categories
  // ─────────────────────────────────────────────────────────
  Future<void> loadCategories() async {
    _error = null;
    notifyListeners();

    try {
      _categories = await _repo.getMainCategories();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  void clearDetail() {
    _selectedPart = null;
    _detailStatus = CatalogStatus.initial;
    notifyListeners();
  }
}

// Simple pagination result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.hasMore,
  });
}
