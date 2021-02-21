import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'סקיפו',
          style: TextStyle(fontSize: 25, fontFamily: 'amaticaRegular'),
        ),
      ),
      body: Center(
        child: Platform.isIOS
            ? CupertinoActivityIndicator()
            : CircularProgressIndicator(),
      ),
    );
  }
}
