import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';

class LocationController extends GetxController {
  Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxString locationName = "Memuat lokasi...".obs;
  RxBool isLoading = false.obs;

  // Warnet terdekat dari Firestore (hanya yang punya koordinat lat/lng).
  RxList<Map<String, dynamic>> nearbyPlaces = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> _venues = [];
  StreamSubscription<List<Map<String, dynamic>>>? _venuesSub;

  /// Susun ulang marker dari daftar venue + lokasi user (untuk hitung jarak).
  void _rebuildNearby() {
    final center = currentLocation.value;
    final list = <Map<String, dynamic>>[];
    for (final v in _venues) {
      final lat = (v['lat'] as num?)?.toDouble();
      final lng = (v['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final entry = <String, dynamic>{...v, 'location': LatLng(lat, lng)};
      if (center != null) {
        final meters = Geolocator.distanceBetween(
            center.latitude, center.longitude, lat, lng);
        entry['distance'] = double.parse((meters / 1000).toStringAsFixed(1));
      }
      list.add(entry);
    }
    nearbyPlaces.value = list;
  }

  @override
  void onInit() {
    super.onInit();
    _venuesSub = FirestoreService.getVenues().listen((venues) {
      _venues = venues;
      _rebuildNearby();
    });
    _determinePosition();
  }

  @override
  void onClose() {
    _venuesSub?.cancel();
    super.onClose();
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
      _rebuildNearby();
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
