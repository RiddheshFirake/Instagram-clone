import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String bio;
  final String email;
  final List followers;
  final List following;
  final String photoUrl;
  final String uid;

  // Named constructor with default values
  User({
    required this.email,
    required this.bio,
    required this.username,
    required this.followers,
    required this.following,
    required this.photoUrl,
    required this.uid,
  });


  // Named constructor for creating a default instance
  User.defaults() :
        email = '',
        bio = '',
        username = 'default blank',
        followers = const [],
        following = const [],
        photoUrl = 'default',
        uid = '';

  Map<String, dynamic> toJson() => {
    'username': username,
    'uid': uid,
    'email': email,
    'bio': bio,
    'followers': followers,
    'following': following,
    'photoUrl': photoUrl,
  };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      bio: snapshot['bio'],
      following: snapshot['following'],
      followers: snapshot['followers'],
    );
  }
}


