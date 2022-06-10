import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sina/template/admin_home.dart';
import 'package:sina/template/home_page.dart';
import 'package:sina/template/signin_page.dart';
import 'package:sina/template/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
              child: child!,
            );
          },
          title: 'Sina Pharmacy',
          theme: ThemeData(
            primarySwatch: Palette.myColor,
          ),
          home: const Start()),
    );
  }
}

class Start extends StatelessWidget {
  const Start({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          isAdmin(context, snap);
          return const SingInPage();
        });
  }

  void isAdmin(context, snap) async {
    if (snap.hasData) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid.toString())
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          if (documentSnapshot["is_admin"]) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: ((context) => const AdminHomePage())));
          } else {
            if (documentSnapshot["is_admin"] == false) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: ((context) => const HomePage())));
            } //home page
          }
        }
      });
    }
  }
}
