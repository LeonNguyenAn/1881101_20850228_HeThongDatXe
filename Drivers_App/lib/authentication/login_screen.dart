import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/methods/common_methods.dart';
import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget
{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  ///Kiểm tra xem điện thoại có mạng internet ko
  CommonMethods cMethods = CommonMethods();
  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signInFormValidation();
  }

  ///Kiểm tra tính hợp lệ Form Đăng nhập tài khoản
  signInFormValidation()
  {
    if (!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Tên đăng nhập không chính xác.", context);
    }
    else if (passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("Mật mã không chính xác.", context);
    }
    else
    {
      //Đăng nhập
      signInUser();
    }
  }

  signInUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Cho phép đăng nhập ..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
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

    //Kiểm tra tài khoản đăng nhập trong Database FireBase
    if (userFirebase != null)
    {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase.uid);
      usersRef.once().then((snap)
      {
        if (snap.snapshot.value != null)
        {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no")
          {
            //userName = (snap.snapshot.value as Map)["name"];
            //Đăng nhập xong trỏ đến HomePage
            Navigator.push(context, MaterialPageRoute(builder: (c) => Dashboard()));
          }
          else
          {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("Tài khoản bị khóa !!!", context);
          }
        }
        else
        {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("Tài khoản không tồn tại !!!", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [

              const SizedBox(
                height: 50,
              ),

              //Logo User App
              Image.asset(
                  "assets/images/uberexec.png",
                width: 220,
              ),

              const SizedBox(height: 30,),

              const Text(
                "Đăng nhập tài khoản",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),
              ),

              //Text feilds + button
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [

                    //Dòng Email người dùng
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Email người dùng",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          height: 2,
                      ),
                    ),

                    const SizedBox(height: 20,),

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
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          height: 2
                      ),
                    ),

                    const SizedBox(height: 32,),

                    //Nút Đăng nhập
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
                          "Đăng nhập"
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 12,),

              //Text Button
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => SignUpScreen()));
                },
                child: const Text(
                  "Bạn chưa có tài khoản ? Đăng ký ở đây",
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
