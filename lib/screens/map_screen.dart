import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  final Point? startPoint;

  const MapScreen({super.key, this.startPoint});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController _mapController;
  final List<MapObject> _mapObjects = [];
  final Point _initialPoint = const Point(latitude: 41.6914, longitude: 60.2940);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];
          _mapObjects.clear();

          for (var doc in users) {
            final data = doc.data() as Map<String, dynamic>;
            final double lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
            final double lon = (data['long'] as num?)?.toDouble() ?? 0.0;

            if (lat != 0.0 && lon != 0.0) {
              _mapObjects.add(
                PlacemarkMapObject(
                  mapId: MapObjectId(doc.id),
                  point: Point(latitude: lat, longitude: lon),
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage('assets/images/img_marker.png'),
                      scale: 0.3,
                      anchor: const Offset(0.8, 1.0),
                    ),
                  ),
                  onTap: (obj, point) => _showUserDetail(data),
                ),
              );
            }
          }

          return Stack(
            children: [
              YandexMap(
                mapObjects: _mapObjects,
                onMapCreated: (controller) {
                  _mapController = controller;
                  final Point targetPoint = widget.startPoint ?? const Point(latitude: 41.6914, longitude: 41.6914);
                  _mapController.moveCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: targetPoint, zoom: 15),
                    ),
                  );
                },
              ),
              _buildFloatingHeader(users.length),
              _buildMapControls(),
              Positioned(
                top: 50,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingHeader(int userCount) {
    return Positioned(
      top: 50,
      left: 75,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: Icon(Icons.radar, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Radar Active", style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                Text("$userCount friends nearby", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: 80,
      right: 20,
      child: Column(
        children: [
          _buildMapButton(Icons.add, () => _mapController.moveCamera(CameraUpdate.zoomIn())),
          const SizedBox(height: 10),
          _buildMapButton(Icons.remove, () => _mapController.moveCamera(CameraUpdate.zoomOut())),
          const SizedBox(height: 10),
          _buildMapButton(Icons.my_location, () {
            _mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _initialPoint, zoom: 15)));
          }, isPrimary: true),
        ],
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.blue[800] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : Colors.blue[800]),
      ),
    );
  }

  void _showUserDetail(Map<String, dynamic> data) {
    final String email = data['email'] ?? "Unknown User";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue[100],
                  child: Text(email[0].toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.green, size: 10),
                          SizedBox(width: 5),
                          Text("Active Now", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}