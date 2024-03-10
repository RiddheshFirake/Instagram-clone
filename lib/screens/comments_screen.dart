import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Utils/colors.dart';
import 'package:instagram_clone/Utils/utils.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  final snap;
  const CommentsScreen({super.key, required this.snap});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {

  String? _username;
  String? _photoUrl;
  bool _isLoading = false;

  TextEditingController _commentController = TextEditingController();


  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getUserDetails() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userSnap = await firestore.collection('user').doc(user.uid).get();

        if (userSnap.exists) {
          // Accessing user data from the DocumentSnapshot
          Map<String, dynamic>? userData = userSnap.data() as Map<String, dynamic>?;

          if (userData != null) {
            // Access specific fields from userData
            String? username = userData['username'];
            String? photoUrl = userData['photoUrl'];

            // Print or use the retrieved data
            print('Username: $username');
            print('PhotoUrl: $photoUrl');
            setState(() {
              _username = username!;
              _photoUrl = photoUrl;
            });
          } else {
            print('User data is null.');
          }
        } else {
          print('User document does not exist in Firestore.');
        }
      } else {
        print('No user signed in.');
      }
    } catch (e) {
      print('Error getting user details: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _commentController.dispose();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy('datePublished' , descending: true)// Accessing the 'comments' subcollection
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white,),);
          }

          // Access the comments directly using snapShot.data.docs
          List<QueryDocumentSnapshot<Map<String, dynamic>>> comments = snapShot.data?.docs ?? [];
          int com_len = comments.length;

          return ListView.builder(
            itemCount: com_len,
            itemBuilder: (context, index) {
              // Use CommentCard with comments[index].data()
              Map<String, dynamic>?
              commentData = comments[index].data();
              if (commentData != null) {
                print(com_len);
                if(com_len == 0){
                  return const Center(child: Text('Error Occured!'),);
                }
                else{
                  return CommentCard(
                    snap: snapShot.data!.docs[index],
                  );
                }
              } else {
                return const Center(child: Text('Error Occured!'),); // Handle the case where comment data is null
              }
            },
          );
        },
      ),


      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: EdgeInsets.only(left: 16 , right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage('$_photoUrl'),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16 , right: 8),
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${_username}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  String res = await FirestoreMethods().storeComments(_username!, widget.snap['uid'], _photoUrl!, widget.snap['postId'], _commentController.text);
                  print('%%%%%%%%%%%%%%%%%%%%%%%%%${widget.snap['username']}');
                  if(res == 'Success!'){
                    setState(() {
                      _isLoading = false;
                      _commentController.text = "";
                    });
                    showSnackBar('Comment Posted Successfully!', context);
                  }
                  else{
                    setState(() {
                      _isLoading = false;
                    });
                    showSnackBar('Some Error Occured!', context);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 8),
                  child: _isLoading? CircularProgressIndicator(color: Colors.white,):Text(
                      'Post',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
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
