import 'package:admin_qa_web_panel/methods/common_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DriversDataList extends StatefulWidget
{
  const DriversDataList({super.key});

  @override
  State<DriversDataList> createState() => _DriversDataListState();
}

class _DriversDataListState extends State<DriversDataList>
{
  final driversRecordsFromDatabase = FirebaseDatabase.instance.ref().child("drivers");
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context)
  {
    ///Stream Builder tự động update dữ liệu ko cần refresh
    return StreamBuilder(
      stream: driversRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData)
      {

        ///Báo lỗi khi ko Load data
        if (snapshotData.hasError)
        {
          return const Center(
            child: Text(
              "Xảy ra lỗi. Vui lòng thử lại sau.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.redAccent,
              ),
            ),
          );
        }

        ///Hiển thị thanh loading lúc load
        if (snapshotData.connectionState == ConnectionState.waiting)
        {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        ///Lấy dữ liệu từ Firebase
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
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                ///Thể hiện data ID Tài xế
                cMethods.data(
                  2,
                  Text(itemsList[index]["id"].toString()),
                ),

                ///Thể hiện data Hình Tài xế
                cMethods.data(
                  1,
                  Image.network(
                    itemsList[index]["photo"].toString(),
                    width: 50,
                    height: 50,
                  ),
                ),

                ///Thể hiện data Họ tên Tài xế
                cMethods.data(
                  1,
                  Text(itemsList[index]["name"].toString()),
                ),

                ///Thể hiện data thông tin xe
                cMethods.data(
                  1,
                  Text(itemsList[index]["car_details"]["carModel"].toString()
                      + " - "
                      +(itemsList[index]["car_details"]["carNumber"].toString())),
                ),

                ///Thể hiện data sdt
                cMethods.data(
                  1,
                  Text(itemsList[index]["phone"].toString()),
                ),

                ///Thể hiện data Doanh thu
                cMethods.data(
                  1,
                  itemsList[index]["earnings"] != null ?
                  Text(itemsList[index]["earnings"].toString() + " VNĐ")
                      : const Text("\$ 0"),
                ),

                ///Thể hiện data Trạng thái tài khoản
                cMethods.data(
                  1,
                  itemsList[index]["blockStatus"] == "no" ?
                  ElevatedButton(
                    onPressed: () async
                    {
                      await FirebaseDatabase.instance.ref()
                          .child("drivers")
                          .child(itemsList[index]["id"])
                          .update(
                          {
                            "blockStatus": "yes",
                          });
                    },
                    child: const Text(
                      "Bị khóa",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  )
                      : ElevatedButton(
                    onPressed: () async
                    {
                      await FirebaseDatabase.instance.ref()
                          .child("drivers")
                          .child(itemsList[index]["id"])
                          .update(
                          {
                            "blockStatus": "no",
                          });
                    },
                    child: const Text(
                      "Chấp thuận",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

              ],
            );
          }),
        );
      },
    );
  }
}
