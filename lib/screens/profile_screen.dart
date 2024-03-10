import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Utils/colors.dart';
import 'package:instagram_clone/Utils/utils.dart';
import 'package:instagram_clone/resources/auth_resources.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key , required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  var userData;
  var postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }


  getData() async {
    try{

      setState(() {
        isLoading = true;
      });
      var usersnap = await FirebaseFirestore.instance.collection('user').doc(widget.uid).get();
      userData = usersnap.data();
      print(userData);
      followers = usersnap.data()!['followers'].length;
      following = usersnap.data()!['following'].length;

      // Getting post data
      var postSnap = await FirebaseFirestore.instance.collection('posts').where('uid' , isEqualTo: userData['uid']).get();
      postLen = postSnap.docs.length;

      isFollowing = userData['followers'].contains(FirebaseAuth.instance.currentUser!.uid);

    }catch(e){
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? const Center(child: CircularProgressIndicator(color: Colors.white,),) : Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(userData['username']),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(userData['photoUrl']),
                      radius: 40,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen,'posts'),
                              buildStatColumn(followers,'followers'),
                              buildStatColumn(following,'following'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FirebaseAuth.instance.currentUser!.uid == widget.uid ? FollowButton(
                                text: 'Sign Out',
                                backGroundColor: mobileBackgroundColor,
                                textColor: primaryColor,
                                borderColor: Colors.grey,
                                function: () async {
                                  await AuthMethods().signOut();
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
                                },
                              ): isFollowing ? FollowButton(
                                text: 'Unfollow',
                                backGroundColor: mobileBackgroundColor,
                                textColor: primaryColor,
                                borderColor: Colors.grey,
                                function: () async {
                                  await FirestoreMethods().followUser(FirebaseAuth.instance.currentUser!.uid, userData['uid']);
                                  setState(() {
                                    isFollowing = false;
                                    followers--;
                                  });
                                },
                              ): FollowButton(
                                text: 'Follow',
                                backGroundColor: Colors.blue,
                                textColor: Colors.white,
                                borderColor: Colors.blue,
                                function: () async {
                                  await FirestoreMethods().followUser(FirebaseAuth.instance.currentUser!.uid, userData['uid']);
                                  setState(() {
                                    isFollowing = true;
                                    followers++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 15 ),
                  child: Text(userData['username'] , style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 1),
                  child: Text(userData['bio'] , style: TextStyle(fontWeight: FontWeight.normal),),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').where('uid' ,isEqualTo: userData['uid']).get(),
              builder: (context , AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator(color: Colors.white,),);
                }

                return GridView.builder(
                  shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3 , crossAxisSpacing: 5,mainAxisSpacing: 1.5,childAspectRatio: 1),
                    itemBuilder: (context,index){
                    DocumentSnapshot snap = snapshot.data!.docs[index];
                    
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Image(
                        image: NetworkImage(snap['photoUrl']),
                        fit: BoxFit.cover,
                      ),
                    );
                    }
                );
              }
          ),
        ],
      ),
    );
  }
  Column buildStatColumn(int num , String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(num.toString(), style: const TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
        Text(label, style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w400 , color: Colors.grey),)
      ],
    );
  }
}
