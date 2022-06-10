import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  const FormButton(
      {Key? key,
      required GlobalKey<FormState> formKey,
      required this.color,
      required this.text,
      required this.textColor,
      required this.x})
      : _formKey = formKey,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final String text;
  final Color color, textColor;
  final Function x;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          x(context);
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              border: Border.all(
                  style: BorderStyle.solid,
                  color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(25)),
          child: Center(
              child: Text(
            text,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w500, fontSize: 18),
          ))),
    );
  }
}

class InputField extends StatefulWidget {
  const InputField(
      {Key? key,
      required this.controller,
      required this.icon,
      required this.hint,
      required this.keyboard,
      required this.isPass})
      : super(key: key);

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final bool isPass;

  @override
  // ignore: no_logic_in_create_state
  State<InputField> createState() => _InputFieldState(showPass: isPass);
}

class _InputFieldState extends State<InputField> {
  _InputFieldState({required this.showPass});
  bool showPass;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      width: MediaQuery.of(context).size.width * 0.85,
      child: TextFormField(
        // cursorHeight: 25,
        // maxLength: 30,
        keyboardType: widget.keyboard,
        obscureText: showPass,
        decoration: InputDecoration(
            errorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: Icon(widget.icon),
            suffixIcon: widget.isPass
                ? InkWell(
                    child: showPass
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    onTap: () {
                      setState(() {
                        showPass = !showPass;
                      });
                    },
                  )
                : null,
            hintText: widget.hint),
        controller: widget.controller,
        maxLines: 1,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          if (value.length >= 35) {
            return 'Max length is 30';
          }
          if (widget.hint.toLowerCase().contains("phone")) {
            final exp = RegExp(
                r"^\s*(?:\+?(\d{0,3}))?[-. (]*(\d{1})[-. )]*(\d{2})[-. ]*(\d{2})[-. ]*(\d{2})[-. ]*(\d{2})\s*$");
            if (!exp.hasMatch(value)) {
              //replaceAll(RegExp(r'\D'), "")
              return "Please type a valid number";
            }
          } else if (widget.hint.toLowerCase().contains("mail")) {
            final exp = RegExp(r"^[\w\.]+@([\w-]+\.)+[\w-]{2,4}$");
            if (!exp.hasMatch(value)) {
              return "Please type a valid E-mail";
            }
          } else if (widget.hint.toLowerCase().contains("password")) {
            if (value.length < 8) {
              return "Password too short";
            }
          }
          return null;
        },
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button(
      {Key? key,
      required this.color,
      required this.text,
      required this.textColor,
      required this.x})
      : super(key: key);

  final String text;
  final Color color, textColor;
  final Function x;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        x();
      },
      child: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.09),
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              border: Border.all(
                  style: BorderStyle.solid,
                  color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(25)),
          child: Center(
              child: Text(
            text,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w500, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ))),
    );
  }
}

class SignTextButton extends StatelessWidget {
  const SignTextButton(
      {Key? key,
      required this.context,
      required this.route,
      required this.leading,
      required this.button})
      : super(key: key);

  final BuildContext context;
  final Widget route;
  final String leading, button;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(leading, style: const TextStyle(color: Colors.black, fontSize: 15)),
      InkWell(
        onTap: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => route));
        },
        child: Text(button,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
      ),
    ]);
  }
}
