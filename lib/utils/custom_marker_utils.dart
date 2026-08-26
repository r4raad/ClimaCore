
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user.dart';
import '../models/school.dart';

class CustomMarkerUtils {

  static Future<BitmapDescriptor> createUserMarkerBitmap(
    AppUser user,
    School? school,
  ) async {

    print('🎨 User location marker handled by overlay widget');
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }

}