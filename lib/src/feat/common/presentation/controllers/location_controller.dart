import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class LocationController extends GetxController {
  Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxString locationName = "Memuat lokasi...".obs;
  RxBool isLoading = false.obs;

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
        timeLimit: const Duration(seconds: 10),
      );
      LatLng loc = LatLng(position.latitude, position.longitude);
      currentLocation.value = loc;
      selectedLocation.value = loc;
      await updateLocationName(loc);
    } catch (e) {
      print("Error getting location: $e");
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
        locationName.value = "${place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'Unknown'}";
      }
    } catch (e) {
      print("Error getting placemark: $e");
      locationName.value = "Unknown Location";
    }
  }

  void onMapTap(LatLng location) {
    selectedLocation.value = location;
    updateLocationName(location);
  }
}
