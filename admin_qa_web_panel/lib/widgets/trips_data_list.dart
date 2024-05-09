import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../methods/common_methods.dart';

class TripsDataList extends StatefulWidget
{
  const TripsDataList({super.key});

  @override
  State<TripsDataList> createState() => _TripsDataListState();
}

class _TripsDataListState extends State<TripsDataList>
{
  final completedTripsRecordsFromDatabase = FirebaseDatabase.instance.ref().child("tripRequests");
  CommonMethods cMethods = CommonMethods();


  launchGoogleMapFromSourceToDestination(pickUpLat, pickUpLng, dropOffLat, dropOffLng,) async
  {
    String directionAPIUrl = "https://www.google.com/maps/dir/?api=1&origin=$pickUpLat,$pickUpLng&destination=$dropOffLat,$dropOffLng&dir_action=navigate";

    if (await canLaunchUrl(Uri.parse(directionAPIUrl)))
    {
      await launchUrl(Uri.parse(directionAPIUrl));
    }
    else
    {
      throw "Không thể truy cập Google Map";
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return StreamBuilder(
      stream: completedTripsRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData)
      {
        if (snapshotData.hasError)
        {
          return const Center(
            child: Text(
              "Xảy ra lỗi.Vui lòng thử lại sau.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.pink,
              ),
            ),
          );
        }

        if (snapshotData.connectionState == ConnectionState.waiting)
        {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List itemsList = [];
        dataMap.forEach((key, value)
        {
          itemsList.add({"key": key, ...value});
        });

        return ListView.builder(
          shrinkWrap: true,
          itemCount: itemsList.length,
          itemBuilder: ((context, index)
          {
            ///Lấy dữ liệu từ firebase, trong triprequest -> status == ended
            if (itemsList[index]["status"] != null && itemsList[index]["status"] == "ended")
            {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  cMethods.data(
                    2,
                    Text(itemsList[index]["tripID"].toString()),
                  ),

                  cMethods.data(
                    1,
                    Text(itemsList[index]["userName"].toString()),
                  ),

                  cMethods.data(
                    1,
                    Text(itemsList[index]["driverName"].toString()),
                  ),

                  cMethods.data(
                    1,
                    Text(itemsList[index]["carDetails"].toString()),
                  ),

                  cMethods.data(
                    1,
                    Text(itemsList[index]["publishDateTime"].toString()),
                  ),

                  cMethods.data(
                    1,
                    Text("\$ " + itemsList[index]["fareAmount"].toString()),
                  ),

                  cMethods.data(
                    1,
                    ElevatedButton(
                      onPressed: ()
                      {
                        String pickUpLat = itemsList[index]["pickUpLatLng"]["latitude"];
                        String pickUpLng = itemsList[index]["pickUpLatLng"]["longitude"];

                        String dropOffLat = itemsList[index]["dropOffLatLng"]["latitude"];
                        String dropOffLng = itemsList[index]["dropOffLatLng"]["longitude"];

                        launchGoogleMapFromSourceToDestination(
                          pickUpLat,
                          pickUpLng,
                          dropOffLat,
                          dropOffLng,
                        );
                      },
                      child: const Text(
                        "Xem thêm",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                ],
              );
            }
            else
            {
              return Container();
            }
          }),
        );
      },
    );
  }
}
