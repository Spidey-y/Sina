import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sina/models/models.dart';
import 'package:sina/template/misc.dart';
import 'package:sina/template/orders_list_page.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class LoadMeds extends StatefulWidget {
  const LoadMeds({Key? key}) : super(key: key);
  final String search = "";
  @override
  State<LoadMeds> createState() => _LoadMedsState();
}

class _LoadMedsState extends State<LoadMeds> {
  bool isSearch = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("Medcines").get(),
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
            List<MedcineChart> med = [];
            if (!isSearch) {
              med.clear();
              for (var i in snapshot.data!.docs) {
                med.add(MedcineChart(
                    medcine: Medcine(
                        id: i["id"],
                        quantity: int.parse(i["quantity"]),
                        price: double.parse(i["price"]),
                        description: i["description"],
                        imageURL: i["imageURL"],
                        name: i["name"]),
                    quantity: 0));
              }
            } else {
              for (var i in snapshot.data!.docs) {
                if (i["name"]
                    .toString()
                    .toLowerCase()
                    .contains(widget.search.toLowerCase())) {
                  med.add(MedcineChart(
                      medcine: Medcine(
                          id: i["id"],
                          quantity: int.parse(i["quantity"]),
                          price: double.parse(i["price"]),
                          description: i["description"],
                          imageURL: i["imageURL"],
                          name: i["name"]),
                      quantity: 0));
                }
              }
            }
            return HomePage(med: med);
          }
        });
  }
}

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.med}) : super(key: key);
  late List<MedcineChart> med;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  String search = "";
  bool isSearch = false;
  List<MedcineChart> chart = [];
  List<MedcineChart> med = [];
  @override
  void initState() {
    super.initState();
    med = widget.med;
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (int i = 0; i < chart.length; ++i) {
      total += chart[i].quantity * chart[i].medcine.price;
    }
    return Scaffold(
        bottomNavigationBar: bottomNavBar(),
        appBar: _currentIndex == 1 ? navBar(context) : null,
        body: Center(
          child: Stack(
            // fit: StackFit.passthrough,
            alignment: Alignment.bottomCenter,
            children: [
              _currentIndex == 2
                  ? const OrdersListPage()
                  : ListView.separated(
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      physics: const BouncingScrollPhysics(),
                      itemCount: _currentIndex == 1 ? med.length : chart.length,
                      itemBuilder: (BuildContext context, int index) => MedCard(
                            context: context,
                            med: _currentIndex == 1 ? med[index] : chart[index],
                            x: (MedcineChart x) {
                              setState(() {
                                if (!chart.contains(x)) {
                                  x.quantity++;
                                  chart.add(x);
                                } else {
                                  chart
                                      .where((element) =>
                                          element.medcine.id == x.medcine.id)
                                      .last
                                      .quantity++;
                                }
                              });
                            },
                            y: (MedcineChart med) {
                              setState(() {
                                if (med.quantity > 0) {
                                  med.quantity--;
                                }
                                if (med.quantity == 0) {
                                  chart.remove(med);
                                }
                              });
                            },
                          )),
              _currentIndex == 0
                  ? Button(
                      color: Theme.of(context).primaryColor,
                      text: "Check out (${total.toStringAsFixed(2)} DA)",
                      textColor: Colors.white,
                      x: () async {
                        var tmp = [];
                        bool correct = true;
                        for (var i in chart) {
                          if (i.quantity <= i.medcine.quantity) {
                            tmp.add({
                              "name": i.medcine.name,
                              "id": i.medcine.id,
                              "price": i.medcine.price,
                              "imageURL": i.medcine.imageURL,
                              "description": i.medcine.description,
                              "quantity": i.quantity
                            });
                          } else {
                            correct = false;
                            break;
                          }
                        }
                        if (correct) {
                          setState(() {
                            for (var i = 0; i < med.length; i++) {
                              med[i].quantity = 0;
                            }
                            chart.clear();
                          });
                          var user = {};
                          await FirebaseFirestore.instance
                              .collection("Users")
                              .doc(FirebaseAuth.instance.currentUser!.uid
                                  .toString())
                              .get()
                              .then((value) {
                            user = {
                              'id': value["id"],
                              "name": value["name"],
                              "email": value["email"],
                              "phone": value["phone"],
                              "address": value["address"],
                            };
                          });
                          var x = await FirebaseFirestore.instance
                              .collection("Orders")
                              .add({
                            "id": "tmp",
                            "date": DateFormat('yyyy-MM-ddTHH:mm:ss')
                                .format(DateTime.now()),
                            "med_list": tmp,
                            "user": user,
                            "total": total,
                            "status": "Pending"
                          });
                          await FirebaseFirestore.instance
                              .collection("Orders")
                              .doc(x.id)
                              .update({"id": x.id});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please lower quanity ordered')),
                          );
                        }
                      })
                  : const SizedBox(),
            ],
          ),
        ));
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
              icon: const Icon(Icons.shopping_cart),
              title: const Text("Chart")),
          SalomonBottomBarItem(
              icon: const Icon(Icons.home), title: const Text("Home")),
          SalomonBottomBarItem(
              icon: const Icon(Icons.delivery_dining),
              title: const Text("My orders")),
        ]);
  }

  navBar(BuildContext context) {
    return AppBar(
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
}

class MedCard extends StatefulWidget {
  const MedCard(
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
  State<MedCard> createState() => _MedCardState();
}

class _MedCardState extends State<MedCard> {
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
                        widget.med.medcine.description,
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
                          // setState(() {
                          //   med.quantity++;
                          //   if (med.quantity == 1) {
                          //     chart.add(med);
                          //   }
                          // });
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
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
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Theme.of(context).primaryColor,
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
