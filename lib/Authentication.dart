import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

class Authenticate {
  static final Authenticate _authenticate = Authenticate._internal();

  Authenticate._internal();

  factory Authenticate() {
    return _authenticate;
  }

  final FacebookLogin fbLogin = FacebookLogin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User currentUser() {
    print("loading: ${_auth.currentUser}");
    return _auth.currentUser;
  }

  Future<String> getUserProfileAddress() async {
    if (_auth.currentUser == null) {
      return null;
    }

    if (googleSignIn.currentUser != null) {
      return googleSignIn.currentUser.photoUrl;
    } else {FacebookAccessToken accessToken = await fbLogin.currentAccessToken;
      final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,picture.width(480).height(480),first_name,last_name,email&access_token=${accessToken.token}');
      return jsonDecode(graphResponse.body)['picture']['data']['url'];
    }
  }

  Future<void> signOut() async {
    if (_auth.currentUser == null) {
      return null;
    }

    if (googleSignIn.currentUser != null) {
      await googleSignIn.signOut();
    } else {
      await fbLogin.logOut();
    }
  }

  Future<User> signInFacebook() async {
    await fbLogin.currentAccessToken.then((value) => print("david $value"));

    final FacebookLoginResult result =
        await fbLogin.logIn(['email', 'public_profile']);

    if (result.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken myToken = result.accessToken;
      AuthCredential credential =
          FacebookAuthProvider.credential(myToken.token);

      var user = await FirebaseAuth.instance.signInWithCredential(credential);
      print('signInWithGoogle succeeded: ${user.user}');
      return user.user;
    }

    return null;

    // print("error: ${result.errorMessage}");
    //
    // final String token = result.accessToken.token;
    // final response = await http.get(
    //     'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    // final profile = jsonDecode(response.body);
    //     // print(profile);
    // return profile;
  }

  Future<User> signInGoogle() async {
    await Firebase.initializeApp();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
      print('signInWithGoogle succeeded: $user');
      return user;
    }

    return null;
  }
}
