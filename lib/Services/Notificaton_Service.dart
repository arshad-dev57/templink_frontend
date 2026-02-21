import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// ✅ Templink OneSignal Notification Service
/// - No separate constants file
/// - Supports envName + externalId format like: "dev:mongodbUserId"
/// - Foreground display
/// - Click handling
/// - Debug state printing
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _inited = false;

  static const String _oneSignalAppId = "c769361a-6190-451b-b0b9-9a4fef5c436e";

  static const String _envName = "dev";

  static const bool _useEnvPrefixInExternalId = true;

  static const String _envTagKey = "env";
  String? _lastExternalId;

  Future<void> init() async {
    if (_inited) return;

    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Init OneSignal
    OneSignal.initialize(_oneSignalAppId);

    // Request permission (iOS + Android 13+)
    final granted = await OneSignal.Notifications.requestPermission(true);
    debugPrint("🔔 OneSignal permission granted = $granted");

    // Opt-in push
    OneSignal.User.pushSubscription.optIn();

    // Foreground: show notification even when app open
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();
      event.notification.display();
    });

    // Notification click/tap
    OneSignal.Notifications.addClickListener((event) {
      final data = Map<String, dynamic>.from(
        event.notification.additionalData ?? {},
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🔔 Notification Tapped: $data');
        // ✅ Yahan tum navigation bhi kara sakte ho
        // Example: if (data["screen"] == "payment") Get.to(() => paymentview());
      });
    });

    // Subscription observer
    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint("🔔 PushSubscription changed:");
      debugPrint("   optedIn=${state.current.optedIn}");
      debugPrint("   id=${state.current.id}");
      debugPrint("   token=${state.current.token}");
    });

    _inited = true;
  }

  /// Build external id like "dev:<mongoUserId>" or just "<mongoUserId>"
  String _buildExternalId(String mongoUserId) {
    final id = mongoUserId.trim();
    if (id.isEmpty) return "";

    if (_useEnvPrefixInExternalId) {
      return "$_envName:$id";
    }
    return id;
  }

  /// Call this after login success (when you have userId)
  Future<void> login(String mongoUserId) async {
    final externalUserId = _buildExternalId(mongoUserId);

    if (externalUserId.isEmpty) {
      debugPrint("🔔 OneSignal.login skipped (empty userId)");
      return;
    }

    _lastExternalId = externalUserId;

    await OneSignal.login(externalUserId);

    // Optional: env tag for segmentation
    await OneSignal.User.addTagWithKey(_envTagKey, _envName);

    debugPrint("✅ OneSignal logged in as externalId=$externalUserId");
  }

  Future<void> logout() async {
    _lastExternalId = null;
    await OneSignal.logout();
    debugPrint("✅ OneSignal logout");
  }

  Future<void> debugPrintState({String from = ""}) async {
    try {
      final permission = OneSignal.Notifications.permission;
      final sub = OneSignal.User.pushSubscription;

      debugPrint("🔎 OneSignalState[$from]");
      debugPrint("   permission=$permission");
      debugPrint("   optedIn=${sub.optedIn}");
      debugPrint("   subId=${sub.id}");
      debugPrint("   token=${sub.token}");
      debugPrint("   externalId=$_lastExternalId");
    } catch (e) {
      debugPrint("❌ OneSignal debugPrintState error: $e");
    }
  }
}
