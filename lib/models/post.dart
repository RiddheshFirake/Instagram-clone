import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String photoUrl;
  final String profImage;
  final String postId;
  final datePublished;
  final likes;

  // Named constructor with default values
  Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.datePublished,
    required this.photoUrl,
    required this.likes,
    required this.profImage,
  });

  // Named constructor for creating a default instance
  Post.defaults() :
        description = '',
        likes = '',
        username = 'default blank',
        profImage = '',
        photoUrl = '',
        datePublished = '',
        uid = '',
        postId = '';

  Map<String, dynamic> toJson() => {
    'username': username,
    'uid': uid,
    'description': description,
    'postId': postId,
    'profImage': profImage,
    'likes': likes,
    'photoUrl': photoUrl,
    'datePublished': datePublished,
  };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      username: snapshot['username'],
      uid: snapshot['uid'],
      description: snapshot['description'],
      photoUrl: snapshot['photoUrl'],
      postId: snapshot['postId'],
      likes: snapshot['likes'],
      datePublished: snapshot['datePublished'],
      profImage: snapshot['profImage'],
    );
  }
}


