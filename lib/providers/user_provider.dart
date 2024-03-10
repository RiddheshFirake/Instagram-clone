import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/auth_resources.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser {
    return _user ?? User.defaults();
  }


  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;

    print('Refreshed user: $user');

    notifyListeners();
  }

}

