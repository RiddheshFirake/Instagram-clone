import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard({super.key , required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String? _username;


  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getUserDetails() async {
    try {
      // Accessing comment data directly
      String commentUid = widget.snap['uid'];

      // Fetching comment author's details
      DocumentSnapshot userSnap = await firestore.collection('user').doc(commentUid).get();

      if (userSnap.exists) {
        // Accessing user data from the DocumentSnapshot
        Map<String, dynamic>? userData = userSnap.data() as Map<String, dynamic>?;

        if (userData != null) {
          // Access specific fields from userData
          String? username = userData['username'];
          String? email = userData['email'];

          // Print or use the retrieved data
          print('Username: $username');
          print('Email: $email');
          setState(() {
            _username = username!;
          });
        } else {
          print('User data is null.');
        }
      } else {
        print('User document does not exist in Firestore.');
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10 ,horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.snap['profilePic']),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding:const EdgeInsets.only(left: 16),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '${widget.snap['name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: widget.snap['text'],
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ),
                  Padding(
                    padding:const EdgeInsets.only(left: 0),
                    child: Text(DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()), style: const TextStyle(fontSize:11 , fontWeight: FontWeight.w400),),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
            ),
          ),
        ],
      ),
    );
  }
}
