import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Utils/colors.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/responsive/global_variables.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/models/user.dart' as model;

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
//
//   String Username = '';
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getUsername();
//   }
//
//   void getUsername() async {
//     DocumentSnapshot snap = await FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid).get();
//     print(snap.data());
//
//     setState(() {
//       Username = (snap.data() as Map<String , dynamic>)['username'];
//     });
//
//     // String UserId = FirebaseAuth.instance.currentUser!.uid;
//     // print(UserId);
//
//   }

  int _page = 0;
  late PageController pageController ;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int _page){
    pageController.jumpToPage(_page);
  }

  void onPageChanged(page){
    setState(() {
      _page = page;
    });
  }


  @override
  Widget build(BuildContext context) {

    model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      // body: Center(
      //   child: Text(user.username),
      // ),
      body: PageView(
        children: homeScreenItems,
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled , color: _page == 0 ? primaryColor : secondaryColor ,) , label: '' , backgroundColor: primaryColor),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined, color: _page == 1 ? primaryColor : secondaryColor) , label: '' , backgroundColor: primaryColor),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, color: _page == 2 ? primaryColor : secondaryColor) , label: '' , backgroundColor: primaryColor),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border, color: _page == 3 ? primaryColor : secondaryColor) , label: '' , backgroundColor: primaryColor),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: _page == 4 ? primaryColor : secondaryColor) , label: '' , backgroundColor: primaryColor),
        ],
        onTap: navigationTapped,
      ),
    );;
  }
}
