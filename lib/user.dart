import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:strazca_revirov/Authentication.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<UserPage> {
  Authenticate auth = Authenticate();
  User user;
  String photoUrl;

  @override
  void initState() {
    user = auth.currentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      Text("User logged = ${user?.displayName ?? "Not logged"}"),
      Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getUserPicture(),
              getButtons(),
            ],
          ),
        ),
      ),
    ]));
  }

  Future<void> setUser(User user) async {
    this.user = user;
    if (user == null) {
      photoUrl = null;
    } else {
      //pockam kym sa nastavy photo url a az potom moezm volat setState
      await auth.getUserProfileAddress().then((value) => photoUrl = value);
    }

    setState(() {});
  }

  getUserPicture() {
    if (photoUrl == null) {
      return Container(
        height: 100.0,
        width: 100.0,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        imageBuilder: (context, imageProvider) => Container(
          height: 100.0,
          width: 100.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: imageProvider, fit: BoxFit.cover),
          ),
        ),
      );
    }
  }

  getButtons() {
    if (user != null) {
      return SignInButton(
        Buttons.Google,
        text: "logout",
        onPressed: () {
          setState(() {
            auth.signOut().then((value) => setUser(null));
          });
        },
      );
    } else {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SignInButton(
                Buttons.Google,
                onPressed: () {
                  auth.signInGoogle().then((value) => setUser(value));
                },
              ),
              SignInButton(
                Buttons.FacebookNew,
                onPressed: () {
                  auth.signInFacebook().then((value) => setUser(value));
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}
