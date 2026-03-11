import 'package:flutter/material.dart';
import 'package:umeed_reseller_app/profile_screen.dart';
import 'add_order_screen.dart';
import 'login.dart';
import 'api_service.dart';

class ResellerDashboard extends StatefulWidget {

  final user;

  const ResellerDashboard({super.key, required this.user});

  @override
  State<ResellerDashboard> createState() => _ResellerDashboardState();
}

class _ResellerDashboardState extends State<ResellerDashboard> {

  String topReseller = "Loading...";
  String topProduct = "Loading...";
  String earnings = "0.00";

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  /// LOAD DASHBOARD DATA
  loadDashboard() async {

    try {

      /// TOP RESELLER
      var reseller = await ApiService.topReseller();

      if(reseller != null && reseller['status'] == true && reseller['name'] != null){

        setState(() {
          topReseller = "${reseller['name']} (${reseller['orders']} orders)";
        });

      } else {

        setState(() {
          topReseller = "No orders today";
        });

      }

      /// TOP PRODUCT
      var product = await ApiService.topProduct();

      if(product != null && product['status'] == true && product['data'] != null){

        setState(() {
          topProduct = product['data']['product_name'];
        });

      }else{

        setState(() {
          topProduct = "No orders today";
        });

      }

      /// MY EARNINGS
      var earn = await ApiService.myEarnings(widget.user['id']);

      if(earn != null && earn['status'] == true){

        setState(() {
          earnings = earn['earning'].toString();
        });

      }

    } catch(e){

      print("Dashboard API Error: $e");

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        automaticallyImplyLeading: false,
        title: const Text("Dashboard"),
        centerTitle: true,
        backgroundColor: const Color(0xffb76e79),

        actions: [

          PopupMenuButton(

            icon: const Icon(Icons.person),

            itemBuilder: (context) => [

              const PopupMenuItem(
                value: "profile",
                child: Text("My Profile"),
              ),

              const PopupMenuItem(
                value: "logout",
                child: Text("Logout"),
              ),

            ],

            onSelected: (value) {

              if(value == "profile"){

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: widget.user),
                  ),
                );

              }

              if(value == "logout"){

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context)=>const LoginPage()),
                      (route) => false,
                );

              }

            },

          )

        ],

      ),

      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// WELCOME MESSAGE
              Text(
                "Welcome, ${widget.user['name']}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Let's start selling today 🚀",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 20),

              /// TOP RESELLER CARD
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                child: ListTile(
                  leading: const Icon(Icons.emoji_events,color: Colors.orange),
                  title: const Text("Today's Top Reseller"),
                  subtitle: Text(topReseller),
                ),
              ),

              const SizedBox(height: 10),

              /// TOP PRODUCT CARD
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag,color: Colors.green),
                  title: const Text("Today's Top Product"),
                  subtitle: Text(topProduct),
                ),
              ),

              const SizedBox(height: 10),

              /// MY EARNINGS CARD
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                child: ListTile(
                  leading: const Icon(Icons.currency_rupee,color: Colors.blue),
                  title: const Text("My Earnings"),
                  subtitle: Text("₹ $earnings"),
                ),
              ),

              const SizedBox(height: 25),

              /// BUTTON ROW 1
              Row(
                children: [

                  Expanded(
                    child: dashboardButton(
                        context,
                        "Add Order",
                        Icons.add_shopping_cart,
                        Colors.pink
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: dashboardButton(
                        context,
                        "My Orders",
                        Icons.list_alt,
                        Colors.deepPurple
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 20),

              /// BUTTON ROW 2
              Row(
                children: [

                  Expanded(
                    child: dashboardButton(
                        context,
                        "Payment Status",
                        Icons.payment,
                        Colors.teal
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: dashboardButton(
                        context,
                        "Order Status",
                        Icons.local_shipping,
                        Colors.orange
                    ),
                  ),

                ],
              ),

            ],

          ),

        ),

      ),

    );

  }

  /// DASHBOARD BUTTON
  Widget dashboardButton(BuildContext context,String title,IconData icon,Color color){

    return GestureDetector(

      onTap: (){

        if(title == "Add Order"){

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddOrderScreen(user: widget.user),
            ),
          );

        }
        else if(title == "My Orders"){

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("My Orders screen coming next"))
          );

        }
        else{

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title screen coming soon"))
          );

        }

      },

      child: Container(

        height: 90,

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(icon,color: Colors.white,size: 28),

            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            )

          ],

        ),

      ),

    );

  }

}