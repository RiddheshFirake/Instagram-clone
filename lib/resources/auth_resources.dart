import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _Firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User _user = _auth.currentUser!;

    DocumentSnapshot snap = await _Firestore.doc('user').get();

    return model.User.fromSnap(snap);
  }

  // sign up user

  Future<String> signUpUser({
    required String username,
    required String password,
    required String bio,
    required String email,
    required Uint8List file,
  }) async {
    try {
      if (email.isNotEmpty && username.isNotEmpty && password.isNotEmpty && bio.isNotEmpty && file.isNotEmpty) {
        // register the user in firebase
        UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

        // Check if the user is not null before accessing uid
        if (credential.user != null) {
          print("User ID: ${credential.user!.uid}");

          String photoUrl = await StorageMethods().uploadImageToStorage('ProfilePics', file, false);

          model.User user = model.User(
            username: username,
            uid: credential.user!.uid,
            email: email,
            bio: bio,
            followers: [],
            following: [],
            photoUrl: photoUrl,
          );

          // add user to our database
          await _Firestore.collection('user').doc(credential.user!.uid).set(user.toJson()!,);

          return 'Success!';
        } else {
          return 'User is null';
        }
      } else {
        return 'All fields are required';
      }
    } catch (error) {
      // Print or log the detailed error information
      print("Error during sign-up: $error");

      // Return a custom error message or use error.toString() for a general message
      return 'An error occurred during sign-up';
    }
  }


  // LOGIN FUNCTION
  Future<String> loginUser({required String email, required String password}) async{
    String res = 'An error Occured';
    try{
      if(email.isNotEmpty || password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = 'Success!';
      }
      else{
        res = 'Enter all fields';
      }
    }
    catch(err){
      res = err.toString();
    }
    //print(res);
    return res;

  }
  Future<void> signOut() async {
    await _auth.signOut();
    }

}