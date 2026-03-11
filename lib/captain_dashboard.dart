import 'package:flutter/material.dart';

class CaptainDashboard extends StatelessWidget {

  final user;

  CaptainDashboard({this.user});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text("Captain Dashboard")),

      body: Center(
        child: Text("Welcome Captain ${user['name']}"),
      ),

    );

  }

}