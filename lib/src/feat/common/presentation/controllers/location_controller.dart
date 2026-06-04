import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class LocationController extends GetxController {
  Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxString locationName = "Memuat lokasi...".obs;
  RxBool isLoading = false.obs;

  // Daftar warnet terdekat (offset relatif dari lokasi user dalam derajat)
  RxList<Map<String, dynamic>> nearbyPlaces = <Map<String, dynamic>>[].obs;

  static const List<Map<String, dynamic>> _placeOffsets = [
    {'name': 'GG Arena', 'dLat': 0.006, 'dLng': 0.004},
    {'name': 'Nexus Esports', 'dLat': -0.005, 'dLng': 0.007},
    {'name': 'CyberShop Hub', 'dLat': 0.008, 'dLng': -0.006},
    {'name': 'Telkom Gaming', 'dLat': -0.007, 'dLng': -0.005},
    {'name': 'Pixel Lounge', 'dLat': 0.003, 'dLng': 0.009},
  ];

  void _generateNearbyPlaces(LatLng center) {
    nearbyPlaces.value = _placeOffsets.map((p) {
      return {
        'name': p['name'],
        'location': LatLng(
          center.latitude + (p['dLat'] as double),
          center.longitude + (p['dLng'] as double),
        ),
      };
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    isLoading.value = true;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationName.value = "GPS tidak aktif";
      isLoading.value = false;
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        locationName.value = "Izin lokasi ditolak";
        isLoading.value = false;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      locationName.value = "Izin lokasi ditolak permanen";
      isLoading.value = false;
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 10),
        ),
      );
      LatLng loc = LatLng(position.latitude, position.longitude);
      currentLocation.value = loc;
      selectedLocation.value = loc;
      _generateNearbyPlaces(loc);
      await updateLocationName(loc);
    } catch (e) {
      debugPrint("Error getting location: $e");
      locationName.value = "Gagal mendapatkan lokasi";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLocationName(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude, location.longitude).timeout(const Duration(seconds: 5));
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        locationName.value = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'Unknown';
      }
    } catch (e) {
      debugPrint("Error getting placemark: $e");
      locationName.value = "Lokasi tidak diketahui";
    }
  }

  void onMapTap(LatLng location) {
    selectedLocation.value = location;
    updateLocationName(location);
  }
}
