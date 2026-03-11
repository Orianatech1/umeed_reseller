import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {

  final user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xffb76e79),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xffb76e79),
              child: Icon(Icons.person,size:50,color: Colors.white),
            ),

            const SizedBox(height: 20),

            profileItem("Name", user['name']),
            profileItem("Email", user['email']),
            profileItem("Phone", user['phone']),
            profileItem("Role", user['role']),
            profileItem("Total Earnings", "₹ ${user['total_earning']}"),

          ],

        ),

      ),

    );

  }

  Widget profileItem(String title, String value){

    return Card(

      margin: const EdgeInsets.only(bottom:10),

      child: ListTile(

        title: Text(title),
        subtitle: Text(value),

      ),

    );

  }

}