import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._(); // Private constructor to prevent instantiation

  static Future<void> openMap(double lat, double lng) async {
    // Standard Google Maps URL format for coordinates
    final String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final Uri uri = Uri.parse(googleUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not open the map.';
    }
  }
}