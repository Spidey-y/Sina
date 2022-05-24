import 'package:flutter/material.dart';
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
            x: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loging in to your account')),
              );
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
