import 'dart:math' as math;

/// Subscription tiers used to determine maximum alert radius for advocates.
enum AdvocatePlan { core, plus, prime }

/// Emergency payload coming from a Halo emergency trigger.
class EmergencyAlertContext {
  const EmergencyAlertContext({
    required this.haloId,
    required this.haloName,
    required this.latitude,
    required this.longitude,
    required this.requestRadiusMeters,
    required this.userOptedInToAdvocateAlerts,
    required this.message,
  });

  final String haloId;
  final String haloName;
  final double latitude;
  final double longitude;
  final double requestRadiusMeters;

  /// If false, no advocate notifications should be sent.
  final bool userOptedInToAdvocateAlerts;
  final String message;
}

/// Advocate candidate loaded from DB/query before notification fan-out.
class AdvocateCandidate {
  const AdvocateCandidate({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.plan,
    required this.proximityAlertsEnabled,
    required this.optedInToEmergencyAlerts,
  });

  final String userId;
  final double latitude;
  final double longitude;
  final AdvocatePlan plan;

  /// Advocate preference toggle.
  final bool proximityAlertsEnabled;

  /// Advocate opt-in for receiving emergency alerts.
  final bool optedInToEmergencyAlerts;
}

/// Notification gateway abstraction. Plug in FCM/APNs implementation here.
abstract class AdvocateNotificationGateway {
  Future<void> sendEmergencyAlert({
    required String userId,
    required String title,
    required String body,
    required Map<String, String> data,
  });
}

/// Handles eligibility filtering and push fan-out for emergency alerts.
class AdvocateNotificationHandler {
  AdvocateNotificationHandler({
    required AdvocateNotificationGateway gateway,
    Map<AdvocatePlan, double>? planRadiusMeters,
  }) : _gateway = gateway,
       _planRadiusMeters =
           planRadiusMeters ??
           const <AdvocatePlan, double>{
             AdvocatePlan.core: 1609.34, // 1 mile
             AdvocatePlan.plus: 4828.03, // 3 miles
             AdvocatePlan.prime: 16093.4, // 10 miles
           };

  final AdvocateNotificationGateway _gateway;
  final Map<AdvocatePlan, double> _planRadiusMeters;

  /// Returns IDs of advocates who were notified.
  ///
  /// Eligibility rules:
  /// 1) Halo user must opt in to advocate notifications.
  /// 2) Advocate must enable proximity alerts.
  /// 3) Advocate must opt in to emergency alerts.
  /// 4) Advocate must be inside min(requestRadius, planRadius).
  Future<List<String>> notifyEligibleAdvocates({
    required EmergencyAlertContext context,
    required List<AdvocateCandidate> advocates,
  }) async {
    if (!context.userOptedInToAdvocateAlerts) {
      return <String>[];
    }

    final List<AdvocateCandidate> eligible = advocates.where((candidate) {
      if (!candidate.proximityAlertsEnabled) {
        return false;
      }
      if (!candidate.optedInToEmergencyAlerts) {
        return false;
      }

      final double planRadius =
          _planRadiusMeters[candidate.plan] ?? context.requestRadiusMeters;
      final double effectiveRadius = math.min(
        context.requestRadiusMeters,
        planRadius,
      );

      final double distanceMeters = _haversineMeters(
        lat1: context.latitude,
        lon1: context.longitude,
        lat2: candidate.latitude,
        lon2: candidate.longitude,
      );

      return distanceMeters <= effectiveRadius;
    }).toList(growable: false);

    for (final AdvocateCandidate candidate in eligible) {
      await _gateway.sendEmergencyAlert(
        userId: candidate.userId,
        title: 'NEDO HALO Emergency Nearby',
        body: context.message,
        data: <String, String>{
          'haloId': context.haloId,
          'haloName': context.haloName,
          'eventType': 'emergency_alert',
          'lat': context.latitude.toString(),
          'lng': context.longitude.toString(),
        },
      );
    }

    return eligible.map((AdvocateCandidate c) => c.userId).toList();
  }

  double _haversineMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusMeters = 6371000;

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        math.pow(math.sin(dLat / 2), 2).toDouble() +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.pow(math.sin(dLon / 2), 2).toDouble();

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);
}
