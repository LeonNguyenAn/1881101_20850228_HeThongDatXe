import 'dart:async';
import 'package:drivers_app/methods/common_methods.dart';
import 'package:drivers_app/methods/map_theme_methods.dart';
import 'package:drivers_app/models/trip_details.dart';
import 'package:drivers_app/widgets/payment_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/global_var.dart';
import '../widgets/loading_dialog.dart';


class NewTripPage extends StatefulWidget
{
  TripDetails? newTripDetailsInfo;

  NewTripPage({super.key, this.newTripDetailsInfo,});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage>
{
  ///Nhúng Google Map vô
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  MapThemeMethods themeMethods = MapThemeMethods();
  double googleMapPaddingFromBottom = 0;
  List<LatLng> coordinatesPolylineLatLngList = [];

  ///Vẽ hành trình của tài xế từ điểm đón -> điểm đến
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circlesSet = Set<Circle>();
  Set<Polyline> polyLinesSet = Set<Polyline>();
  BitmapDescriptor? carMarkerIcon;

  ///Cập nhật thông tin chi tiết chuyến đi
  bool directionRequested = false;
  String statusOfTrip = "accepted";
  String durationText = "", distanceText = "";
  String buttonTitleText = "ARRIVED";
  Color buttonColor = Colors.indigoAccent;

  ///End trip
  CommonMethods cMethods = CommonMethods();

  ///Icon Tracking
  makeMarker()
  {
    if (carMarkerIcon == null)
    {
      ImageConfiguration configuration = createLocalImageConfiguration(context, size: Size(2, 2));

      BitmapDescriptor.fromAssetImage(configuration, "assets/images/tracking.png")
          .then((valueIcon)
      {
        carMarkerIcon = valueIcon;
      });
    }
  }

  ///Vẽ hành trình của tài xế từ điểm đón -> điểm đến
  obtainDirectionAndDrawRoute(sourceLocationLatLng, destinationLocationLatLng) async
  {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageText: 'Vui lòng chờ...',)
    );

    var tripDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
        sourceLocationLatLng,
        destinationLocationLatLng
    );

    Navigator.pop(context);

    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPoints = pointsPolyline.decodePolyline(tripDetailsInfo!.encodedPoints!);

    coordinatesPolylineLatLngList.clear();

    if (latLngPoints.isNotEmpty)
    {
      latLngPoints.forEach((PointLatLng pointLatLng)
      {
        coordinatesPolylineLatLngList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    ///Draw polyline _ Vẽ hành trình đón khách từ điểm đón -> điểm đến
    polyLinesSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          polylineId: const PolylineId("routeID"),
          color: Colors.amber,
          points: coordinatesPolylineLatLngList,
          jointType: JointType.round,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true
      );

      polyLinesSet.add(polyline);
    });

    ///Fit the polyline on google map
    LatLngBounds boundsLatLng;

    if (sourceLocationLatLng.latitude > destinationLocationLatLng.latitude
        && sourceLocationLatLng.longitude > destinationLocationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: destinationLocationLatLng,
        northeast: sourceLocationLatLng,
      );
    }
    else if (sourceLocationLatLng.longitude > destinationLocationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(sourceLocationLatLng.latitude, destinationLocationLatLng.longitude),
        northeast: LatLng(destinationLocationLatLng.latitude, sourceLocationLatLng.longitude),
      );
    }
    else if (sourceLocationLatLng.latitude > destinationLocationLatLng.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLocationLatLng.latitude, sourceLocationLatLng.longitude),
        northeast: LatLng(sourceLocationLatLng.latitude, destinationLocationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(
        southwest: sourceLocationLatLng,
        northeast: destinationLocationLatLng,
      );
    }

    controllerGoogleMap!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    ///Add marker _ Thêm icon điểm đón, điểm đến
    Marker sourceMarker = Marker(
      markerId: const MarkerId('sourceID'),
      position: sourceLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationID'),
      position: destinationLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(sourceMarker);
      markersSet.add(destinationMarker);
    });

    ///Add circle _ Thêm icon điểm tròn cho điểm đón, điểm đến
    Circle sourceCircle = Circle(
      circleId: const CircleId('sourceCircleID'),
      strokeColor: Colors.orange,
      strokeWidth: 4,
      radius: 14,
      center: sourceLocationLatLng,
      fillColor: Colors.green,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId('destinationCircleID'),
      strokeColor: Colors.green,
      strokeWidth: 4,
      radius: 14,
      center: destinationLocationLatLng,
      fillColor: Colors.orange,
    );

    setState(() {
      circlesSet.add(sourceCircle);
      circlesSet.add(destinationCircle);
    });
  }

  ///Cập nhật trực tiếp vị trí của tài xế
  getLiveLocationUpdatesOfDriver()
  {
    LatLng lastPositionLatLng = LatLng(0, 0);

    positionStreamNewTripPage = Geolocator.getPositionStream().listen((Position positionDriver)
    {
      driverCurrentPosition = positionDriver;

      LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      Marker carMarker = Marker(
        markerId: const MarkerId("carMarkerID"),
        position: driverCurrentPositionLatLng,
        icon: carMarkerIcon!,
        infoWindow: const InfoWindow(title: "My Location"),
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: driverCurrentPositionLatLng, zoom: 16);
        controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet.removeWhere((element) => element.markerId.value == "carMarkerID");
        markersSet.add(carMarker);
      });

      lastPositionLatLng = driverCurrentPositionLatLng;

      ///Update Trip Details Information _ Cập nhật thông tin chi tiết chuyến đi
      updateTripDetailsInformation();

      ///Update driver location to tripRequest _ Cập nhật vị trí của tài xế trong yêu cầu chuyến đi
      Map updatedLocationOfDriver =
      {
        "latitude": driverCurrentPosition!.latitude,
        "longitude": driverCurrentPosition!.longitude,
      };
      FirebaseDatabase.instance.ref().child("tripRequests")
          .child(widget.newTripDetailsInfo!.tripID!)
          .child("driverLocation")
          .set(updatedLocationOfDriver);
    });
  }

  ///Cập nhật thông tin chi tiết chuyến đi
  updateTripDetailsInformation() async
  {
    if(!directionRequested)
    {
      directionRequested = true;

      if(driverCurrentPosition == null)
      {
        return;
      }

      var driverLocationLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      LatLng dropOffDestinationLocationLatLng;
      if(statusOfTrip == "accepted")
      {
        dropOffDestinationLocationLatLng = widget.newTripDetailsInfo!.pickUpLatLng!;
      }
      else
      {
        dropOffDestinationLocationLatLng = widget.newTripDetailsInfo!.dropOffLatLng!;
      }

      var directionDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(driverLocationLatLng, dropOffDestinationLocationLatLng);

      if(directionDetailsInfo != null)
      {
        directionRequested = false;

        setState(() {
          durationText = directionDetailsInfo.durationTextString!;
          distanceText = directionDetailsInfo.distanceTextString!;
        });
      }
    }
  }

  ///Kết thúc chuyến đi của tài xế
  endTripNow() async
  {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: 'Vui lòng chờ...',),
    );

    var driverCurrentLocationLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    var directionDetailsEndTripInfo = await CommonMethods.getDirectionDetailsFromAPI(
      widget.newTripDetailsInfo!.pickUpLatLng!, ///Pickup
      driverCurrentLocationLatLng, ///Destination
    );

    Navigator.pop(context);

    String fareAmount = (cMethods.calculateFareAmount(directionDetailsEndTripInfo!)).toString();

    await FirebaseDatabase.instance.ref().child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("fareAmount").set(fareAmount);

    await FirebaseDatabase.instance.ref().child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("status").set("ended");

    positionStreamNewTripPage!.cancel();

    ///Dialog for collecting fare amount _ Bảng hiện ra tiền cước chuyến đi
    displayPaymentDialog(fareAmount);

    ///Save fare amount to driver total earnings _ Lưu lại tiền cước chuyến đi của tài xế
    saveFareAmountToDriverTotalEarnings(fareAmount);
  }

  ///Hiển thị khung thanh toán
  displayPaymentDialog(fareAmount)
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => PaymentDialog(fareAmount: fareAmount),
    );
  }

  ///Lưu lại tiền cước chuyến đi của tài xế
  saveFareAmountToDriverTotalEarnings(String fareAmount) async
  {
    DatabaseReference driverEarningsRef = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("earnings");

    await driverEarningsRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
      {
        double previousTotalEarnings = double.parse(snap.snapshot.value.toString());
        double fareAmountForTrip = double.parse(fareAmount);

        double newTotalEarnings = previousTotalEarnings + fareAmountForTrip;

        driverEarningsRef.set(newTotalEarnings);
      }
      else
      {
        driverEarningsRef.set(fareAmount);
      }
    });
  }

  ///Lưu lại dữ liệu tài xế vô tripRequest trên Firebase
  saveDriverDataToTripInfo() async
  {
    Map<String, dynamic> driverDataMap =
    {
      "status": "accepted",
      "driverID": FirebaseAuth.instance.currentUser!.uid,
      "driverName": driverName,
      "driverPhone": driverPhone,
      "driverPhoto": driverPhoto,
      "carDetails": carColor + " - " + carModel + " - " + carNumber,
    };

    Map<String, dynamic> driverCurrentLocation =
    {
      'latitude': driverCurrentPosition!.latitude.toString(),
      'longitude': driverCurrentPosition!.longitude.toString(),
    };

    await FirebaseDatabase.instance.ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .update(driverDataMap);

    await FirebaseDatabase.instance.ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("driverLocation").update(driverCurrentLocation);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    saveDriverDataToTripInfo();
  }

  @override
  Widget build(BuildContext context)
  {
    makeMarker();

    return Scaffold(
      body: Stack(
        children: [

          ///Google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: googleMapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationEnabled: true,
            markers: markersSet,
            circles: circlesSet,
            polylines: polyLinesSet,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) async
            {
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                googleMapPaddingFromBottom = 262;
              });

              var driverCurrentLocationLatLng = LatLng(
                  driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude
              );

              var userPickUpLocationLatLng = widget.newTripDetailsInfo!.pickUpLatLng;

              await obtainDirectionAndDrawRoute(driverCurrentLocationLatLng, userPickUpLocationLatLng);

              getLiveLocationUpdatesOfDriver();
            },
          ),

          ///Trip details _ Thông tin chi tiết chuyến đi của tài xế
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(topRight: Radius.circular(17), topLeft: Radius.circular(17)),
                boxShadow:
                [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 17,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: 256,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    ///Trip duration _ Khoảng cách + Thời gian di chuyển giữa tài xế đến khách hàng
                    Center(
                      child: Text(
                        durationText + " - " + distanceText,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5,),

                    ///User name - call user icon btn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        ///User name
                        Text(
                          widget.newTripDetailsInfo!.userName!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        ///Call user icon btn
                        GestureDetector(
                          onTap: ()
                          {
                            launchUrl(
                              Uri.parse(
                                  "tel://${widget.newTripDetailsInfo!.userPhone.toString()}"
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.phone_android_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 15,),

                    ///Pickup icon and location
                    Row(
                      children: [

                        Image.asset(
                          "assets/images/initial.png",
                          height: 16,
                          width: 16,
                        ),

                        Expanded(
                          child: Text(
                            widget.newTripDetailsInfo!.pickupAddress.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 15,),

                    ///Dropoff icon and location
                    Row(
                      children: [

                        Image.asset(
                          "assets/images/final.png",
                          height: 16,
                          width: 16,
                        ),

                        Expanded(
                          child: Text(
                            widget.newTripDetailsInfo!.dropOffAddress.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 25,),

                    Center(
                      child: ElevatedButton(
                        onPressed: () async
                        {
                          ///Arrived button
                          if(statusOfTrip == "accepted")
                          {
                            setState(() {
                              buttonTitleText = "BẮT ĐẦU";
                              buttonColor = Colors.green;
                            });

                            statusOfTrip = "arrived";

                            FirebaseDatabase.instance.ref()
                                .child("tripRequests")
                                .child(widget.newTripDetailsInfo!.tripID!)
                                .child("status").set("arrived");

                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) => LoadingDialog(messageText: 'Vui lòng chờ...',)
                            );

                            await obtainDirectionAndDrawRoute(
                              widget.newTripDetailsInfo!.pickUpLatLng,
                              widget.newTripDetailsInfo!.dropOffLatLng,
                            );

                            Navigator.pop(context);
                          }
                          ///Start trip button
                          else if(statusOfTrip == "arrived")
                          {
                            setState(() {
                              buttonTitleText = "ĐẾN NƠI";
                              buttonColor = Colors.amber;
                            });

                            statusOfTrip = "ontrip";

                            FirebaseDatabase.instance.ref()
                                .child("tripRequests")
                                .child(widget.newTripDetailsInfo!.tripID!)
                                .child("status").set("ontrip");
                          }
                          ///End trip button
                          else if(statusOfTrip == "ontrip")
                          {
                            ///End the trip
                            endTripNow();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        child: Text(
                          buttonTitleText,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
