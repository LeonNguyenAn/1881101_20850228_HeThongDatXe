import 'dart:math';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/methods/common_methods.dart';
import 'package:drivers_app/pages/dashboard.dart';
import 'package:drivers_app/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();

  XFile? imageFile;
  String urlOfUploadedImage = "";

  //Kiểm tra xem điện thoại có mạng internet ko
  CommonMethods cMethods = CommonMethods();
  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    if (imageFile != null) //Kiểm tra ảnh Avatar
    {
      signUpFormValidation();
    }
    else
    {
      cMethods.displaySnackBar("Chọn ảnh Avatar trước.", context);
    }
  }

  //Kiểm tra tính hợp lệ Form Đăng ký tài khoản
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
    else if (vehicleModelTextEditingController.text.trim().isEmpty)
    {
      cMethods.displaySnackBar("Nhập loại xe.", context);
    }
    else if (vehicleColorTextEditingController.text.trim().isEmpty)
    {
      cMethods.displaySnackBar("Nhập màu sắc của xe.", context);
    }
    else if (vehicleNumberTextEditingController.text.isEmpty)
    {
      cMethods.displaySnackBar("Nhập biển số xe.", context);
    }
    else
    {
      uploadImageToStorage();
    }
  }

  //Lưu ảnh avatar vào Firebase
  uploadImageToStorage() async
  {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });

    //register user
    registerNewDriver();
  }

  //Đăng ký tài khoản
  registerNewDriver() async
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

    //Thêm tài khoản vào Database FireBase
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);

    Map driverCarInfo =
    {
      "carColor" : vehicleColorTextEditingController.text.trim(),
      "carModel" : vehicleModelTextEditingController.text.trim(),
      "carNumber" : vehicleNumberTextEditingController.text.trim(),
    };

    Map driverDataMap =
    {
      "photo": urlOfUploadedImage,
      "car_details" : driverCarInfo,
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    usersRef.set(driverDataMap);

    //Đăng ký xong trỏ đến HomePage
    Navigator.push(context, MaterialPageRoute(builder: (c) => Dashboard()));
  }

  //Chọn hình Avatar
  chooseImageFromGallery() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null)
    {
      setState(() {
        imageFile = pickedFile;
      });
    }
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

              const SizedBox(
                height: 10 ,
              ),

              //Avartar tài xế
              imageFile == null ?

              const CircleAvatar(
                radius: 86,
                backgroundImage: AssetImage("assets/images/avatarman.png"),
              ) : Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: FileImage(
                      File(
                        imageFile!.path
                      ),
                    )
                  )
                ),
              ),

              const SizedBox(
                height: 10 ,
              ),

              //Upload ảnh Avartar
              GestureDetector(
                onTap: ()
                {
                  chooseImageFromGallery();
                },
                child: const Text(
                  "Đổi ảnh",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              //Text feilds + button (Các dòng phía dưới Logo)
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [

                    //Dòng Tên đăng nhập
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

                    TextField(
                      controller: vehicleModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Loại xe",
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

                    TextField(
                      controller: vehicleColorTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Màu xe",
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

                    TextField(
                      controller: vehicleNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Biển số xe",
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
                        "Đăng ký"
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 5,),

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
