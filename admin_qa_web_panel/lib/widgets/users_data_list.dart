import 'package:admin_qa_web_panel/methods/common_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UsersDataList extends StatefulWidget
{
  const UsersDataList({super.key});

  @override
  State<UsersDataList> createState() => _UsersDataListState();
}

class _UsersDataListState extends State<UsersDataList>
{
  final usersRecordsFromDatabase = FirebaseDatabase.instance.ref().child("users");
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context)
  {
    ///Stream Builder tự động update dữ liệu ko cần refresh
    return StreamBuilder(
      stream: usersRecordsFromDatabase.onValue,
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

                ///Thể hiện data ID Khách hàng
                cMethods.data(
                  2,
                  Text(itemsList[index]["id"].toString()),
                ),

                ///Thể hiện data Họ tên khách hàng
                cMethods.data(
                  1,
                  Text(itemsList[index]["name"].toString()),
                ),

                ///Thể hiện data email khách hàng
                cMethods.data(
                  1,
                  Text(itemsList[index]["email"].toString()),
                ),

                ///Thể hiện data sdt
                cMethods.data(
                  1,
                  Text(itemsList[index]["phone"].toString()),
                ),

                ///Thể hiện data Trạng thái tài khoản
                cMethods.data(
                  1,
                  itemsList[index]["blockStatus"] == "no" ?
                  ElevatedButton(
                    onPressed: () async
                    {
                      await FirebaseDatabase.instance.ref()
                          .child("users")
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
                          .child("users")
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
