import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sina/template/admin_home.dart';
import 'package:sina/template/home_page.dart';
import 'package:sina/template/misc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordVerController = TextEditingController();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
          child: loading
              ? CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                )
              : ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    picture(context),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputField(
                              controller: nameController,
                              icon: Icons.person_outline_sharp,
                              hint: "Full name",
                              keyboard: TextInputType.name,
                              isPass: false,
                            ),
                            InputField(
                              controller: emailController,
                              icon: Icons.email_outlined,
                              hint: "E-mail",
                              keyboard: TextInputType.emailAddress,
                              isPass: false,
                            ),
                            InputField(
                              controller: phoneController,
                              icon: Icons.phone,
                              hint: "Phone number",
                              keyboard: TextInputType.phone,
                              isPass: false,
                            ),
                            InputField(
                              controller: addressController,
                              icon: Icons.location_on,
                              hint: "Address",
                              keyboard: TextInputType.streetAddress,
                              isPass: false,
                            ),
                            InputField(
                              controller: passwordController,
                              icon: Icons.key,
                              hint: "Password",
                              keyboard: TextInputType.visiblePassword,
                              isPass: true,
                            ),
                            InputField(
                              controller: passwordVerController,
                              icon: Icons.key,
                              hint: "Re-enter password",
                              keyboard: TextInputType.visiblePassword,
                              isPass: true,
                            ),
                            FormButton(
                                formKey: _formKey,
                                color: Theme.of(context).primaryColor,
                                text: "Sign Up",
                                textColor: Colors.white,
                                x: (context) async {
                                  if (passwordController.text ==
                                      passwordVerController.text) {
                                    // setState(() {
                                    //   loading = true;
                                    // });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Creating new account')),
                                    );
                                    var x = await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: emailController.text,
                                            password: passwordController.text);
                                    await FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(x.user!.uid.toString())
                                        .set({
                                      "full_name": nameController.text,
                                      "email": emailController.text,
                                      "phone": phoneController.text,
                                      "address": addressController.text,
                                      "id": x.user!.uid.toString(),
                                      "is_admin": false
                                    });
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Passwords do not match')),
                                    );
                                  }
                                }),
                          ],
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    SignTextButton(
                        context: context,
                        route: const AdminHomePage(),
                        leading: "Do you have an account ?  ",
                        button: "Sign In"),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                )),
    );
  }

  Row picture(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 250,
          height: 80,
          margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.075,
              0, 0, MediaQuery.of(context).size.width * 0.2),
          decoration: const BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.scaleDown,
            image: AssetImage("lib/Images/Make_New_Account..png"),
          )),
        ),
      ],
    );
  }
}
