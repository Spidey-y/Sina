import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sina/template/signin_page.dart';
import 'package:sina/template/theme.dart';

void main() {
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
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
              child: child!,
            );
          },
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Palette.myColor,
          ),
          home: const SingInPage()),
    );
  }
}
