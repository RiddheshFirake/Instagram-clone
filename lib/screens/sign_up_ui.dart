import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/Utils/colors.dart';
import 'package:instagram_clone/Utils/utils.dart';
import 'package:instagram_clone/resources/auth_resources.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image ;


  void selectImage() async {
    Uint8List img = await pickupImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(username: _usernameController.text, password: _passwordController.text, bio: _bioController.text, email: _emailController.text , file: _image!);
    print(res);
    if(res == 'Success!'){
      showSnackBar(res, context);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(webScreenLayout: WebScreenLayout(), mobileScreenLayout: MobileScreenLayout()),
      ));
    }
  }


  void navigateToLogin(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,
            child: Column(
              children: [
                Flexible(child: Container() , flex: 2,),

                // SVG img
                SvgPicture.asset('assets/ic_instagram.svg',semanticsLabel: 'InstaLogo', color: primaryColor, height: 64,),
                SizedBox(height: 24,),
                
                // Profile pic
                Stack(
                  children: [
                    _image != null ? CircleAvatar(
                      radius: 54,
                      backgroundImage: MemoryImage(_image!),
                    )
                    : CircleAvatar(
                      radius: 54,
                      backgroundImage: NetworkImage('https://png.pngitem.com/pimgs/s/111-1114675_user-login-person-man-enter-person-login-icon.png'),
                    ),
                    Positioned(child: IconButton(onPressed: () {
                      selectImage();
                    } , icon: Icon(
                        Icons.add_a_photo,
                      size: 34,
                    ),
                    ),
                    bottom: 2,
                    left: 65,)
                  ],
                ),

                SizedBox(height: 24,),
                //textfield for username
                TextFieldInput(hintText: 'Enter Your Username', textEditingController: _usernameController, textInputType: TextInputType.text),
                SizedBox(height: 24,),
                // textfield input
                TextFieldInput(
                  hintText: "Enter Your Email",
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                ),
                SizedBox(height: 24,),

                //textfield for bio
                TextFieldInput(hintText: 'Enter your bio', textEditingController: _bioController, textInputType: TextInputType.text),
                SizedBox(height: 24,),
                // password input
                TextFieldInput(
                    hintText: "Enter Your Password",
                    textInputType: TextInputType.text,
                    textEditingController: _passwordController,
                    isPass: true
                ),
                SizedBox(height: 24,),

                // Sign up button
                InkWell(
                  onTap: signUpUser,
                  child: Container(
                    child: _isLoading ? Center(child: CircularProgressIndicator(color: Colors.white,)) :const Text('Sign Up'),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(4)
                          )
                      ),
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 24,),
                Flexible(child: Container(), flex: 2,),

                // signup navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text('Dont have an account?'),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    GestureDetector(
                      onTap: navigateToLogin,
                      child: Container(
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}
