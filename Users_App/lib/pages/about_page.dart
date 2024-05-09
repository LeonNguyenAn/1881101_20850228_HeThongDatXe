import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget
{
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đồ án Chuyên Đề Thiết Kế Phần Mềm",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: ()
          {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.grey,),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(80),
          child: Column(
            children: [

              Image.asset(
                "assets/images/QA_Logo.png",
              ),

              const SizedBox(
                height: 20,
              ),

              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  "Hệ thống điều phối xe",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "1881101 _ Nguyễn Bảo An",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "20850228 _ Nguyễn Lê Nhật Quang",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),

            ],
          ),
        ),

      ),
    );
  }
}
