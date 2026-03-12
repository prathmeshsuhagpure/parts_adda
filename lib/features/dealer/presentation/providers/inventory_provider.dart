import 'package:flutter/foundation.dart';
import '../../domain/models/inventory_model.dart';

enum InventoryStatus { initial, loading, loaded, saving, error }

class InventoryProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────
  InventoryStatus _status = InventoryStatus.initial;
  List<InventoryItem> _items = [];
  String? _error;
  String _searchQuery = '';
  ListingStatus? _statusFilter;
  String _sortBy = 'updatedAt'; // updatedAt | price | stock | soldCount

  // ── Getters ───────────────────────────────────────────────
  InventoryStatus get status => _status;

  String? get error => _error;

  bool get isLoading => _status == InventoryStatus.loading;

  bool get isSaving => _status == InventoryStatus.saving;

  String get searchQuery => _searchQuery;

  ListingStatus? get statusFilter => _statusFilter;

  String get sortBy => _sortBy;

  List<InventoryItem> get items {
    var list = List<InventoryItem>.from(_items);

    // Filter by status
    if (_statusFilter != null) {
      list = list.where((i) => i.status == _statusFilter).toList();
    }
    // Filter by search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (i) =>
                i.name.toLowerCase().contains(q) ||
                i.sku.toLowerCase().contains(q) ||
                i.brand.toLowerCase().contains(q) ||
                (i.oemNumber?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    // Sort
    switch (_sortBy) {
      case 'price':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'stock':
        list.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case 'soldCount':
        list.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      default:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return list;
  }

  // Summary stats
  int get totalListings => _items.length;

  int get activeListings =>
      _items.where((i) => i.status == ListingStatus.active).length;

  int get lowStockCount =>
      _items.where((i) => i.stock > 0 && i.stock <= 5).length;

  int get outOfStock => _items.where((i) => i.stock == 0).length;

  double get totalRevenue =>
      _items.fold(0, (sum, i) => sum + (i.price * i.soldCount));

  // ── Load inventory ────────────────────────────────────────
  Future<void> loadInventory() async {
    _status = InventoryStatus.loading;
    _error = null;
    notifyListeners();
    try {
      // TODO: replace with real API call
      // final res = await _api.get('/seller/inventory');
      // _items = (res as List).map((j) => InventoryItem.fromJson(j)).toList();
      await Future.delayed(const Duration(milliseconds: 800));
      _items = _mockItems();
      _status = InventoryStatus.loaded;
    } catch (e) {
      _status = InventoryStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  // ── Add listing ───────────────────────────────────────────
  Future<bool> addListing(Map<String, dynamic> data) async {
    _status = InventoryStatus.saving;
    _error = null;
    notifyListeners();
    try {
      // TODO: await _api.post('/seller/inventory', data);
      await Future.delayed(const Duration(milliseconds: 700));
      final newItem = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        partId: DateTime.now().millisecondsSinceEpoch.toString(),
        name: data['name'] as String,
        sku: data['sku'] as String,
        brand: data['brand'] as String? ?? '',
        category: data['category'] as String? ?? '',
        price: (data['price'] as num).toDouble(),
        mrp: data['mrp'] != null ? (data['mrp'] as num).toDouble() : null,
        b2bPrice: data['b2bPrice'] != null
            ? (data['b2bPrice'] as num).toDouble()
            : null,
        stock: (data['stock'] as int?) ?? 0,
        status: ListingStatus.pending,
        oemNumber: data['oemNumber'] as String?,
        partType: data['partType'] as String?,
        description: data['description'] as String?,
        specifications: (data['specifications'] as Map<String, String>?) ?? {},
        compatibleMakes: (data['compatibleMakes'] as List<String>?) ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _items.insert(0, newItem);
      _status = InventoryStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = InventoryStatus.loaded;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Update listing ────────────────────────────────────────
  Future<bool> updateListing(String id, Map<String, dynamic> data) async {
    _status = InventoryStatus.saving;
    notifyListeners();
    try {
      // TODO: await _api.patch('/seller/inventory/$id', data);
      await Future.delayed(const Duration(milliseconds: 600));
      final idx = _items.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final old = _items[idx];
        _items[idx] = old.copyWith(
          name: data['name'] as String?,
          sku: data['sku'] as String?,
          brand: data['brand'] as String?,
          category: data['category'] as String?,
          price: data['price'] != null
              ? (data['price'] as num).toDouble()
              : null,
          mrp: data['mrp'] != null ? (data['mrp'] as num).toDouble() : null,
          b2bPrice: data['b2bPrice'] != null
              ? (data['b2bPrice'] as num).toDouble()
              : null,
          stock: data['stock'] as int?,
          oemNumber: data['oemNumber'] as String?,
          partType: data['partType'] as String?,
          description: data['description'] as String?,
        );
      }
      _status = InventoryStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = InventoryStatus.loaded;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Toggle active/inactive ────────────────────────────────
  Future<void> toggleStatus(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final old = _items[idx];
    final next = old.status == ListingStatus.active
        ? ListingStatus.inactive
        : ListingStatus.active;
    _items[idx] = old.copyWith(status: next);
    notifyListeners();
    try {
      // TODO: await _api.patch('/seller/inventory/$id', {'status': next.apiValue});
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (_) {
      _items[idx] = old; // revert
      notifyListeners();
    }
  }

  // ── Update stock only ─────────────────────────────────────
  Future<void> updateStock(String id, int newStock) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final old = _items[idx];
    _items[idx] = old.copyWith(stock: newStock);
    notifyListeners();
    try {
      // TODO: await _api.patch('/seller/inventory/$id', {'stock': newStock});
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (_) {
      _items[idx] = old;
      notifyListeners();
    }
  }

  // ── Delete listing ────────────────────────────────────────
  Future<bool> deleteListing(String id) async {
    final old = List<InventoryItem>.from(_items);
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    try {
      // TODO: await _api.delete('/seller/inventory/$id');
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    } catch (_) {
      _items = old;
      notifyListeners();
      return false;
    }
  }

  // ── Filter / search helpers ───────────────────────────────
  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setStatusFilter(ListingStatus? s) {
    _statusFilter = s;
    notifyListeners();
  }

  void setSortBy(String s) {
    _sortBy = s;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Mock data (remove when API ready) ─────────────────────
  List<InventoryItem> _mockItems() => [
    InventoryItem(
      id: '1',
      partId: 'p1',
      name: 'Bosch Wiper Blade 18"',
      sku: 'BSH-WB18',
      brand: 'Bosch',
      category: 'Wipers',
      price: 349,
      mrp: 499,
      stock: 45,
      soldCount: 120,
      rating: 4.5,
      reviewCount: 34,
      status: ListingStatus.active,
      partType: 'aftermarket',
      createdAt: DateTime(2025, 1),
      updatedAt: DateTime(2025, 6),
    ),
    InventoryItem(
      id: '2',
      partId: 'p2',
      name: 'Mahle Oil Filter OC100',
      sku: 'MHL-OC100',
      brand: 'Mahle',
      category: 'Filters',
      price: 285,
      mrp: 380,
      b2bPrice: 240,
      stock: 3,
      soldCount: 89,
      rating: 4.3,
      reviewCount: 21,
      status: ListingStatus.active,
      oemNumber: '15400-PH1-014',
      partType: 'OEM',
      createdAt: DateTime(2025, 2),
      updatedAt: DateTime(2025, 6),
    ),
    InventoryItem(
      id: '3',
      partId: 'p3',
      name: 'Exide 45Ah Battery',
      sku: 'EXD-45L',
      brand: 'Exide',
      category: 'Batteries',
      price: 3499,
      mrp: 4200,
      b2bPrice: 3100,
      stock: 0,
      soldCount: 55,
      rating: 4.7,
      reviewCount: 48,
      status: ListingStatus.inactive,
      createdAt: DateTime(2025, 3),
      updatedAt: DateTime(2025, 6),
    ),
    InventoryItem(
      id: '4',
      partId: 'p4',
      name: 'NGK Iridium Spark Plug',
      sku: 'NGK-IX5',
      brand: 'NGK',
      category: 'Engine',
      price: 420,
      mrp: 550,
      stock: 28,
      soldCount: 210,
      rating: 4.8,
      reviewCount: 73,
      status: ListingStatus.active,
      oemNumber: 'BKR6EIX',
      partType: 'OEM',
      createdAt: DateTime(2025, 1),
      updatedAt: DateTime(2025, 5),
    ),
    InventoryItem(
      id: '5',
      partId: 'p5',
      name: 'Monroe Shock Absorber Front',
      sku: 'MNR-SA01',
      brand: 'Monroe',
      category: 'Suspension',
      price: 2100,
      mrp: 2800,
      stock: 12,
      soldCount: 30,
      rating: 4.2,
      reviewCount: 15,
      status: ListingStatus.pending,
      createdAt: DateTime(2025, 4),
      updatedAt: DateTime(2025, 6),
    ),
    InventoryItem(
      id: '6',
      partId: 'p6',
      name: 'Lumax LED Headlight H4',
      sku: 'LMX-H4',
      brand: 'Lumax',
      category: 'Electrical',
      price: 1200,
      mrp: 1600,
      b2bPrice: 980,
      stock: 5,
      soldCount: 67,
      rating: 4.0,
      reviewCount: 22,
      status: ListingStatus.active,
      createdAt: DateTime(2025, 2),
      updatedAt: DateTime(2025, 5),
    ),
  ];
}
