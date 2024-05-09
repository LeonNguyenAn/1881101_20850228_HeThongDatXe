import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";

///Key Googlemap của tài khoản
String googleMapKey = "AIzaSyDzifxpge9ajp-C9yDy-Kn5S75JfigAW6c";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(10.74695, 106.63044),
  zoom: 14.4746,
);

StreamSubscription<Position>? positionStreamHomePage;
StreamSubscription<Position>? positionStreamNewTripPage;

int driverTripRequestTimeout = 20;

final audioPlayer = AssetsAudioPlayer();

Position? driverCurrentPosition;

///retrieveCurrentDriverInfo()
String driverName = "";
String driverPhone = "";
String driverPhoto = "";
String carColor = "";
String carModel = "";
String carNumber = "";