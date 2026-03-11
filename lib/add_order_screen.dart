import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'api_service.dart';

class AddOrderScreen extends StatefulWidget {
  final dynamic user;

  const AddOrderScreen({super.key, required this.user});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {

  final TextEditingController customerName = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController city = TextEditingController();

  /// PRODUCT LIST
  List<Map<String, dynamic>> orderProducts = [
    {
      "product_id": null,
      "product_name": "",
      "qty": TextEditingController()
    }
  ];

  bool loading = false;

  @override
  void dispose() {

    customerName.dispose();
    mobile.dispose();
    city.dispose();

    for (var p in orderProducts) {
      p["qty"].dispose();
    }

    super.dispose();
  }

  /// ADD PRODUCT ROW
  void addProductRow() {
    setState(() {
      orderProducts.add({
        "product_id": null,
        "product_name": "",
        "qty": TextEditingController()
      });
    });
  }

  /// REMOVE PRODUCT ROW
  void removeProductRow(int index) {

    if (orderProducts.length == 1) {
      _showSnack("At least one product required");
      return;
    }

    orderProducts[index]["qty"].dispose();

    setState(() {
      orderProducts.removeAt(index);
    });
  }

  /// SNACKBAR HELPER
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /// VALIDATE MOBILE
  bool isValidMobile(String number) {
    return number.length >= 6;
  }

  /// CREATE ORDER
  Future<void> createOrder() async {

    if (loading) return;

    if (customerName.text.trim().isEmpty ||
        mobile.text.trim().isEmpty ||
        city.text.trim().isEmpty) {

      _showSnack("Please fill customer details");
      return;
    }

    if (!isValidMobile(mobile.text.trim())) {
      _showSnack("Invalid mobile number");
      return;
    }

    List products = [];

    for (var p in orderProducts) {

      if (p["product_id"] == null || p["qty"].text.trim().isEmpty) {
        _showSnack("Please select product and quantity");
        return;
      }

      int qty = int.tryParse(p["qty"].text.trim()) ?? 0;

      if (qty <= 0) {
        _showSnack("Quantity must be greater than 0");
        return;
      }

      products.add({
        "product_id": p["product_id"],
        "quantity": qty
      });
    }

    setState(() => loading = true);

    var data = {

      "reseller_id": widget.user['id'],

      "captain_id": widget.user['captain_id'] ?? 1,

      "customer_name": customerName.text.trim(),

      "mobile": mobile.text.trim(),

      "city": city.text.trim(),

      "products": products

    };

    debugPrint("ORDER DATA: $data");

    try {

      var response = await ApiService.createSale(data);

      debugPrint("API RESPONSE: $response");

      if (response != null && response['status'] == true) {

        _showSnack("Sale Order Created");

        Navigator.pop(context);

      } else {

        _showSnack(response?['message'] ?? "Failed to create order");

      }

    } catch (e) {

      debugPrint(e.toString());
      _showSnack("Network error. Please try again");

    }

    setState(() => loading = false);
  }

  /// PRODUCT ROW
  Widget productRow(int index) {

    return Card(

      elevation: 3,

      margin: const EdgeInsets.only(bottom: 10),

      child: Padding(

        padding: const EdgeInsets.all(10),

        child: Row(

          children: [

            /// PRODUCT SEARCH
            Expanded(
              flex: 4,
              child: TypeAheadFormField(

                textFieldConfiguration: TextFieldConfiguration(
                  decoration: const InputDecoration(
                    labelText: "Search Product",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),

                suggestionsCallback: (pattern) async {

                  if (pattern.length < 2) return [];

                  var response = await ApiService.searchProducts(pattern);

                  if (response != null && response['status'] == true) {
                    return response['data'];
                  }

                  return [];
                },

                itemBuilder: (context, suggestion) {

                  final product = suggestion as Map<String, dynamic>;

                  return ListTile(
                    title: Text(product['name']),
                  );
                },

                onSuggestionSelected: (suggestion) {

                  final product = suggestion as Map<String, dynamic>;

                  setState(() {

                    orderProducts[index]['product_id'] = product['id'];
                    orderProducts[index]['product_name'] = product['name'];

                  });
                },

              ),
            ),

            const SizedBox(width: 10),

            /// QUANTITY
            Expanded(

              flex: 2,

              child: TextField(

                controller: orderProducts[index]['qty'],

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: "Qty",
                  border: OutlineInputBorder(),
                ),

              ),
            ),

            /// DELETE BUTTON
            IconButton(

              icon: const Icon(Icons.delete, color: Colors.red),

              onPressed: () => removeProductRow(index),

            )

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Order"),
        centerTitle: true,
        backgroundColor: const Color(0xffb76e79),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            /// CUSTOMER DETAILS
            Card(

              elevation: 4,

              child: Padding(

                padding: const EdgeInsets.all(16),

                child: Column(

                  children: [

                    TextField(
                      controller: customerName,
                      decoration: const InputDecoration(
                        labelText: "Customer Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: mobile,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Mobile Number",
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: city,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// PRODUCTS TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Products",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            /// PRODUCT LIST
            Column(
              children: List.generate(
                orderProducts.length,
                    (index) => productRow(index),
              ),
            ),

            const SizedBox(height: 10),

            /// ADD PRODUCT BUTTON
            ElevatedButton.icon(

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),

              onPressed: addProductRow,

              icon: const Icon(Icons.add),

              label: const Text("Add Another Product"),
            ),

            const SizedBox(height: 25),

            /// SUBMIT BUTTON
            SizedBox(

              width: double.infinity,

              height: 50,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb76e79),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: loading
                    ? null
                    : () {
                  FocusScope.of(context).unfocus();
                  createOrder();
                },

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Submit Order",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}