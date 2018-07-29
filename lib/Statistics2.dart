import 'dart:async';

import 'package:flutter/material.dart';

import 'package:food_tracker/Edit.dart';
import 'package:food_tracker/MealList.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Statistics extends StatelessWidget {
  final FirebaseUser _user;

  Statistics(this._user);

  @override
  Widget build(BuildContext context) {
    return MyStatistics(_user);
  }
}

class MyStatistics extends StatefulWidget {
  final FirebaseUser _user;

  MyStatistics(this._user);

  @override
  _MyStatisticsState createState() => _MyStatisticsState(_user);
}

class _MyStatisticsState extends State<MyStatistics> {
  final FirebaseUser _user;

  _MyStatisticsState(this._user);

  bool _sortAllBy100 = false;
  DateTime _filterDay = DateTime.now();

  Widget _totals(List<dynamic> list) {
    double _calories = 0.0;
    double _protein = 0.0;
    double _carbohydrates = 0.0;
    double _sugars = 0.0;
    double _fat = 0.0;

    double total = 1.0;

    list.forEach((value) {
      if (value['per100']) {
        total = value['amount'] / 100.0;
      } else {
        total = 1.0;
      }
      _calories = double.parse(
          (_calories + value['calories'] * total).toStringAsFixed(2));
      _protein = double.parse(
          (_protein + value['protein'] * total).toStringAsFixed(2));
      _carbohydrates = double.parse(
          (_carbohydrates + value['carbohydrates'] * total).toStringAsFixed(2));
      _sugars =
          double.parse((_sugars + value['sugars'] * total).toStringAsFixed(2));
      _fat = double.parse((_fat + value['fat'] * total).toStringAsFixed(2));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text("$_calories kcal"),
        Text("$_protein g"),
        Text("$_carbohydrates g"),
        Text("$_sugars g"),
        Text("$_fat g"),
      ],
    );
  }

  Map<int, int> _indexMap(List<dynamic> list) {
    int index = 0;
    int fIndex = 0;
    Map<int, int> map = Map();

    list.forEach((value) {
      if (DateTime.fromMillisecondsSinceEpoch(
                  Map<String, dynamic>.from(value)['time'])
              .day ==
          _filterDay.day) {
        map[fIndex] = index;
        fIndex++;
      }
      index++;
    });

    return map;
  }

  String _toDate(int time) {
    DateTime t = DateTime.fromMillisecondsSinceEpoch(time);
    String d = t.day < 10 ? "0${t.day}" : t.day.toString();
    String m = t.month < 10 ? "0${t.month}" : t.month.toString();
    String y = t.year.toString();
    return "$d.$m.$y";
  }

  List<dynamic> _filterList(List<dynamic> list) {
    List<dynamic> newList = List();

    list.forEach((value) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(
          Map<String, dynamic>.from(value)['time']);
      if (dt.day == _filterDay.day &&
          dt.month == _filterDay.month &&
          dt.year == _filterDay.year) {
        newList.add(value);
      }
    });

    return newList;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 0.0, left: 0.0, right: 0.0, top: 16.0),
      child: Column(
        children: <Widget>[
          StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(_user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text("Loading...");
              if (snapshot.data['meals'].length == 0)
                return const Text("Welcome!");
              double width = MediaQuery.of(context).size.width;
              return Expanded(
                child: Column(
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "Meals ${_toDate(_filterDay.millisecondsSinceEpoch)}",
                        style: Theme.of(context).textTheme.headline,
                      ),
                      onPressed: () async {
                        DateTime dt = await showDatePicker(
                            context: context,
                            initialDate: _filterDay,
                            firstDate: DateTime(2018),
                            lastDate: DateTime.now());

                        if (dt != null) {
                          setState(() {
                            _filterDay = dt;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: (width * 0.16) + 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Calories: "),
                              Text("Protein: "),
                              Text("Carbohydrates: "),
                              Text("Sugars: "),
                              Text("Fat: "),
                            ],
                          ),
                          _totals(_filterList(snapshot.data['meals'])),
                        ],
                      ),
                    ),
                    RaisedButton(
                      child: Text("View"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: Text("Meals"),
                                  ),
                                  body: MealList(
                                    _user,
                                    _filterList(snapshot.data['meals']),
                                    _indexMap(snapshot.data['meals']),
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
