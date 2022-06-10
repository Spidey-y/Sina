class Medcine {
  Medcine(
      {required this.id,
      required this.quantity,
      required this.price,
      required this.description,
      required this.imageURL,
      required this.name});
  late String id;
  late String name;
  late int quantity;
  late double price;
  late String description;
  late String imageURL;
}

class User {
  User(
      {required this.id,
      required this.address,
      required this.email,
      required this.name,
      required this.isAdmin,
      required this.phone});
  late String id;
  late bool isAdmin;
  late String name;
  late String email;
  late String phone;
  late String address;
}

class MedcineChart {
  MedcineChart({required this.medcine, required this.quantity});
  late Medcine medcine;
  late int quantity;
}

class Order {
  Order(
      {required this.date,
      required this.id,
      required this.medcineList,
      required this.stauts,
      required this.user,
      required this.total});
  late String id;
  late DateTime date;
  late List<MedcineChart> medcineList;
  late User user;
  late double total;
  late String stauts;
}
