import 'package:flutter/material.dart';
import 'package:validate/validate.dart';

import 'package:food_tracker/Register.dart';
import 'package:food_tracker/PasswordReset.dart';
import 'package:food_tracker/Localizations.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Loc.of(context).title),
        ),
        body: MyCustomForm());
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";
  bool _loading = false;

  void _login() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _loading = true;
      });
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(Loc.of(context).loggingIn)));
      _formKey.currentState.save();
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _username, password: _password);
      } catch (e) {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(Loc.of(context).somethingWentWrong)));
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Form(
            key: _formKey,
            child: Center(
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
                  Image.network(
                    "https://facelex.com/img/foodTracker.png",
                    height: 100.0,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      } else {
                        try {
                          Validate.isEmail(value);
                        } catch (e) {
                          return 'The E-mail Address must be a valid email address.';
                        }
                      }
                    },
                    decoration: InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String value) {
                      setState(() {
                        _username = value;
                      });
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                    },
                    decoration: InputDecoration(labelText: "Passord"),
                    obscureText: true,
                    onFieldSubmitted: (value) {
                      _login();
                    },
                    onSaved: (String value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                  SizedBox(height: 24.0),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: RaisedButton(
                        color: Colors.red,
                        onPressed: _login,
                        child: Text('Login'),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text(Loc.of(context).createAccount),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register()));
                        },
                      ),
                      FlatButton(
                        child: Text("Forgot password?"),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PasswordReset()));
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
