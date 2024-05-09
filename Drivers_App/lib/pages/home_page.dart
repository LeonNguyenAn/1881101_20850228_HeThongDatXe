import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drivers_app/methods/map_theme_methods.dart';
import 'package:drivers_app/pushNotification/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global_var.dart';

class HomePage extends StatefulWidget
{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  ///Nhúng Google map vô
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;

  ///Vị trí hiện tại
  Position? currentPositionOfDriver;

  ///Go Online Offline Button
  Color colorToShow = Colors.green;
  String titleToShow = "TRỰC TUYẾN NGAY BÂY GIỜ";
  bool isDriverAvailable = false;

  DatabaseReference? newTripRequestReference;

  ///Thay đổi Themes cho Google Map
  MapThemeMethods themeMethods = MapThemeMethods();

  ///Chọn vị trí hiện tại trên Google Map
  getCurrentLiveLocationOfDriver() async
  {
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfUser;
    driverCurrentPosition = currentPositionOfDriver;

    LatLng positionOfUserInLatLng = LatLng(currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLng, zoom: 16);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  ///Chế độ Online
  goOnlineNow()
  {
    ///all drivers who are Available for new trip requests
    Geofire.initialize("onlineDrivers");

    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfDriver!.latitude,
      currentPositionOfDriver!.longitude,
    );

    newTripRequestReference = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");
    newTripRequestReference!.set("waiting");

    newTripRequestReference!.onValue.listen((event) { });
  }

  ///Cập nhật vị trí hiện tại
  setAndGetLocationUpdates()
  {
    positionStreamHomePage = Geolocator.getPositionStream()
        .listen((Position position)
    {
      currentPositionOfDriver = position;

      if(isDriverAvailable == true)
      {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );
      }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      controllerGoogleMap!.animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  ///Chế độ Offline
  goOfflineNow()
  {
    ///Stop sharing driver live location updates
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    ///Stop listening to the newTripStatus
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  ///Khởi tạo thông báo trên App
  initializePushNotificationSystem()
  {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  ///Truy xuất thông tin tài xế hiện tại
  retrieveCurrentDriverInfo() async
  {
    await FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once().then((snap)
    {
      driverName = (snap.snapshot.value as Map)["name"];
      driverPhone = (snap.snapshot.value as Map)["phone"];
      driverPhoto = (snap.snapshot.value as Map)["photo"];
      carColor = (snap.snapshot.value as Map)["car_details"]["carColor"];
      carModel = (snap.snapshot.value as Map)["car_details"]["carModel"];
      carNumber = (snap.snapshot.value as Map)["car_details"]["carNumber"];
    });

    initializePushNotificationSystem();
  }

  @override
  void initState()
  {
    // TODO: implement initState
    super.initState();

    retrieveCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [

            ///Google Map _ Nhúng Google Map vô
            GoogleMap(
              padding: const EdgeInsets.only(top: 136),
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: googlePlexInitialPosition,
              onMapCreated: (GoogleMapController mapController)
              {
                controllerGoogleMap = mapController;
                themeMethods.updateMapTheme(controllerGoogleMap!);

                googleMapCompleterController.complete(controllerGoogleMap);

                getCurrentLiveLocationOfDriver();
              },
            ),

            Container(
              height: 136,
              width: double.infinity,
              color: Colors.black54,
            ),

            ///Go online offline button _ Nút Online Offline
            Positioned(
              top: 61,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ElevatedButton(
                    onPressed: ()
                    {
                      showModalBottomSheet(
                        context: context,
                        isDismissible: false,
                        builder: (BuildContext context)
                        {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              boxShadow:
                              [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(
                                    0.7,
                                    0.7,
                                  ),
                                ),
                              ],
                            ),
                            height: 221,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                              child: Column(
                                children: [

                                  const SizedBox(height:  11,),

                                  Text(
                                      (!isDriverAvailable) ? "CHẾ ĐỘ TRỰC TUYẾN" : "CHẾ ĐỘ NGOẠI TUYẾN",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 21,),

                                  Text(
                                      (!isDriverAvailable)
                                        ? "Bạn chuyển sang trực tuyến, bạn sẽ sẵn sàng nhận yêu cầu chuyến đi từ người dùng."
                                        : "Bạn chuyển sang ngoại tuyến, bạn sẽ ngừng nhận yêu cầu chuyến đi mới từ người dùng.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white30,
                                    ),
                                  ),

                                  const SizedBox(height: 25,),

                                  Row(
                                    children: [

                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: ()
                                          {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                              "TRỞ VỀ"
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 16,),

                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: ()
                                          {
                                            if (!isDriverAvailable)
                                            {
                                              ///Go online
                                              goOnlineNow();

                                              ///Get driver location updates
                                              setAndGetLocationUpdates();

                                              Navigator.pop(context);

                                              setState(() {
                                                colorToShow = Colors.pink;
                                                titleToShow = "CHẾ ĐỘ NGOẠI TUYẾN";
                                                isDriverAvailable = true;
                                              });
                                            }
                                            else
                                            {
                                              ///Go offline
                                              goOfflineNow();

                                              Navigator.pop(context);

                                              setState(() {
                                                colorToShow = Colors.green;
                                                titleToShow = "CHẾ ĐỘ TRỰC TUYẾN";
                                                isDriverAvailable = false;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: (titleToShow == "CHẾ ĐỘ TRỰC TUYẾN")
                                                ? Colors.green
                                                : Colors.pink,
                                          ),
                                          child: const Text(
                                              "ĐỒNG Ý"
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),

                                ],
                              ),
                            ),
                          );
                        }
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorToShow,
                    ),
                    child: Text(
                      titleToShow,
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
