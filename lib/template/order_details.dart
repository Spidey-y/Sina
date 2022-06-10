import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sina/models/models.dart';
import 'package:sina/template/home_page.dart';
import 'package:sina/template/misc.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({Key? key, required this.order}) : super(key: key);
  final Order order;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (int i = 0; i < widget.order.medcineList.length; ++i) {
      total += widget.order.medcineList[i].quantity *
          widget.order.medcineList[i].medcine.price;
    }
    return Scaffold(
      appBar: loading
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 3,
              centerTitle: true,
              title: const Text(
                "Order Details",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          blurRadius: 2,
                          offset: Offset(1, 1),
                          color: Colors.black12)
                    ]),
              )),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ))
          : Center(
              child: Stack(
                // fit: StackFit.passthrough,
                alignment: Alignment.bottomCenter,
                children: [
                  ListView.separated(
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 15,
                        );
                      },
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.order.medcineList.length,
                      itemBuilder: (BuildContext context, int index) => MedCard(
                            context: context,
                            med: widget.order.medcineList[index],
                            x: (med) {
                              if (widget.order.stauts == "Pending") {
                                setState(() {
                                  med.quantity++;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('You cant edit this order')),
                                );
                              }
                            },
                            y: (med) {
                              if (widget.order.stauts == "Pending") {
                                setState(() {
                                  if (med.quantity > 0) {
                                    med.quantity--;
                                    if (med.quantity == 0) {
                                      widget.order.medcineList.remove(med);
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('You cant edit this order')),
                                    );
                                  }
                                });
                              }
                            },
                          )),
                  widget.order.stauts == "Pending"
                      ? Button(
                          color: Theme.of(context).primaryColor,
                          text: "Confirm (${total.toStringAsFixed(2)} DA)",
                          textColor: Colors.white,
                          x: () async {
                            setState(() {
                              loading = !loading;
                            });
                            var tmp = [];
                            for (var i in widget.order.medcineList) {
                              tmp.add({
                                "name": i.medcine.name,
                                "id": i.medcine.id,
                                "price": i.medcine.price,
                                "imageURL": i.medcine.imageURL,
                                "description": i.medcine.description,
                                "quantity": i.quantity
                              });
                            }
                            await FirebaseFirestore.instance
                                .collection("Orders")
                                .doc(widget.order.id)
                                .update({"med_list": tmp});
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          })
                      : const SizedBox()
                ],
              ),
            ),
    );
  }
}
