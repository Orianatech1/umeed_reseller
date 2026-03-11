import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {

  final user;

  AdminDashboard({this.user});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text("Admin Dashboard")),

      body: Center(
        child: Text("Welcome Admin ${user['name']}"),
      ),

    );

  }

}