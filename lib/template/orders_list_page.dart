import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:sina/template/order_details.dart';

import '../models/models.dart';

class OrdersListPage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const OrdersListPage({
    Key? key,
  });

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Orders").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Something went wrong')),
            );
          }
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          } else {
            List<Order> orders = [];
            for (var i in snapshot.data!.docs) {
              if (i["user"]["id"] ==
                  auth.FirebaseAuth.instance.currentUser!.uid.toString()) {
                List<MedcineChart> tmp = [];
                for (var j in i["med_list"]) {
                  tmp.add(MedcineChart(
                      medcine: Medcine(
                          description: j["description"],
                          id: j["id"],
                          imageURL: j["imageURL"],
                          name: j["name"],
                          price: j["price"],
                          quantity: 0),
                      quantity: j["quantity"]));
                }
                orders.add(Order(
                    date: DateTime.parse(i["date"]),
                    id: i["id"],
                    medcineList: tmp,
                    stauts: i["status"],
                    user: User(
                        address: i["user"]["address"],
                        email: i["user"]["email"],
                        id: i["user"]["id"],
                        isAdmin: false,
                        name: i["user"]["name"],
                        phone: i["user"]["phone"]),
                    total: i['total']));
              }
            }
            return ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 15,
                  );
                },
                physics: const BouncingScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (BuildContext context, int index) => orderCard(
                      context,
                      orders[index],
                    ));
          }
        });
  }

  Stack orderCard(context, Order order) {
    return Stack(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.23,
            decoration: BoxDecoration(
                // border: Border.all(width: 1, color: Colors.black),
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: order.stauts.toLowerCase() == "accepted"
                          ? Colors.green.shade300
                          : order.stauts.toLowerCase() == "pending"
                              ? Colors.orange.shade300
                              : Colors.red.shade300,
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                      spreadRadius: 1)
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.14),
                    margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
                    // width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.user.name,
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${order.total.toStringAsFixed(2)}DA",
                          maxLines: 1,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${order.user.phone}\n${order.user.address}\ntest",
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade300,
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            spreadRadius: 2)
                      ],
                      // border: Border.all(width: 0.15),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(25))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderDetails(
                                          order: order,
                                        )));
                          },
                          icon: Icon(
                            Icons.read_more_outlined,
                            color: Theme.of(context).primaryColor,
                          )),
                      Icon(
                        order.stauts.toLowerCase() == "accepted"
                            ? Icons.check_circle_outline
                            : order.stauts.toLowerCase() == "pending"
                                ? Icons.timelapse
                                : Icons.do_not_disturb,
                        color: order.stauts.toLowerCase() == "accepted"
                            ? Colors.greenAccent.shade700
                            : order.stauts.toLowerCase() == "pending"
                                ? Colors.orange
                                : Colors.red,
                      ),
                      IconButton(
                          // iconSize: 20,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text(
                                        "Delete Order",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      content: const Text(
                                          "Are you sure you want to delete this order ?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection("Orders")
                                                .doc(order.id)
                                                .delete();
                                            // ignore: use_build_context_synchronously
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Confirm"),
                                        )
                                      ],
                                    ));
                          },
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
