import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sina/template/admin_home.dart';
import 'package:sina/template/home_page.dart';
import 'package:sina/template/signup_page.dart';
import 'misc.dart';

class SingInPage extends StatefulWidget {
  const SingInPage({Key? key}) : super(key: key);

  @override
  State<SingInPage> createState() => _SingInPageState();
}

class _SingInPageState extends State<SingInPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          // padding: EdgeInsets.all(20),
          children: [
            picture(context),
            loginForm(context),
            const SizedBox(
              height: 30,
            ),
            SignTextButton(
              context: context,
              route: const SignUpPage(),
              button: "Sign Up",
              leading: "New to Sina ?  ",
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Form loginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          InputField(
            controller: emailController,
            icon: Icons.email_outlined,
            hint: "E-mail",
            keyboard: TextInputType.emailAddress,
            isPass: false,
          ),
          InputField(
            controller: passwordController,
            icon: Icons.key_outlined,
            hint: "Password",
            keyboard: TextInputType.visiblePassword,
            isPass: true,
          ),
          FormButton(
            formKey: _formKey,
            color: Theme.of(context).primaryColor,
            text: "Sign in",
            textColor: Colors.white,
            x: (context) async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Loging in to your account')),
                );
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text)
                    .then((value) async {
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
                      .get()
                      .then((value) {
                    if (value["is_admin"]) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const AdminHomePage()));
                    } else {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const HomePage()));
                    }
                  });
                });
              } on FirebaseAuthException catch (error) {
                var errorMessage = "";
                switch (error.code) {
                  case "invalid-email":
                    errorMessage =
                        "Your email address appears to be malformed.";

                    break;
                  case "wrong-password":
                    errorMessage = "Your password is wrong.";
                    break;
                  case "user-not-found":
                    errorMessage = "User with this email doesn't exist.";
                    break;
                  case "user-disabled":
                    errorMessage = "User with this email has been disabled.";
                    break;
                  case "too-many-requests":
                    errorMessage = "Too many requests";
                    break;
                  case "operation-not-allowed":
                    errorMessage =
                        "Signing in with Email and Password is not enabled.";
                    break;
                  default:
                    errorMessage = "An undefined Error happened.";
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Row picture(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 200,
          height: 100,
          margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.075,
              0, 0, MediaQuery.of(context).size.width * 0.2),
          decoration: const BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("lib/Images/Hello_There..png"),
          )),
        ),
      ],
    );
  }
}
