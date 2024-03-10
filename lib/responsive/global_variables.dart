import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/add_post_screen.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';

const webScreenLayout = 600;

final homeScreenItems = [
  FeedScreen(),
  SearchScreen(),
  AddPostscreen(),
  Text('notification'),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
];