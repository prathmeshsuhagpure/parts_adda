import 'package:flutter/material.dart';
import '../../data/user_repository.dart';
import '../../domain/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final UserRepository _repo;

  NotificationProvider({required UserRepository repo}) : _repo = repo;

  final List<NotificationModel> _notifications = [];

  bool _loading = false;

  /// PUBLIC GETTERS
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  bool get isLoading => _loading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  /// LOAD NOTIFICATIONS
  Future<void> loadNotifications() async {
    try {
      _loading = true;
      notifyListeners();

      final list = await _repo.fetchNotifications();

      _notifications
        ..clear()
        ..addAll(list);
    } catch (e) {
      debugPrint("Notification load error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  /// MARK SINGLE NOTIFICATION READ
  Future<void> markRead(String id) async {
    try {
      await _repo.markNotificationRead(id);

      final index = _notifications.indexWhere((n) => n.id == id);

      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Mark read error: $e");
    }
  }

  /// MARK ALL READ
  Future<void> markAllRead() async {
    try {
      await _repo.markAllNotificationsRead();

      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Mark all read error: $e");
    }
  }

  /// OPTIONAL: REFRESH
  Future<void> refresh() async {
    await loadNotifications();
  }
}
