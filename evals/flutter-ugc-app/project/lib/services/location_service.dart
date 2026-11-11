import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Shares the user's live position so nearby rooms and people stay up to date.
class LocationService {
  StreamSubscription<Position>? _sub;

  Future<void> startSharingLiveLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse) {
      // Ask for "Always" so the user keeps appearing in nearby rooms.
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    final settings = defaultTargetPlatform == TargetPlatform.iOS
        ? AppleSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 50,
            allowBackgroundLocationUpdates: true,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: false,
          )
        : const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 50);

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      FirebaseFirestore.instance.collection('presence').doc(uid).set({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  void stop() => _sub?.cancel();
}
