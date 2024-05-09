import 'package:drivers_app/pages/earnings_page.dart';
import 'package:drivers_app/pages/home_page.dart';
import 'package:drivers_app/pages/profile_page.dart';
import 'package:drivers_app/pages/trips_page.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget
{
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin
{
  ///Thanh điều hướng
  TabController? controller;
  int indexSelected = 0;

  onBarItemClicked(int i)
  {
    setState(()
    {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }

  @override
  void initState()
  {
    //TO DO : implement initState
    super.initState();

    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose()
  {
    //TO DO : implement initState
    controller!.dispose();
    super.dispose();
  }

  //Thanh điều hướng
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          HomePage(),
          EarningsPage(),
          TripsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const
        [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Trang chính",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: "Thu nhập",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: "Chuyến đi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Hồ sơ",
          ),
        ],
        currentIndex: indexSelected,
        //backgroundColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.pink,
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
      ),
    );
  }
}
