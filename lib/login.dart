import 'package:flutter/material.dart';
import 'api_service.dart';
import 'reseller_dashboard.dart';
import 'captain_dashboard.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {

    setState(() {
      loading = true;
    });

    var response = await ApiService.login(email.text, password.text);

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if(response != null && response['status'] == true){

      var user = response['user'];
      String role = user['role'] ?? "";

      if(role == "reseller"){

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResellerDashboard(user: user),
          ),
        );

      }
      else if(role == "captain"){

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaptainDashboard(user: user),
          ),
        );

      }
      else{

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboard(user: user),
          ),
        );

      }

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Failed")),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8C8DC), // Blush Pink
              Color(0xFFB76E79), // Rose Gold
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(

          child: SingleChildScrollView(

            child: Padding(

              padding: const EdgeInsets.all(20),

              child: Card(

                elevation: 18,
                shadowColor: Colors.black26,
                color: Colors.white.withOpacity(0.95),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Padding(

                  padding: const EdgeInsets.all(28),

                  child: Column(

                    mainAxisSize: MainAxisSize.min,

                    children: [

                      const SizedBox(height: 10),

                      Image.asset(
                        "assets/logo.png",
                        height: 85,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Umeed Fashion",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "Reseller App",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextField(
                        controller: email,

                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),

                          filled: true,
                          fillColor: Colors.grey.shade100,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: password,
                        obscureText: true,

                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),

                          filled: true,
                          fillColor: Colors.grey.shade100,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: const Color(0xffb76e79),
                            elevation: 4,
                          ),

                          onPressed: loading ? null : login,

                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),

                        ),

                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Forgot password? Contact admin",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),

                    ],

                  ),

                ),

              ),

            ),

          ),

        ),

      ),

    );

  }

}