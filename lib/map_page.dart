import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instabee/Allhomepages/targetpage.dart';
import 'package:instabee/services/nearby_service.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class BeeNearbyPage extends StatefulWidget {
  const BeeNearbyPage({super.key});

  @override
  State<BeeNearbyPage> createState() => _BeeNearbyPageState();
}

class _BeeNearbyPageState extends State<BeeNearbyPage> {
 Future<BitmapDescriptor> createProfileMarker(String? imageUrl) async {
  const int size = 80;

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // White circular border
  canvas.drawCircle(
    const ui.Offset(size / 2, size / 2),
    40,
    ui.Paint()..color = Colors.white,
  );

  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      final networkImage = NetworkImage(imageUrl);
      final imageStream = networkImage.resolve(
        const ImageConfiguration(),
      );

      final completer = Completer<ui.Image>();

      final listener = ImageStreamListener((info, _) {
        completer.complete(info.image);
      });

      imageStream.addListener(listener);

      final image = await completer.future;
      imageStream.removeListener(listener);

      canvas.save();

      canvas.clipPath(
        ui.Path()
          ..addOval(
            const ui.Rect.fromLTWH(3, 3, 74, 74),
          ),
      );

      paintImage(
        canvas: canvas,
        rect: const ui.Rect.fromLTWH(3, 3, 74, 74),
        image: image,
        fit: BoxFit.cover,
      );

      canvas.restore();
    } catch (e) {
      canvas.drawCircle(
        const ui.Offset(size / 2, size / 2),
        37,
        ui.Paint()..color = Colors.grey,
      );
    }
  } else {
    canvas.drawCircle(
      const ui.Offset(size / 2, size / 2),
      37,
      ui.Paint()..color = Colors.grey,
    );
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);

  final bytes = await img.toByteData(
    format: ui.ImageByteFormat.png,
  );

  return BitmapDescriptor.bytes(
    bytes!.buffer.asUint8List(),
  );
}
  final NearbyService nearbyService = NearbyService();

  GoogleMapController? mapController;

  Position? currentPosition;

  List<Map<String, dynamic>> nearbyUsers = [];

  Set<Marker> markers = {};

  int selectedRadius = 10;

  bool isLoading = true;
  bool isRefreshing = false;

  Timer? refreshTimer;
  Timer? locationTimer;

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;
  

  @override
  void initState() {
    super.initState();
    initializeNearby();
  }
  Future<void> initializeNearby() async {
    try {
      Position position = await nearbyService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        isLoading = false;
      });
      await nearbyService.updateMyLocation(position);
      await loadNearbyPeople();
      locationTimer = Timer.periodic(const Duration(seconds: 30), (
        timer,
      ) async {
        try {
          Position position = await nearbyService.getCurrentLocation();

          currentPosition = position;

          await nearbyService.updateMyLocation(position);

          if (mounted) {
            await loadNearbyPeople();
          }
        } catch (e) {
          debugPrint('Location update error: $e');
        }
      });
      refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
        if (mounted) {
          await loadNearbyPeople();
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
Future<void> loadNearbyPeople() async {
  if (currentPosition == null) return;

  try {
    final users = await nearbyService.getNearbyPeople(
      latitude: currentPosition!.latitude,
      longitude: currentPosition!.longitude,
      radiusKm: selectedRadius,
    );

    if (!mounted) return;

    setState(() {
      nearbyUsers = users;
      isRefreshing = false;
    });

    await updateMarkers();

  } catch (e) {
    if (!mounted) return;

    setState(() {
      isRefreshing = false;
    });

    debugPrint('Nearby error: $e');
  }
}

Future<void> updateMarkers() async {
  Set<Marker> newMarkers = {};

  for (var user in nearbyUsers) {
    BitmapDescriptor icon = await createProfileMarker(
      user['profileImage']?.toString(),
    );

    newMarkers.add(
      Marker(
        markerId: MarkerId(user['uid']),
        position: LatLng(
          user['latitude'],
          user['longitude'],
        ),
        icon: icon,
        infoWindow: InfoWindow(
          title: '@${user['username']}',
          snippet: '${user['distanceKm']} km away',
        ),
        onTap: () {
          openUserProfile(user);
        },
      ),
    );
  }

  if (!mounted) return;

  setState(() {
    markers = newMarkers;
  });
}
 Future<void> openUserProfile(Map<String, dynamic> user)  async{
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Targetpage(uid: user['uid'], currentUserId: currentUserId),
      ),
    );
  }

  Future<void> changeRadius(int radius) async {
    setState(() {
      selectedRadius = radius;
      isRefreshing = true;
    });

    await loadNearbyPeople();
  }

  Future<void> refreshNearby() async {
    setState(() {
      isRefreshing = true;
    });

    try {
      Position position = await nearbyService.getCurrentLocation();
      currentPosition = position;
      await nearbyService.updateMyLocation(position);
      await loadNearbyPeople();
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    mapController?.dispose();
    locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentPosition == null) {
      return Scaffold(
        appBar: AppBar(title: Text('BeeNearby')),
        body: Center(child: Text('Unable to get your location.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nearby Maps',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: refreshNearby, icon: Icon(Icons.refresh)),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  'Discover people within:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                Spacer(),

                ChoiceChip(
                  label: Text('10 km'),
                  selected: selectedRadius == 10,
                  onSelected: (value) {
                    if (value) changeRadius(10);
                  },
                ),

                SizedBox(width: 8),

                ChoiceChip(
                  label: Text('20 km'),
                  selected: selectedRadius == 20,
                  onSelected: (value) {
                    if (value) changeRadius(20);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(13.0827, 80.2707),

                  zoom: 12,
                ),

                onMapCreated: (controller) {
                  mapController = controller;
                },

                myLocationEnabled: true,
                myLocationButtonEnabled: true,

                markers: markers,

                zoomControlsEnabled: true,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(
                        'People Nearby',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Spacer(),

                      Text(
                        '${nearbyUsers.length} people',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                if (isRefreshing) LinearProgressIndicator(),

                Expanded(
                  child: nearbyUsers.isEmpty
                      ? Center(child: Text('No InstaBee users  '))
                      : ListView.builder(
                          itemCount: nearbyUsers.length,
                          itemBuilder: (context, index) {
                            final user = nearbyUsers[index];

                           
return ListTile(
  leading: CircleAvatar(
    radius: 26,
    backgroundImage:
        user['profileImage'] != null &&
                user['profileImage'].toString().isNotEmpty
            ? NetworkImage(user['profileImage'])
            : null,
    child: user['profileImage'] == null ||
            user['profileImage'].toString().isEmpty
        ? const Icon(Icons.person, size: 28)
        : null,
  ),

  title: Text(
    '@${user['username'] ?? 'InstaBee User'}',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),

  subtitle: Text(
    '${(user['distanceKm'] as num).toStringAsFixed(1)} km away',
  ),

  trailing: const Icon(
    Icons.arrow_forward_ios,
    size: 16,
  ),

  onTap: () {
    openUserProfile(user);
  },
);

                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
