import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sina/template/add_med.dart';
import 'package:sina/template/admin_orders.dart';

import '../models/models.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String dropDownValue = "All";
  var items = ["All", "Pending", "Accepted", "Rejected"];

  int _currentIndex = 0;
  String search = "";
  bool isSearch = false;
  List<Order> orders = [];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Medcines").snapshots(),
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
          }
          List<Medcine> med = [];
          if (!isSearch) {
            for (var i in snapshot.data!.docs) {
              med.add(Medcine(
                  id: i["id"],
                  quantity: int.parse(i["quantity"]),
                  price: double.parse(i["price"]),
                  description: i["description"],
                  imageURL: i["imageURL"],
                  name: i["name"]));
            }
          } else {
            for (var i in snapshot.data!.docs) {
              if (i["name"]
                  .toString()
                  .toLowerCase()
                  .contains(search.toLowerCase())) {
                med.add(Medcine(
                    id: i["id"],
                    quantity: int.parse(i["quantity"]),
                    price: double.parse(i["price"]),
                    description: i["description"],
                    imageURL: i["imageURL"],
                    name: i["name"]));
              }
            }
          }

          return Scaffold(
            bottomNavigationBar: bottomNavBar(),
            appBar:
                _currentIndex == 0 ? navBar(context) : filterNavBar(context),
            body: Center(
              child: Stack(
                // fit: StackFit.passthrough,
                alignment: Alignment.bottomCenter,
                children: [
                  _currentIndex == 1
                      ? const AdminOrders()
                      : ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              height: 10,
                            );
                          },
                          physics: const BouncingScrollPhysics(),
                          itemCount: med.length,
                          itemBuilder: (BuildContext context, int index) =>
                              AdminMedCard(
                                context: context,
                                med: med[index],
                                x: (med) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditMed(med: med)));
                                },
                                y: (med) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: const Text("Delete Medcine"),
                                            content: const Text(
                                                "Are you sure you want to delete this medcine ?"),
                                            actions: [
                                              TextButton(
                                                child: const Text('Confirm'),
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("Medcines")
                                                      .doc(med.id)
                                                      .delete();
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ));
                                },
                              )),
                ],
              ),
            ),
          );
        });
  }

  SalomonBottomBar bottomNavBar() {
    return SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
          });
        },
        items: [
          SalomonBottomBarItem(
              icon: const Icon(Icons.home), title: const Text("Home")),
          SalomonBottomBarItem(
              icon: const Icon(Icons.delivery_dining),
              title: const Text("Orders")),
        ]);
  }

  navBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddMed()));
          },
          icon: const Icon(
            Icons.add_box_outlined,
            color: Colors.white,
            size: 32,
            shadows: [
              Shadow(color: Colors.black26, offset: Offset(2, 1), blurRadius: 2)
            ],
          )),
      actions: [
        IconButton(
            onPressed: () {
              setState(() {
                isSearch = !isSearch;
                if (!isSearch) {
                  search = "";
                }
              });
            },
            icon: Icon(
              isSearch ? Icons.close : Icons.search,
              color: Colors.white,
              size: 30,
              shadows: const [
                Shadow(
                    color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)
              ],
            ))
      ],
      centerTitle: true,
      title: !isSearch
          ? const Text(
              "Sina Pharmacy",
              style: TextStyle(
                  shadows: [
                    Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 2)
                  ],
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 27),
            )
          : Container(
              margin: const EdgeInsets.all(5),
              // width: MediaQuery.of(context).size.width * 0.95,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                    hintText: 'Search',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 18),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    )),
              ),
            ),
    );
  }

  filterNavBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      // actions: [
      //   // DropdownButtonFormField(
      //   //     items: items.map((String items) {
      //   //       return DropdownMenuItem(
      //   //         value: items,
      //   //         child: Text(items),
      //   //       );
      //   //     }).toList(),
      //   //     onChanged: (String? val) {}),
      //   // DropdownButton(
      //   //     alignment: Alignment.centerLeft,
      //   //     // value: dropDownValue,

      //   //     items: items.map((String items) {
      //   //       return DropdownMenuItem(
      //   //         value: items,
      //   //         child: Text(items),
      //   //       );
      //   //     }).toList(),
      //   //     onChanged: (value) {}),
      //   //   IconButton(
      //   //     onPressed: () {
      //   //       showDialog(
      //   //           context: context,
      //   //           builder: (context) => AlertDialog(
      //   //                 title: const Text("Filter orders"),
      //   //                 content: DropdownButton(
      //   //                     alignment: Alignment.centerLeft,
      //   //                     value: dropDownValue,
      //   //                     items: items.map((String items) {
      //   //                       return DropdownMenuItem(
      //   //                         value: items,
      //   //                         child: Text(items),
      //   //                       );
      //   //                     }).toList(),
      //   //                     onChanged: (String? newValue) {
      //   //                       setState(() {
      //   //                         dropDownValue = newValue!;
      //   //                       });
      //   //                     }),
      //   //                 actions: [
      //   //                   TextButton(
      //   //                     child: const Text('Confirm'),
      //   //                     onPressed: () {
      //   //                       print("deleted");
      //   //                       Navigator.pop(context);
      //   //                     },
      //   //                   ),
      //   //                 ],
      //   //               ));
      //   //     },
      //   //     icon: const Icon(
      //   //       Icons.filter_list,
      //   //       size: 30,
      //   //       shadows: [
      //   //         Shadow(color: Colors.black26, offset: Offset(2, 1), blurRadius: 2)
      //   //       ],
      //   //       color: Colors.white,
      //   //     ),
      //   //   )
      // ],

      title: const Text(
        "Orders",
        style: TextStyle(shadows: [
          Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 2)
        ], color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
      ),
    );
  }
}

class AdminMedCard extends StatefulWidget {
  const AdminMedCard(
      {Key? key,
      required this.x,
      required this.med,
      required this.context,
      required this.y})
      : super(key: key);
  final Function x;
  final Function y;
  final BuildContext context;
  final Medcine med;
  @override
  State<AdminMedCard> createState() => _AdminMedCardState();
}

class _AdminMedCardState extends State<AdminMedCard> {
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
                        fit: BoxFit.contain,
                        image: NetworkImage(widget.med.imageURL)),
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
                      Text(widget.med.name,
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
                        "${widget.med.price.toStringAsFixed(2)}DA",
                        maxLines: 1,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.med.description,
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
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                    // border: Border.all(width: 0.15),
                    borderRadius: const BorderRadius.all(Radius.circular(25))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          widget.x(widget.med);
                        },
                        icon: Icon(
                          Icons.edit_note_outlined,
                          color: Theme.of(context).primaryColor,
                        )),
                    Text(
                      widget.med.quantity.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        // iconSize: 20,
                        onPressed: () {
                          widget.y(widget.med);
                          // setState(() {
                          //   if (med.quantity > 0) {
                          //     med.quantity--;
                          //     if (med.quantity == 0) {
                          //       chart.remove(med);
                          //     }
                          //   }
                          // });
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
    ]);
  }
}
