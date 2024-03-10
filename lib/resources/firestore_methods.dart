import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/Utils/utils.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description , Uint8List file , String uid ,String username , String profImage) async{
    String res = 'Some Error occured';
    String postId = const Uuid().v1();
    try{
    String photoUrl = await StorageMethods().uploadImageToStorage('posts', file, true);

    Post post = Post(description: description, uid: uid, username: username, postId: postId, datePublished: DateTime.now(), photoUrl: photoUrl, likes: [], profImage: profImage);

    _firestore.collection('posts').doc(postId).set(post.toJson());
    res = 'Success!';
  }
  catch(e){
    res = e.toString();
}
return res;
}

Future<void> likePost(String postId , String uid , List like) async {
    try{
      if(like.contains(uid)){
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      }
      else{
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    }catch(e){
      print(e.toString());
    }
}
Future<String> storeComments (String name , String uid , String photoUrl , String postId , String text) async {
    String res = 'Some error Occured!';
    print(res);
    print(name);
    print(uid);
    print(photoUrl);
    print(postId);
    print(text);
    try{
      if(text.isNotEmpty){
        String commentId = Uuid().v1();
        await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'profilePic': photoUrl,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now()
        });
        res = 'Success!';
      }
      else{
        print('Text is empty');
        res = 'Text is empty';
      }
    } catch(e){
      print(e.toString());
    }
    return res;
}

Future<String> deletePost(String postId) async {
    String res = 'error occured! ';
    try{
      await _firestore.collection('posts').doc(postId).delete();
      res = 'Successful!';
    }catch(e){
      print(e.toString());
      res = 'Error';
    }
    return res;
}

Future<void> followUser(String uid , String followId) async {
    try{
      DocumentSnapshot snap = await _firestore.collection('user').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if(following.contains(followId)){
        await _firestore.collection('user').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });
        await _firestore.collection('user').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });
      }
      else{
        await _firestore.collection('user').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });
        await _firestore.collection('user').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });
      }
    }
    catch(e){
      print(e.toString());
    }
}

}