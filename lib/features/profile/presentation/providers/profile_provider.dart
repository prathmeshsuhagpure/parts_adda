/*
import 'package:flutter/foundation.dart';
import '../../data/user_repository.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../domain/models/address_model.dart';
import '../../domain/models/vehicle_model.dart';

enum ProfileStatus { initial, loading, loaded, saving, error }

class ProfileProvider extends ChangeNotifier {
  final UserRepository _repo;

  ProfileProvider({required UserRepository repo}) : _repo = repo;

  // ── State
  ProfileStatus _status = ProfileStatus.initial;
  UserModel? _user;
  List<AddressModel> _addresses = [];
  List<VehicleModel> _vehicles = [];
  List<dynamic> _wishlist = [];
  List<String> makes = [];
  List<String> models = [];
  List<int> years = [];
  List<VehicleModel> variants = [];
  String? _error;

  // ── Getters
  ProfileStatus get status => _status;

  UserModel? get user => _user;

  List<AddressModel> get addresses => _addresses;

  List<VehicleModel> get vehicles => _vehicles;

  List<dynamic> get wishlist => _wishlist;

  String? get error => _error;

  bool get isLoading => _status == ProfileStatus.loading;

  bool get isSaving => _status == ProfileStatus.saving;

  AddressModel? get defaultAddress =>
      _addresses.where((a) => a.isDefault).firstOrNull ??
      (_addresses.isNotEmpty ? _addresses.first : null);

  void _setStatus(ProfileStatus s) {
    _status = s;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _status = ProfileStatus.loading;
    notifyListeners();
    try {
      _user = await _repo.getProfile();
      _status = ProfileStatus.loaded;
    } catch (e) {
      _status = ProfileStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? avatar,
    String? dateOfBirth,
    String? phone,
    String? gender,
  }) async {
    _status = ProfileStatus.saving;
    notifyListeners();
    try {
      _user = await _repo.updateProfile(
        name: name,
        email: email,
        avatar: avatar,
        dateOfBirth: dateOfBirth,
        phone: phone,
        gender: gender,
      );
      _status = ProfileStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ProfileStatus.loaded;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAddresses() async {
    _setStatus(ProfileStatus.loading);

    try {
      _addresses = await _repo.getAddresses();
      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      _error = e.toString();
      _setStatus(ProfileStatus.error);
    }
  }

  Future<bool> addAddress(Map<String, dynamic> data) async {
    _status = ProfileStatus.saving;
    notifyListeners();

    try {
      final newAddr = await _repo.addAddress(data);

      _addresses = [..._addresses, newAddr];

      _setStatus(ProfileStatus.saving);

      return true;
    } catch (e) {
      _status = ProfileStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> data) async {
    _status = ProfileStatus.saving;
    notifyListeners();

    try {
      final updatedAddress = await _repo.updateAddress(id, data);

      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
      }

      _setStatus(ProfileStatus.saving);

      return true;
    } catch (e) {
      _status = ProfileStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    try {
      await _repo.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      await _repo.setDefaultAddress(id);
      _addresses = _addresses
          .map(
            (a) => AddressModel(
              id: a.id,
              label: a.label,
              fullName: a.fullName,
              phone: a.phone,
              line1: a.line1,
              line2: a.line2,
              city: a.city,
              state: a.state,
              pincode: a.pincode,
              isDefault: a.id == id,
            ),
          )
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMakes() async {
    try {
      _setStatus(ProfileStatus.loading);

      _makes = await _repo.getVehicleMakes();

      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      debugPrint("loadMakes error: $e");
      _setStatus(ProfileStatus.error);
    }
  }

  Future<void> loadModels(String make) async {
    try {
      _setStatus(ProfileStatus.loading);

      _models = await _repo.getVehicleModels(make);

      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      debugPrint("loadModels error: $e");
      _setStatus(ProfileStatus.error);
    }
  }

  Future<void> loadYears(String make, String model) async {
    try {
      _setStatus(ProfileStatus.loading);

      _years = await _repo.getVehicleYears(make, model);

      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      debugPrint("loadYears error: $e");
      _setStatus(ProfileStatus.error);
    }
  }

  Future<void> loadVariants(String make, String model, int year) async {
    try {
      _setStatus(ProfileStatus.loading);

      _variants = await _repo.getVehicleVariants(make, model, year);

      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      debugPrint("loadVariants error: $e");
      _setStatus(ProfileStatus.error);
    }
  }

  Future<void> loadVehicles() async {
    _setStatus(ProfileStatus.loading);

    try {
      _vehicles = await _repo.getVehicles();
      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      _error = e.toString();
      _setStatus(ProfileStatus.error);
    }
  }

  Future<bool> addVehicle(Map<String, dynamic> data) async {
    _setStatus(ProfileStatus.saving);
    try {
      final v = await _repo.addVehicle(data);
      _vehicles.add(v);
      _setStatus(ProfileStatus.loaded);
      return true;
    } catch (e) {
      _status = ProfileStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> removeVehicle(String id) async {
    try {
      await _repo.removeVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadWishlist() async {
    _setStatus(ProfileStatus.loading);

    try {
      _wishlist = await _repo.getWishlist();
      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      _error = e.toString();
      _setStatus(ProfileStatus.error);
    }
  }

  // AFTER
  Future<void> toggleWishlist(String partId) async {
    try {
      final res = await _repo.toggleWishlist(partId);

      if (res['action'] == 'added') {
        _wishlist.add({'id': partId, '_id': partId});
      } else if (res['action'] == 'removed') {
        _wishlist.removeWhere(
              (p) => p['id']?.toString() == partId || p['_id']?.toString() == partId,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  bool isWishlisted(String partId) => _wishlist.any(
        (p) => p['id']?.toString() == partId || p['_id']?.toString() == partId,
  );

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
*/

import 'package:flutter/foundation.dart';
import '../../data/user_repository.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../domain/models/address_model.dart';
import '../../domain/models/vehicle_model.dart';

enum ProfileStatus { initial, loading, loaded, saving, error }

class ProfileProvider extends ChangeNotifier {
  final UserRepository _repo;

  ProfileProvider({required UserRepository repo}) : _repo = repo;

  // ── State
  ProfileStatus _status = ProfileStatus.initial;
  UserModel? _user;
  List<AddressModel> _addresses = [];
  List<UserVehicleModel> _vehicles = [];
  List<dynamic> _wishlist = [];
  final Set<String> _togglingIds = {};

  // ── Vehicle cascade state (private, exposed via getters)
  List<BrandModel> _brands = [];
  List<VehicleModel> _models = [];
  List<GenerationModel> _generations = [];
  List<VariantModel> _variants = [];

  // ── Separate loading flags for each cascade level so the UI
  //    can show per-level spinners without blocking the whole screen
  bool _brandsLoading = false;
  bool _modelsLoading = false;
  bool _generationsLoading = false;
  bool _variantsLoading = false;

  String? _error;

  // ── Getters
  ProfileStatus get status => _status;
  UserModel? get user => _user;
  List<AddressModel> get addresses => _addresses;
  List<UserVehicleModel> get vehicles => _vehicles;
  List<dynamic> get wishlist => _wishlist;
  Set<String> get togglingIds => _togglingIds;
  String? get error => _error;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isSaving => _status == ProfileStatus.saving;

  // Vehicle cascade getters
  List<BrandModel> get brands => _brands;
  List<VehicleModel> get models => _models;
  List<GenerationModel> get generations => _generations;
  List<VariantModel> get variants => _variants;

  bool get brandsLoading => _brandsLoading;
  bool get modelsLoading => _modelsLoading;
  bool get variantsLoading => _variantsLoading;
  bool get generationsLoading => _generationsLoading;


  AddressModel? get defaultAddress =>
      _addresses.where((a) => a.isDefault).firstOrNull ??
          (_addresses.isNotEmpty ? _addresses.first : null);

  void _setStatus(ProfileStatus s) {
    _status = s;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Profile
  // ─────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    _status = ProfileStatus.loading;
    notifyListeners();
    try {
      _user = await _repo.getProfile();
      _status = ProfileStatus.loaded;
    } catch (e) {
      _status = ProfileStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? avatar,
    String? dateOfBirth,
    String? phone,
    String? gender,
  }) async {
    _status = ProfileStatus.saving;
    notifyListeners();
    try {
      _user = await _repo.updateProfile(
        name: name,
        email: email,
        avatar: avatar,
        dateOfBirth: dateOfBirth,
        phone: phone,
        gender: gender,
      );
      _status = ProfileStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ProfileStatus.loaded;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Addresses
  // ─────────────────────────────────────────────────────────

  Future<void> loadAddresses() async {
    _setStatus(ProfileStatus.loading);
    try {
      _addresses = await _repo.getAddresses();
      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      _error = e.toString();
      _setStatus(ProfileStatus.error);
    }
  }

  Future<bool> addAddress(Map<String, dynamic> data) async {
    _status = ProfileStatus.saving;
    notifyListeners();
    try {
      final newAddr = await _repo.addAddress(data);
      _addresses = [..._addresses, newAddr];
      _setStatus(ProfileStatus.loaded);
      return true;
    } catch (e) {
      _status = ProfileStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> data) async {
    _status = ProfileStatus.saving;
    notifyListeners();
    try {
      final updatedAddress = await _repo.updateAddress(id, data);
      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) _addresses[index] = updatedAddress;
      _setStatus(ProfileStatus.loaded);
      return true;
    } catch (e) {
      _status = ProfileStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    try {
      await _repo.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      await _repo.setDefaultAddress(id);
      _addresses = _addresses
          .map(
            (a) => AddressModel(
          id: a.id,
          label: a.label,
          fullName: a.fullName,
          phone: a.phone,
          line1: a.line1,
          line2: a.line2,
          city: a.city,
          state: a.state,
          pincode: a.pincode,
          isDefault: a.id == id,
        ),
      )
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────
  // Vehicle cascade loaders
  // ─────────────────────────────────────────────────────────

  Future<void> loadBrands() async {
    _brandsLoading = true;

    _models = [];
    _generations = [];
    _variants = [];

    notifyListeners();

    try {
      _brands = await _repo.getVehicleBrands();
    } catch (e) {
      debugPrint('loadBrands error: $e');
      _brands = [];
    }

    _brandsLoading = false;
    notifyListeners();
  }

  Future<void> loadModels(String brandId) async {
    _modelsLoading = true;

    _models = [];
    _generations = [];
    _variants = [];

    notifyListeners();

    try {
      _models = await _repo.getVehicleModels(brandId);
    } catch (e) {
      debugPrint('loadModels error: $e');
      _models = [];
    }

    _modelsLoading = false;
    notifyListeners();
  }

  Future<void> loadVehicleGenerations(String modelId) async {
    _generationsLoading = true;

    _generations = [];
    _variants = [];

    notifyListeners();

    try {
      _generations = await _repo.getVehicleGenerations(modelId);
    } catch (e) {
      debugPrint('loadGenerations error: $e');
      _generations = [];
    }
    _generationsLoading = false;
    notifyListeners();
  }

  Future<void> loadVariants(String generationId) async {
    _variantsLoading = true;

    _variants = [];
    notifyListeners();

    try {
      _variants = await _repo.getVehicleVariants(generationId);
    } catch (e) {
      debugPrint('loadVariants error: $e');
      _variants = [];
    }

    _variantsLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Vehicles (garage)
  // ─────────────────────────────────────────────────────────

  Future<void> loadVehicles() async {
    _setStatus(ProfileStatus.loading);
    try {
      _vehicles = await _repo.getUserVehicles();
      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      _error = e.toString();
      print("Error: ${e.toString()}");
      _setStatus(ProfileStatus.error);
    }
  }

  Future<bool> addVehicle(Map<String, dynamic> data) async {
    _setStatus(ProfileStatus.saving);

    try {
      final v = await _repo.addVehicle(data);

      _vehicles.add(v);

      _setStatus(ProfileStatus.loaded);
      return true;
    } catch (e) {
      debugPrint("addVehicle error: $e");
      _setStatus(ProfileStatus.error);
      return false;
    }
  }

  Future<void> removeVehicle(String id) async {
    try {
      await _repo.removeVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);
      notifyListeners();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────
  // Wishlist
  // ─────────────────────────────────────────────────────────

  Future<void> loadWishlist() async {
    _setStatus(ProfileStatus.loading);
    try {
      _wishlist = await _repo.getWishlist();
      _setStatus(ProfileStatus.loaded);
    } catch (e) {
      _error = e.toString();
      _setStatus(ProfileStatus.error);
    }
  }

  Future<void> toggleWishlist(String partId) async {
    _togglingIds.add(partId);
    notifyListeners();
    try {
      final res = await _repo.toggleWishlist(partId);
      if (res['action'] == 'added') {
        _wishlist.add({'id': partId, '_id': partId});
      } else if (res['action'] == 'removed') {
        _wishlist.removeWhere(
              (p) =>
          p['id']?.toString() == partId ||
              p['_id']?.toString() == partId,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _togglingIds.remove(partId);
      notifyListeners();
    }
  }

  bool isWishlisted(String partId) => _wishlist.any(
        (p) =>
    p['id']?.toString() == partId || p['_id']?.toString() == partId,
  );

  void clearError() {
    _error = null;
    notifyListeners();
  }
}