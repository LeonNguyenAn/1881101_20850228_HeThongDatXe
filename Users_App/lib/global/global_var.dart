import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String userID = FirebaseAuth.instance.currentUser!.uid;

///Key Google Map
String googleMapKey = "AIzaSyDzifxpge9ajp-C9yDy-Kn5S75JfigAW6c";

///Key Firebase
String serverKeyFCM = "key=AAAAjDN6cCY:APA91bF8zw4xiP5Uwp0jn3B8D3CWde-cU2xSfJLfRPJYquajJrlPLUsXA7vZERNF55Co-wtucFOhakozsJ07Hys5aLSDKVtykCOH9-04G_OoQYkKZj9yJhmJ6eat_qtl1x5EXGS4vKIL";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(10.74699, 106.63151),
  zoom: 14.4746,
);
