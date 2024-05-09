import 'dart:js_util';

import 'package:admin_qa_web_panel/widgets/drivers_data_list.dart';
import 'package:flutter/material.dart';
import '../methods/common_methods.dart';

class DriversPage extends StatefulWidget
{
  static const String id = "\webPageDrivers";

  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage>
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
                  "QUẢN LÝ TÀI XẾ",
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
                  cMethods.header(2, "ID TÀI XẾ"),
                  cMethods.header(1, "ẢNH ĐẠI DIỆN"),
                  cMethods.header(1, "HỌ VÀ TÊN"),
                  cMethods.header(1, "THÔNG TIN XE"),
                  cMethods.header(1, "SỐ ĐIỆN THOẠI"),
                  cMethods.header(1, "DOANH THU"),
                  cMethods.header(1, "TRẠNG THÁI"),
                ],
              ),

              //HIỂN THỊ DỮ LIỆU
              DriversDataList(),
            ],
          ),
        ),
      ),
    );
  }
}
