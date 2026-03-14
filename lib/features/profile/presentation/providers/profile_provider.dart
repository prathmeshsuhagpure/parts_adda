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
    try {
      _addresses = await _repo.getAddresses();
      notifyListeners();
    } catch (_) {}
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

  Future<void> loadVehicles() async {
    try {
      _vehicles = await _repo.getVehicles();
      notifyListeners();
    } catch (_) {}
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
    try {
      _wishlist = await _repo.getWishlist();
      notifyListeners();
    } catch (_) {}
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
