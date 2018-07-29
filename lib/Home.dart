import 'package:flutter/material.dart';

import 'package:food_tracker/Add.dart';
import 'package:food_tracker/Today.dart';
import 'package:food_tracker/Statistics.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatelessWidget {
  final FirebaseUser _user;

  Home(this._user);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Image.network(
                          "https://facelex.com/img/foodTracker.png",
                        ),
                      ),
                    ),
                    Text(
                      _user.email,
                      style: Theme.of(context).textTheme.subhead,
                    ),
                  ],
                ),
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Sign out"),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.insert_chart)),
            ],
          ),
          title: Text('Food Tracker'),
        ),
        body: TabBarView(
          children: [
            Today(_user),
            Statistics(_user),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Add(_user)));
          },
        ),
      ),
    );
  }
}
