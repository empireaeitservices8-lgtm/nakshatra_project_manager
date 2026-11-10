// =============================================================================
//  NotificationViewModel — Handles notification list fetching and marking as read
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class NotificationViewModel extends ChangeNotifier {
  final TaskManagerApiService _api;

  NotificationViewModel({TaskManagerApiService? api})
      : _api = api ?? TaskManagerApiService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _unreadOnly = false;
  String? _errorMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get unreadOnly => _unreadOnly;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // ─── Fetch Notifications ────────────────────────────────────────────────────
  Future<void> fetchNotifications({bool? unreadOnly}) async {
    if (unreadOnly != null) _unreadOnly = unreadOnly;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _api.getNotifications(unreadOnly: _unreadOnly);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Failed to load notifications: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Mark Single Notification as Read ───────────────────────────────────────
  Future<bool> markAsRead(int notificationId) async {
    try {
      await _api.markNotificationRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Failed to mark notification as read: $e";
      notifyListeners();
      return false;
    }
  }

  // ─── Mark All Notifications as Read ─────────────────────────────────────────
  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    for (final item in unread) {
      await markAsRead(item.id);
    }
  }

  void toggleUnreadOnly() {
    _unreadOnly = !_unreadOnly;
    fetchNotifications();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
