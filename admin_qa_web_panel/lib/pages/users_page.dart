import 'package:admin_qa_web_panel/widgets/users_data_list.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';

class UsersPage extends StatefulWidget
{
  static const String id = "\webPageUsers";

  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
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
                  "QUẢN LÝ NGƯỜI DÙNG",
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
                  cMethods.header(2, "ID HÀNH KHÁCH"),
                  cMethods.header(1, "TÊN ĐĂNG NHẬP"),
                  cMethods.header(1, "EMAIL"),
                  cMethods.header(1, "SỐ ĐIỆN THOẠI"),
                  cMethods.header(1, "TRẠNG THÁI"),
                ],
              ),

              //HIỂN THỊ DỮ LIỆU
              UsersDataList(),

            ],
          ),
        ),
      ),
    );
  }
}
