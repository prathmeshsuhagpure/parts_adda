import 'package:flutter/foundation.dart';
import '../../data/catalog_repository.dart';
import '../../../parts/domain/models/part_model.dart';
import '../../domain/models/category_model.dart';

enum CatalogStatus { initial, loading, loaded, error }

class CategoryProvider extends ChangeNotifier {
  final CatalogRepository _repo;

  CategoryProvider({required CatalogRepository repo}) : _repo = repo;

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
  CatalogStatus _categoryStatus = CatalogStatus.initial;

  // ── Cascade selection
  List<CategoryModel> _subcategories = [];
  List<CategoryModel> _subSubcategories = [];
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String? _selectedSubSubcategoryId;
  CatalogStatus _subcategoryStatus = CatalogStatus.initial;
  CatalogStatus _subSubcategoryStatus = CatalogStatus.initial;

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

  CatalogStatus get categoryStatus => _categoryStatus;

  bool get isCategoryLoading => _categoryStatus == CatalogStatus.loading;

  // ── Cascade getters
  List<CategoryModel> get subcategories => _subcategories;

  List<CategoryModel> get subSubcategories => _subSubcategories;

  String? get selectedCategoryId => _selectedCategoryId;

  String? get selectedSubcategoryId => _selectedSubcategoryId;

  String? get selectedSubSubcategoryId => _selectedSubSubcategoryId;

  bool get isSubcategoryLoading => _subcategoryStatus == CatalogStatus.loading;

  bool get isSubSubcategoryLoading =>
      _subSubcategoryStatus == CatalogStatus.loading;

  /// Returns the deepest selected category id for form submission.
  String? get leafCategoryId =>
      _selectedSubSubcategoryId ??
      _selectedSubcategoryId ??
      _selectedCategoryId;

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
  // Load root categories
  // ─────────────────────────────────────────────────────────
  Future<void> loadCategories() async {
    _categoryStatus = CatalogStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repo.getRootCategories();
      _categoryStatus = CatalogStatus.loaded;
    } catch (e) {
      _categoryStatus = CatalogStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Cascade selection — called from the UI
  // ─────────────────────────────────────────────────────────

  /// Select a root category, reset lower levels, load subcategories.
  void selectCategory(String id) {
    _selectedCategoryId = id;
    _selectedSubcategoryId = null;
    _selectedSubSubcategoryId = null;
    _subcategories = [];
    _subSubcategories = [];
    _subcategoryStatus = CatalogStatus.initial;
    _subSubcategoryStatus = CatalogStatus.initial;
    notifyListeners();
    _loadSubcategories(id);
  }

  /// Select a subcategory, reset sub-subcategory level, load sub-subcategories.
  void selectSubcategory(String id) {
    _selectedSubcategoryId = id;
    _selectedSubSubcategoryId = null;
    _subSubcategories = [];
    _subSubcategoryStatus = CatalogStatus.initial;
    notifyListeners();
    _loadSubSubcategories(id);
  }

  /// Select a sub-subcategory (leaf).
  void selectSubSubcategory(String id) {
    _selectedSubSubcategoryId = id;
    notifyListeners();
  }

  /// Clear all cascade selections (e.g. when resetting the form).
  void clearCascadeSelection() {
    _selectedCategoryId = null;
    _selectedSubcategoryId = null;
    _selectedSubSubcategoryId = null;
    _subcategories = [];
    _subSubcategories = [];
    _subcategoryStatus = CatalogStatus.initial;
    _subSubcategoryStatus = CatalogStatus.initial;
    notifyListeners();
  }

  Future<void> _loadSubcategories(String parentId) async {
    _subcategoryStatus = CatalogStatus.loading;
    notifyListeners();
    try {
      _subcategories = await _repo.getSubCategories(parentId);
      _subcategoryStatus = CatalogStatus.loaded;
    } catch (e) {
      _subcategoryStatus = CatalogStatus.error;
      _subcategories = [];
    }
    notifyListeners();
  }

  Future<void> _loadSubSubcategories(String parentId) async {
    _subSubcategoryStatus = CatalogStatus.loading;
    notifyListeners();
    try {
      _subSubcategories = await _repo.getSubCategories(parentId);
      _subSubcategoryStatus = CatalogStatus.loaded;
    } catch (e) {
      _subSubcategoryStatus = CatalogStatus.error;
      _subSubcategories = [];
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
