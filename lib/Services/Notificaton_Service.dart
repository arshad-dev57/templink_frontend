import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _inited = false;

  static const String _oneSignalAppId = "c769361a-6190-451b-b0b9-9a4fef5c436e";
  static const String _envName = "dev";
  static const String _envTagKey = "env";

  String? _lastExternalId;

  Future<void> init() async {
    if (_inited) return;

    debugPrint("🔔 Initializing OneSignal...");
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize(_oneSignalAppId);

    // ✅ Permission request
    final granted = await OneSignal.Notifications.requestPermission(true);
    debugPrint("🔔 OneSignal permission granted = $granted");

    // ✅ Opt-in push
    OneSignal.User.pushSubscription.optIn();

    // ✅ Clear old notifications
    OneSignal.Notifications.clearAll();

    // ✅ FOREGROUND mein bhi notification display karo
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint("🔔 ===== FOREGROUND NOTIFICATION =====");
      debugPrint("🔔 Title: ${event.notification.title}");
      debugPrint("🔔 Body: ${event.notification.body}");
      debugPrint("🔔 Data: ${event.notification.additionalData}");
      debugPrint("🔔 Calling display()...");

      // ✅ YAHI KEY HAI — foreground mein force display karo
      event.notification.display();

      debugPrint("🔔 display() called successfully");
      debugPrint("🔔 =====================================");
    });

    // ✅ Notification click handler
    OneSignal.Notifications.addClickListener((event) {
      final data = Map<String, dynamic>.from(
        event.notification.additionalData ?? {},
      );

      debugPrint('🔔 Notification Clicked: ${event.notification.title}');
      debugPrint('🔔 Notification Data: $data');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (data["screen"] == "home") {
          debugPrint("🔔 Home screen notification clicked");
        } else if (data["type"] == "auth") {
          debugPrint("🔔 Auth notification clicked");
        }
      });
    });

    // ✅ Subscription change observer
    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint("🔔 PushSubscription changed:");
      debugPrint("   optedIn=${state.current.optedIn}");
      debugPrint("   id=${state.current.id}");
      debugPrint("   token=${state.current.token}");
    });

    _inited = true;
    debugPrint("🔔 OneSignal initialized successfully");
  }

  /// Build external id like "dev:<mongoUserId>"
  String _buildExternalId(String mongoUserId) {
    final id = mongoUserId.trim();
    if (id.isEmpty) return "";
    return "$_envName:$id";
  }

  /// Subscription ready hone ka wait karo
  Future<bool> waitForSubscription({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    debugPrint("🔔 Waiting for push subscription to be ready...");

    final startTime = DateTime.now();
    while (DateTime.now().difference(startTime) < timeout) {
      final subscription = OneSignal.User.pushSubscription;

      if (subscription.id != null && subscription.id!.isNotEmpty) {
        debugPrint("✅ Push subscription is ready! ID: ${subscription.id}");
        return true;
      }

      debugPrint(
        "⏳ Still waiting... (${DateTime.now().difference(startTime).inSeconds}s)",
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    debugPrint("❌ Timeout waiting for push subscription");
    return false;
  }

  /// Login ke baad call karo
  Future<void> login(String mongoUserId) async {
    final externalUserId = _buildExternalId(mongoUserId);

    if (externalUserId.isEmpty) {
      debugPrint("🔔 OneSignal.login skipped (empty userId)");
      return;
    }

    debugPrint(
      "🔔 ATTEMPTING OneSignal login with externalId: $externalUserId",
    );
    debugPrint("🔔 Original mongoUserId: $mongoUserId");

    try {
      if (!_inited) {
        await init();
      }

      // ✅ Pehle logout karo
      debugPrint("🔔 Logging out from any previous session");
      await OneSignal.logout();
      await Future.delayed(const Duration(milliseconds: 500));

      final oldSubId = OneSignal.User.pushSubscription.id;
      debugPrint("🔔 Old subscription ID: $oldSubId");

      // ✅ Login
      await OneSignal.login(externalUserId);

      // ✅ Subscription ready hone ka wait
      final subscribed = await waitForSubscription(
        timeout: const Duration(seconds: 15),
      );

      if (!subscribed) {
        debugPrint("⚠️ Subscription not ready, trying to opt-in manually");
        OneSignal.User.pushSubscription.optIn();
        await Future.delayed(const Duration(seconds: 3));
      }

      // ✅ Environment tag
      await OneSignal.User.addTagWithKey(_envTagKey, _envName);
      debugPrint("   - Environment tag set: $_envTagKey=$_envName");

      _lastExternalId = externalUserId;
      await verifyDeviceRegistration();

      debugPrint("✅ OneSignal login completed successfully");
    } catch (e) {
      debugPrint("❌ OneSignal login error: $e");
    }
  }

  /// Logout
  Future<void> logout() async {
    _lastExternalId = null;
    await OneSignal.logout();
    debugPrint("✅ OneSignal logout");
  }

  /// Device registration verify karo
  Future<void> verifyDeviceRegistration() async {
    try {
      final subscription = OneSignal.User.pushSubscription;
      debugPrint("🔍 VERIFICATION - Device Registration Status:");
      debugPrint("   - Push subscription ID: ${subscription.id}");
      debugPrint("   - Push token: ${subscription.token}");
      debugPrint("   - Opted in: ${subscription.optedIn}");
      debugPrint("   - External ID set: $_lastExternalId");
      debugPrint(
        "   - Permission granted: ${OneSignal.Notifications.permission}",
      );

      if (subscription.id == null || subscription.id!.isEmpty) {
        debugPrint("❌ No push subscription ID! Trying to opt-in again...");
        OneSignal.User.pushSubscription.optIn();
        await Future.delayed(const Duration(seconds: 2));
      } else {
        debugPrint("✅ Device successfully registered with OneSignal");
        debugPrint("✅ Device ID: ${subscription.id}");
      }
    } catch (e) {
      debugPrint("❌ Verification error: $e");
    }
  }

  /// Debug state print
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
      debugPrint("   OneSignal initialized: $_inited");
    } catch (e) {
      debugPrint("❌ OneSignal debugPrintState error: $e");
    }
  }
}