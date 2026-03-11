import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddOrderScreen extends StatefulWidget {

  final user;

  const AddOrderScreen({super.key, required this.user});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {

  final TextEditingController customerName = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController city = TextEditingController();

  /// PRODUCT LIST
  List<Map<String,dynamic>> orderProducts = [
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
  addProductRow(){

    setState(() {

      orderProducts.add({
        "product_id": null,
        "product_name": "",
        "qty": TextEditingController()
      });

    });

  }

  /// REMOVE PRODUCT ROW
  removeProductRow(int index){

    if(orderProducts.length == 1){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("At least one product required"))
      );
      return;
    }

    setState(() {
      orderProducts.removeAt(index);
    });

  }

  /// CREATE ORDER
  createOrder() async {

    if(customerName.text.isEmpty ||
        mobile.text.isEmpty ||
        city.text.isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill customer details")),
      );

      return;
    }

    List products = [];

    for(var p in orderProducts){

      if(p["product_id"] == null || p["qty"].text.isEmpty){

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select product and quantity")),
        );

        return;
      }

      products.add({
        "product_id": p["product_id"],
        "quantity": int.parse(p["qty"].text)
      });

    }

    setState(() {
      loading = true;
    });

    var data = {

      "reseller_id": widget.user['id'],

      "captain_id": widget.user['captain_id'] ?? 1,

      "customer_name": customerName.text,

      "mobile": mobile.text,

      "city": city.text,

      "products": products

    };

    print("ORDER DATA:");
    print(data);

    try{

      var response = await ApiService.createSale(data);

      print("API RESPONSE:");
      print(response);

      if(response != null && response['status'] == true){

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sale Order Created")),
        );

        Navigator.pop(context);

      }else{

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Failed")),
        );

      }

    }catch(e){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }

    setState(() {
      loading = false;
    });

  }
  /// PRODUCT ROW UI
  Widget productRow(int index){

    return Card(

      elevation: 3,

      margin: const EdgeInsets.only(bottom:10),

      child: Padding(

        padding: const EdgeInsets.all(10),

        child: Row(

          children: [

            /// PRODUCT SEARCH
            Expanded(
              flex: 4,
              child: TypeAheadFormField(

                textFieldConfiguration: TextFieldConfiguration(
                  controller: TextEditingController(
                      text: orderProducts[index]['product_name'] ?? ""
                  ),
                  decoration: const InputDecoration(
                    labelText: "Search Product",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),

                suggestionsCallback: (pattern) async {

                  if(pattern.length < 2){
                    return [];
                  }

                  var response = await ApiService.searchProducts(pattern);

                  if(response != null && response['status']==true){
                    return response['data'];
                  }

                  return [];

                },

                itemBuilder: (context, suggestion){

                  final product = suggestion as Map<String,dynamic>;

                  return ListTile(
                    title: Text(product['name']),
                  );

                },

                onSuggestionSelected: (suggestion){

                  final product = suggestion as Map<String,dynamic>;

                  setState(() {

                    orderProducts[index]['product_id'] = product['id'];
                    orderProducts[index]['product_name'] = product['name'];

                  });

                },

              ),
            ),

            const SizedBox(width:10),

            /// QUANTITY
            Expanded(

              flex:2,

              child: TextField(

                controller: orderProducts[index]['qty'],

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: "Qty",
                  border: OutlineInputBorder(),
                ),

              ),

            ),

            /// DELETE
            IconButton(

              icon: const Icon(Icons.delete,color: Colors.red),

              onPressed: (){
                removeProductRow(index);
              },

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

        child: Padding(

          padding: const EdgeInsets.all(16),

          child: Column(

            children: [

              /// CUSTOMER CARD
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

                      const SizedBox(height:15),

                      TextField(
                        controller: mobile,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Mobile Number",
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),

                      const SizedBox(height:15),

                      TextField(
                        controller: city,
                        decoration: const InputDecoration(
                          labelText: "City",
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(height:20),

              /// PRODUCTS TITLE
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Products",
                  style: TextStyle(
                      fontSize:18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),

              const SizedBox(height:10),

              /// PRODUCT ROWS
              Column(
                children: List.generate(
                    orderProducts.length,
                        (index)=>productRow(index)
                ),
              ),

              const SizedBox(height:10),

              /// ADD PRODUCT BUTTON
              ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),

                onPressed: addProductRow,

                icon: const Icon(Icons.add),

                label: const Text("Add Another Product"),

              ),

              const SizedBox(height:25),

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

                  onPressed: loading ? null : () async {

                    FocusScope.of(context).unfocus();
                    await createOrder();

                  },

                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Submit Order",
                    style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),
                  ),
                )

              )

            ],

          ),

        ),

      ),

    );

  }

}