import 'package:latlong2/latlong.dart';

class GeoUtils {
  static List<List<double>> rectangleFromCenter(LatLng center) {
    const double delta = 0.001; // ~100m square

    final lat = center.latitude;
    final lng = center.longitude;

    return [
      [lng - delta, lat - delta],
      [lng + delta, lat - delta],
      [lng + delta, lat + delta],
      [lng - delta, lat + delta],
    ];
  }
}
