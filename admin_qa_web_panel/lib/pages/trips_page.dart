import 'package:admin_qa_web_panel/widgets/trips_data_list.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';

class TripsPage extends StatefulWidget
{
  static const String id = "\webPageTrips";

  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage>
{
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "NHẬT KÝ CHUYẾN ĐI",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              Row(
                children: [
                  cMethods.header(2, "ID CHUYẾN XE"),
                  cMethods.header(1, "KHÁCH HÀNG"),
                  cMethods.header(1, "TÊN TÀI XẾ"),
                  cMethods.header(1, "THÔNG TIN XE"),
                  cMethods.header(1, "THỜI GIAN"),
                  cMethods.header(1, "PHÍ XE"),
                  cMethods.header(1, "CHI TIẾT"),
                ],
              ),

              //HIỂN THỊ DỮ LIỆU
              TripsDataList(),
            ],
          ),
        ),
      ),
    );
  }
}
