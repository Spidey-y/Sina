import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class AdminOrderDetails extends StatefulWidget {
  const AdminOrderDetails({Key? key, required this.order}) : super(key: key);
  final Order order;
  @override
  State<AdminOrderDetails> createState() => _AdminOrderDetailsState();
}

class _AdminOrderDetailsState extends State<AdminOrderDetails> {
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
                      // physics: const BouncingScrollPhysics(),
                      itemCount: widget.order.medcineList.length + 2,
                      itemBuilder: (BuildContext context, int index) => index ==
                              widget.order.medcineList.length
                          ? Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  // border: Border.all(width: 0.5, color: Colors.red),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Total: ${total.toStringAsFixed(2)} DA",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          : index == widget.order.medcineList.length + 1
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        await FirebaseFirestore.instance
                                            .collection("Orders")
                                            .doc(widget.order.id)
                                            .update({"status": "Accepted"});
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Order marked as Accepted')),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            15, 15, 15, 30),
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.green),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Accept",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        await FirebaseFirestore.instance
                                            .collection("Orders")
                                            .doc(widget.order.id)
                                            .update({"status": "Rejected"});
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Order marked as Rejected')),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            15, 15, 15, 30),
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.5, color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.red,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Decline",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : Card(
                                  context: context,
                                  med: widget.order.medcineList[index],
                                  x: (med) {
                                    if (widget.order.stauts == "Pending") {
                                      setState(() {
                                        med.quantity++;
                                      });
                                    }
                                  },
                                  y: (med) {
                                    if (widget.order.stauts == "Pending") {
                                      setState(() {
                                        if (med.quantity > 0) {
                                          med.quantity--;
                                          if (med.quantity == 0) {
                                            widget.order.medcineList
                                                .remove(med);
                                          }
                                        }
                                      });
                                    }
                                  },
                                )),
                ],
              ),
            ),
    );
  }
}

class Card extends StatefulWidget {
  const Card(
      {Key? key,
      required this.x,
      required this.med,
      required this.context,
      required this.y})
      : super(key: key);
  final Function x;
  final Function y;
  final BuildContext context;
  final MedcineChart med;
  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
                    color: Colors.grey.shade300,
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                    spreadRadius: 2)
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                        image: NetworkImage(widget.med.medcine.imageURL)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(-3, 2),
                          blurRadius: 5,
                          spreadRadius: 2)
                    ]),
                width: MediaQuery.of(context).size.width * 0.27,
                height: MediaQuery.of(context).size.width * 0.27,
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.14),
                  margin: const EdgeInsets.fromLTRB(0, 18, 0, 18),
                  // width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.med.medcine.name,
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
                        "${widget.med.medcine.price.toStringAsFixed(2)}DA",
                        maxLines: 1,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Quantity: ${widget.med.quantity}\n${widget.med.medcine.description}",
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
            ],
          ),
        ),
      ),
    ]);
  }
}
