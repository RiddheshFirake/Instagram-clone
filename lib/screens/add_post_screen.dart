import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/Utils/colors.dart';
import 'package:instagram_clone/Utils/utils.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/auth_resources.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';
import 'package:provider/provider.dart';

class AddPostscreen extends StatefulWidget {
  const AddPostscreen({super.key});

  @override
  State<AddPostscreen> createState() => _AddPostscreenState();
}

class _AddPostscreenState extends State<AddPostscreen> {

  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  String ProfPic = '';
  String Uid = '';
  String Username = '';
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    inputData();
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  clearImage() {
    setState(() {
      _file = null;
    });
  }

  void postImage(
      String uid,
      String username,
      String profImage,
      ) async {
    setState(() {
      _isLoading = true;
    });
    try{
      String res = await FirestoreMethods().uploadPost(_descriptionController.text, _file!, uid, username, profImage,);

      if(res == "Success!"){
        setState(() {
          _isLoading = false;
        });
        showSnackBar('Posted!', context);
        clearImage();
      }
      else{
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    }catch (e) {
      showSnackBar(e.toString(), context);
    }
  }


  _addDialogBox(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select an option'),
          children: [
            SimpleDialogOption(
              child: const Text('Take a Photo'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickupImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              child: const Text('Choose from gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickupImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }



  Future<void> inputData() async {
    final Auth.FirebaseAuth auth = Auth.FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      Auth.User? user = auth.currentUser;

      if (user != null) {
        final uid = user.uid;

        // Fetch user data from Firestore
        DocumentSnapshot userSnapshot = await firestore.collection('user').doc(uid).get();

        if (userSnapshot.exists) {
          // Retrieve the 'photoUrl' field from the document
          String photoUrl = userSnapshot['photoUrl'] ?? ''; // Use an empty string if 'photoUrl' is not present
          String username = userSnapshot['username'] ?? ''; // Use an empty string if 'photoUrl' is not present
          String uid = userSnapshot['uid'] ?? ''; // Use an empty string if 'photoUrl' is not present
          setState(() {
            ProfPic = photoUrl;
            Username = username;
            Uid = uid;
          });

          // Now, you have the 'photoUrl' for the current user
          print('Photo URL for the current user: $photoUrl');
        } else {
          print('User document does not exist in Firestore.');
        }
      } else {
        print('No user signed in.');
      }
    } catch (e) {
      print('Error retrieving data from Firestore: $e');
    }
  }



  @override
  Widget build(BuildContext context) {





    final User user = Provider.of<UserProvider>(context).getUser;


    print('======================================================================================$ProfPic');

    return _file == null ? Center(
      child: IconButton(
        icon: Icon(Icons.upload_outlined),
        onPressed: () => _addDialogBox(context) ,
      ),
    )

    :
    Scaffold(
      appBar: AppBar(
        title: const Text('Post to'),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: clearImage
        ),
        backgroundColor: mobileBackgroundColor,
        actions: [
          TextButton(onPressed: () => postImage(Uid, Username, ProfPic),
              child: Text('Post', style: TextStyle(color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),))
        ],
      ),
      body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading ? const LinearProgressIndicator() : Container(),
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
      CircleAvatar(
      backgroundImage: NetworkImage(ProfPic),
    ),
    SizedBox(
    width: MediaQuery.of(context).size.width*0.45,
    height: 105,
    child: TextField(
      controller: _descriptionController,
    decoration: InputDecoration(
    hintText: 'Enter the Description...',
    border: InputBorder.none,
    ),
    maxLines: 8,
    ),
    ),
    SizedBox(
    height: 45,
    width: 45,
    child: AspectRatio(
    aspectRatio: 487/451,
    child: Container(
    decoration: BoxDecoration(
    image: DecorationImage(image: MemoryImage(_file!),
    fit: BoxFit.fill,
    alignment: FractionalOffset.topCenter)
    ),
    ),
    ),
    ),
            const Divider(
              thickness: 12.0,
              color: Colors.white,
            ),
    ],
    ),
    ]
    ,
    ),
    );
  }
}
