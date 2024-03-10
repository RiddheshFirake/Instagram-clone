import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StorageMethods{
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Adding file to storage

  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost) async {


    // ref() is a pointer to the storage in firebaseStorage and child means folders to create
    Reference ref =  _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if(isPost){
      String id = Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snap = await uploadTask;

    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }

}