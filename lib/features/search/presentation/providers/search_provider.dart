import 'package:flutter/foundation.dart';
import '../../data/search_repository.dart';
import '../../../catalog/domain/models/part_model.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchFilter {
  final String? make;
  final String? model;
  final int? year;
  final List<String> brands;
  final List<String> categories;
  final double? minPrice;
  final double? maxPrice;
  final bool? inStockOnly;
  final String? partType; // 'OEM' | 'aftermarket'
  final String sortBy; // 'price_asc' | 'price_desc' | 'rating' | 'relevance'

  const SearchFilter({
    this.make,
    this.model,
    this.year,
    this.brands = const [],
    this.categories = const [],
    this.minPrice,
    this.maxPrice,
    this.inStockOnly,
    this.partType,
    this.sortBy = 'relevance',
  });

  SearchFilter copyWith({
    String? make,
    String? model,
    int? year,
    List<String>? brands,
    List<String>? categories,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    String? partType,
    String? sortBy,
  }) => SearchFilter(
    make: make ?? this.make,
    model: model ?? this.model,
    year: year ?? this.year,
    brands: brands ?? this.brands,
    categories: categories ?? this.categories,
    minPrice: minPrice ?? this.minPrice,
    maxPrice: maxPrice ?? this.maxPrice,
    inStockOnly: inStockOnly ?? this.inStockOnly,
    partType: partType ?? this.partType,
    sortBy: sortBy ?? this.sortBy,
  );

  SearchFilter reset() => const SearchFilter();

  bool get hasActiveFilters =>
      make != null ||
      brands.isNotEmpty ||
      categories.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      inStockOnly == true ||
      partType != null;

  Map<String, dynamic> toQueryParams() => {
    if (make != null) 'make': make,
    if (model != null) 'model': model,
    if (year != null) 'year': year.toString(),
    if (brands.isNotEmpty) 'brands': brands.join(','),
    if (categories.isNotEmpty) 'categories': categories.join(','),
    if (minPrice != null) 'minPrice': minPrice.toString(),
    if (maxPrice != null) 'maxPrice': maxPrice.toString(),
    if (inStockOnly == true) 'inStock': 'true',
    if (partType != null) 'partType': partType,
    'sortBy': sortBy,
  };
}

class SearchProvider extends ChangeNotifier {
  final SearchRepository _repo;

  SearchProvider({required SearchRepository repo}) : _repo = repo;

  // ── State
  SearchStatus _status = SearchStatus.initial;
  List<PartModel> _results = [];
  List<String> _suggestions = [];
  String _query = '';
  SearchFilter _filter = const SearchFilter();
  int _total = 0;
  int _page = 1;
  bool _hasMore = true;
  String? _error;

  // ── Getters
  SearchStatus get status => _status;

  List<PartModel> get results => _results;

  List<String> get suggestions => _suggestions;

  String get query => _query;

  SearchFilter get filter => _filter;

  int get total => _total;

  bool get hasMore => _hasMore;

  bool get isLoading => _status == SearchStatus.loading && _results.isEmpty;

  bool get isLoadingMore =>
      _status == SearchStatus.loading && _results.isNotEmpty;

  String? get error => _error;

  // ─────────────────────────────────────────────────────────
  // Search (fresh query)
  // ─────────────────────────────────────────────────────────
  Future<void> search(String query, {SearchFilter? filter}) async {
    _query = query;
    if (filter != null) _filter = filter;
    _status = SearchStatus.loading;
    _results = [];
    _page = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repo.search(
        query: query,
        page: 1,
        filters: _filter.toQueryParams(),
      );
      _results = result.items;
      _total = result.total;
      _hasMore = result.hasMore;
      _status = SearchStatus.loaded;
    } catch (e) {
      _status = SearchStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Load more results (infinite scroll)
  // ─────────────────────────────────────────────────────────
  Future<void> loadMore() async {
    if (!_hasMore || _status == SearchStatus.loading) return;
    _status = SearchStatus.loading;
    notifyListeners();

    try {
      _page++;
      final result = await _repo.search(
        query: _query,
        page: _page,
        filters: _filter.toQueryParams(),
      );
      _results.addAll(result.items);
      _hasMore = result.hasMore;
      _status = SearchStatus.loaded;
    } catch (_) {
      _page--;
      _status = SearchStatus.loaded;
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Autocomplete suggestions
  // ─────────────────────────────────────────────────────────
  Future<void> fetchSuggestions(String input) async {
    if (input.length < 2) {
      _suggestions = [];
      notifyListeners();
      return;
    }
    try {
      _suggestions = await _repo.getSuggestions(input);
      notifyListeners();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────
  // Apply / update filters then re-search
  // ─────────────────────────────────────────────────────────
  Future<void> applyFilter(SearchFilter newFilter) async {
    _filter = newFilter;
    await search(_query, filter: newFilter);
  }

  void clearFilters() {
    _filter = const SearchFilter();
    notifyListeners();
  }

  void clearAll() {
    _status = SearchStatus.initial;
    _results = [];
    _suggestions = [];
    _query = '';
    _filter = const SearchFilter();
    _total = 0;
    _page = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }
}
