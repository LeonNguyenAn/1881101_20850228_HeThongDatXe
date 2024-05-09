import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget
{
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
{
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  ///Kiểm tra xem điện thoại có mạng internet ko
  CommonMethods cMethods = CommonMethods();
  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signUpFormValidation();
  }

  ///Kiểm tra tính hợp lệ Form Đăng ký tài khoản
  signUpFormValidation()
  {
    if (userNameTextEditingController.text.trim().length < 3)
    {
      cMethods.displaySnackBar("Tên đăng nhập từ 4 ký tự trở lên.", context);
    }
    else if (userPhoneTextEditingController.text.trim().length < 9)
    {
      cMethods.displaySnackBar("Số điện thoại từ 10 số trở lên.", context);
    }
    else if (!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Nhập Email hợp lệ.", context);
    }
    else if (passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("Mật mã từ 5 ký tự trở lên.", context);
    }
    else
    {
      ///register user
      registerNewUser();
    }
  }

  registerNewUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Đăng ký tài khoản của bạn ..."),
    );

    final User? userFirebase = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      ).catchError((errorMsg)
      {
        Navigator.pop(context);
        cMethods.displaySnackBar(errorMsg.toString(), context);
      })
    ).user;

    if (!context.mounted) return;
    Navigator.pop(context);

    ///Thêm tài khoản vào Database FireBase
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap =
    {
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    usersRef.set(userDataMap);

    ///Đăng ký xong trỏ đến HomePage
    Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [

              //Logo User App
              Image.asset(
                "assets/images/QA_Logo.png"
              ),

              const SizedBox(height: 15,),

              const Text(
                "Đăng ký tài khoản",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 0.5,
                ),
              ),

              //Text feilds + button (Các dòng phía dưới Logo)
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [

                    //Dòng Tên đăng ký
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Tên người dùng",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        height: 2,
                      ),
                    ),

                    const SizedBox(height: 15,),

                    //Dòng Số Điện Thoại
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          height: 2,
                      ),
                    ),

                    const SizedBox(height: 15,),

                    //Dòng Email người dùng
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email người dùng",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          height: 2,
                      ),
                    ),

                    const SizedBox(height: 15,),

                    //Dòng Mật khẩu
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Mật khẩu",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          height: 2,
                      ),
                    ),

                    const SizedBox(height: 25),

                    //Nút Đăng ký
                    ElevatedButton(
                      onPressed: ()
                      {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      ),
                      child: const Text(
                        "Đăng ký",
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 1,),

              //Text Button
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: const Text(
                  "Bạn đã có tài khoản chưa ? Đăng nhập ở đây",
                  style: TextStyle(
                    color: Colors.white,

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
