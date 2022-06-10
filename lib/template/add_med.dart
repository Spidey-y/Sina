import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sina/models/models.dart';
import 'package:sina/template/misc.dart';

// ignore: must_be_immutable
class AddMed extends StatefulWidget {
  const AddMed({Key? key}) : super(key: key);

  @override
  State<AddMed> createState() => _AddMedState();
}

class _AddMedState extends State<AddMed> {
  TextEditingController nameCtrlr = TextEditingController();

  TextEditingController priceCtrlr = TextEditingController();

  TextEditingController quantityCtrlr = TextEditingController();

  TextEditingController descriptionCtrlr = TextEditingController();

  PlatformFile? pickedFile;

  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    setState(() {
      pickedFile = result.files.first;
    });
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !loading
          ? AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                    shadows: [
                      Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2)
                    ],
                  )),
              centerTitle: true,
              title: const Text(
                "Add Medcine",
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
              ),
            )
          : null,
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Center(
              child: ListView(
                padding: const EdgeInsets.all(30),
                shrinkWrap: true,
                children: [
                  InputField(
                      controller: nameCtrlr,
                      icon: Icons.add,
                      hint: "Medcine name",
                      keyboard: TextInputType.name,
                      isPass: false),
                  InputField(
                      controller: quantityCtrlr,
                      icon: Icons.add,
                      hint: "Available quantity",
                      keyboard: TextInputType.number,
                      isPass: false),
                  InputField(
                      controller: priceCtrlr,
                      icon: Icons.attach_money,
                      hint: "Unit price",
                      keyboard: TextInputType.number,
                      isPass: false),
                  InputField(
                      controller: descriptionCtrlr,
                      icon: Icons.description,
                      hint: "Medcine description",
                      keyboard: TextInputType.text,
                      isPass: false),
                  InkWell(
                    onTap: () {
                      selectFile();
                    },
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 4,
                                    color: Colors.grey.shade400,
                                    offset: const Offset(2, 2),
                                    spreadRadius: 2)
                              ],
                              color: Colors.grey[300],
                            ),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.4,
                            child: pickedFile != null
                                ? Image.file(File(pickedFile!.path!))
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_rounded,
                                        size: 40,
                                        color: Colors.grey[700],
                                      ),
                                      const Text(
                                        'Please select\nan image',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Button(
                      color: Theme.of(context).primaryColor,
                      text: "Add New Medcine",
                      textColor: Colors.white,
                      x: () async {
                        if (nameCtrlr.text.isNotEmpty &&
                            priceCtrlr.text.isNotEmpty &&
                            priceCtrlr.text.isNotEmpty &&
                            descriptionCtrlr.text.isNotEmpty &&
                            pickedFile != null) {
                          setState(() {
                            loading = !loading;
                          });
                          var x = await FirebaseFirestore.instance
                              .collection("Medcines")
                              .add({
                            "name": nameCtrlr.text,
                            "price": priceCtrlr.text,
                            "quantity": quantityCtrlr.text,
                            "description": descriptionCtrlr.text,
                            "id": "tmp",
                            "imageURL": "tmp"
                          });
                          final path = 'Images/${x.id}';
                          final file = File(pickedFile!.path!);
                          final ref =
                              FirebaseStorage.instance.ref().child(path);
                          uploadTask = ref.putFile(file);
                          final snap = await uploadTask!.whenComplete(() {});
                          final url = await snap.ref.getDownloadURL();
                          await FirebaseFirestore.instance
                              .collection("Medcines")
                              .doc(x.id)
                              .update({"imageURL": url, "id": x.id});
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please fill in all the fields.')),
                          );
                        }
                      })
                ],
              ),
            ),
    );
  }
}

class EditMed extends StatefulWidget {
  const EditMed({Key? key, required this.med}) : super(key: key);
  final Medcine med;

  @override
  State<EditMed> createState() => _EditMedState();
}

class _EditMedState extends State<EditMed> {
  TextEditingController nameCtrlr = TextEditingController();

  TextEditingController priceCtrlr = TextEditingController();

  TextEditingController quantityCtrlr = TextEditingController();

  TextEditingController descriptionCtrlr = TextEditingController();

  PlatformFile? pickedFile;

  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    setState(() {
      pickedFile = result.files.first;
    });
  }

  @override
  void initState() {
    super.initState();
    nameCtrlr.text = widget.med.name;
    priceCtrlr.text = widget.med.price.toString();
    quantityCtrlr.text = widget.med.quantity.toString();
    descriptionCtrlr.text = widget.med.description;
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: loading
          ? null
          : AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                    shadows: [
                      Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2)
                    ],
                  )),
              centerTitle: true,
              title: const Text(
                "Edit Medcine",
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
              ),
            ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Center(
              child: ListView(
                padding: const EdgeInsets.all(30),
                shrinkWrap: true,
                children: [
                  InputField(
                      controller: nameCtrlr,
                      icon: Icons.add,
                      hint: "Medcine name",
                      keyboard: TextInputType.name,
                      isPass: false),
                  InputField(
                      controller: quantityCtrlr,
                      icon: Icons.add,
                      hint: "Available quantity",
                      keyboard: TextInputType.number,
                      isPass: false),
                  InputField(
                      controller: priceCtrlr,
                      icon: Icons.attach_money,
                      hint: "Unit price",
                      keyboard: TextInputType.number,
                      isPass: false),
                  InputField(
                      controller: descriptionCtrlr,
                      icon: Icons.description,
                      hint: "Description",
                      keyboard: TextInputType.text,
                      isPass: false),
                  InkWell(
                    onTap: () {
                      selectFile();
                    },
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                              margin: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 4,
                                      color: Colors.grey.shade400,
                                      offset: const Offset(2, 2),
                                      spreadRadius: 2)
                                ],
                                color: Colors.grey[300],
                              ),
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: MediaQuery.of(context).size.width * 0.4,
                              child: pickedFile != null
                                  ? Image.file(File(pickedFile!.path!))
                                  : Image.network(widget.med.imageURL)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Button(
                      color: Theme.of(context).primaryColor,
                      text: "Confim changes",
                      textColor: Colors.white,
                      x: () async {
                        if (nameCtrlr.text.isNotEmpty &&
                            priceCtrlr.text.isNotEmpty &&
                            priceCtrlr.text.isNotEmpty &&
                            descriptionCtrlr.text.isNotEmpty) {
                          setState(() {
                            loading = !loading;
                          });
                          var url = widget.med.imageURL;
                          if (pickedFile != null) {
                            final path = 'Images/${widget.med.id}';
                            final file = File(pickedFile!.path!);
                            final ref =
                                FirebaseStorage.instance.ref().child(path);
                            uploadTask = ref.putFile(file);
                            final snap = await uploadTask!.whenComplete(() {});
                            url = await snap.ref.getDownloadURL();
                          }
                          await FirebaseFirestore.instance
                              .collection("Medcines")
                              .doc(widget.med.id)
                              .update({
                            "imageURL": url,
                            "name": nameCtrlr.text,
                            "price": priceCtrlr.text,
                            "quantity": quantityCtrlr.text,
                            "description": descriptionCtrlr.text,
                          });
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please fill in all the fields.')),
                          );
                        }
                      })
                ],
              ),
            ),
    );
  }
}
