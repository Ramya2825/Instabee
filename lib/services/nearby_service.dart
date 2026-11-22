
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NearbyService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Please enable your GPS.');
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // Save current user's location
  Future<void> updateMyLocation(Position position) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('Please login first.');
    }

    await firestore
        .collection('nearby_locations')
        .doc(uid)
        .set({
      'uid': uid,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'nearbyEnabled': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getNearbyPeople({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    String? currentUid =
        FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      throw Exception('Please login first.');
    }

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore
            .collection('nearby_locations')
            .where('nearbyEnabled', isEqualTo: true)
            .get();

    List<Map<String, dynamic>> nearbyPeople = [];

    for (var doc in snapshot.docs) {
      String uid = doc.id;
      if (uid == currentUid) continue;

      var locationData = doc.data();

      if (locationData['latitude'] == null ||
          locationData['longitude'] == null) {
        continue;
      }

      double userLatitude =
          (locationData['latitude'] as num).toDouble();

      double userLongitude =
          (locationData['longitude'] as num).toDouble();

      double distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        userLatitude,
        userLongitude,
      );

      double distanceKm = distance / 1000;
      if (distanceKm <= radiusKm) {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await firestore
                .collection('users')
                .doc(uid)
                .get();

        if (!userDoc.exists) continue;

        Map<String, dynamic> userData = userDoc.data()!;

        String username =
            userData['username'] ??
            userData['userName'] ??
            userData['name'] ??
            'InstaBee User';


        String profileImage =
            userData['profileImage'] ??
            userData['profile_image'] ??
            '';

nearbyPeople.add({
  ...userData,
  'uid': uid,

  'username': username,
  'profileImage': userData['profile_url']??'',

  'latitude': userLatitude,
  'longitude': userLongitude,
  'distanceKm': distanceKm,
  'distance': distanceKm,
});
        }
      }

    nearbyPeople.sort(
      (a, b) => (a['distanceKm'] as double)
          .compareTo(b['distanceKm'] as double),
    );

    return nearbyPeople;
  }


  Future<void> disableNearby() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('Please login first.');
    }

    await firestore
        .collection('nearby_locations')
        .doc(uid)
        .update({
      'nearbyEnabled': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
