import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:food_tracker/Login.dart';
import 'package:food_tracker/Home.dart';
import 'package:food_tracker/Localizations.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseUser;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => Loc.of(context).title,
      localizationsDelegates: [
        const LocDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('nb', 'NO'),
      ],
      title: 'Food Tracker',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: "Food Tracker",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isAuthenticated = false;
  FirebaseUser _user;

  void _listener() {
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _isAuthenticated = user != null;
        _user = user != null ? user : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _listener();
    return _isAuthenticated ? Home(_user) : Login();
  }
}
