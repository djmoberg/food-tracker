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

  DateTime _fromDay = DateTime.now().subtract(Duration(days: 6));
  DateTime _toDay = DateTime.now();
  List<dynamic> _stuff = List();
  int _daysNoMeal = 0;
  bool _listen = true;

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

  Widget _averages(List<dynamic> list) {
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

    int days = _toDay.difference(_fromDay).inDays + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text("${(_calories / (days - _daysNoMeal)).toStringAsFixed(2)} kcal"),
        Text("${(_protein / (days - _daysNoMeal)).toStringAsFixed(2)} g"),
        Text("${(_carbohydrates / (days - _daysNoMeal)).toStringAsFixed(2)} g"),
        Text("${(_sugars / (days - _daysNoMeal)).toStringAsFixed(2)} g"),
        Text("${(_fat / (days - _daysNoMeal)).toStringAsFixed(2)} g"),
      ],
    );
  }

  String _toDate(int time) {
    DateTime t = DateTime.fromMillisecondsSinceEpoch(time);
    String d = t.day < 10 ? "0${t.day}" : t.day.toString();
    String m = t.month < 10 ? "0${t.month}" : t.month.toString();
    String y = t.year.toString();
    return "$d.$m.$y";
  }

  void _test() {
    int days = _toDay.difference(_fromDay).inDays;
    int day = _fromDay.millisecondsSinceEpoch;
    List<dynamic> data = List();

    setState(() {
      _daysNoMeal = 0;
    });

    for (int i = 0; i <= days && _listen; i++) {
      DocumentReference dr = Firestore.instance
          .collection('users')
          .document(_user.uid)
          .collection('meals')
          .document(_toDate(day));
      dr.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          List.from(snapshot.data['meals']).forEach((value) {
            data.add(value);
          });

          setState(() {
            _stuff = data;
          });
        } else {
          setState(() {
            _daysNoMeal = _daysNoMeal + 1;
          });
        }
      });
      day = day + Duration.millisecondsPerDay;
    }
    setState(() {
      _listen = false;
    });
  }

  Widget _daysNoMealText() {
    String text = "";
    if (_daysNoMeal == 0) {
      text = "";
    } else if (_daysNoMeal == 1) {
      text = "Found 1 day with no meals\nThis will not be calculated";
    } else {
      text =
          "Found $_daysNoMeal days with no meals\nThese will not be calculated";
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Theme.of(context).errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_listen) {
      _test();
    }
    double width = MediaQuery.of(context).size.width;
    return ListView(
      padding: EdgeInsets.only(top: 16.0),
      children: <Widget>[
        Text(
          "Statistics",
          //last ${_toDay.difference(_fromDay).inDays + 1} days
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: (width * 0.20) + 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Start"),
              FlatButton(
                padding: EdgeInsets.all(0.0),
                child: Text(
                  "${_toDate(_fromDay.millisecondsSinceEpoch)}",
                  style: Theme.of(context).textTheme.headline,
                ),
                onPressed: () async {
                  DateTime dt = await showDatePicker(
                      context: context,
                      initialDate: _fromDay,
                      firstDate: DateTime(2018),
                      lastDate: _toDay);

                  if (dt != null) {
                    setState(() {
                      _fromDay = dt;
                      _listen = true;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: (width * 0.20) + 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("End"),
              FlatButton(
                padding: EdgeInsets.all(0.0),
                child: Text(
                  "${_toDate(_toDay.millisecondsSinceEpoch)}",
                  style: Theme.of(context).textTheme.headline,
                ),
                onPressed: () async {
                  DateTime dt = await showDatePicker(
                      context: context,
                      initialDate: _toDay,
                      firstDate: _fromDay,
                      lastDate: DateTime.now());

                  if (dt != null) {
                    setState(() {
                      _toDay = dt;
                      _listen = true;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        _daysNoMealText(),
        SizedBox(
          height: 16.0,
        ),
        Text(
          "Average",
          style: Theme.of(context).textTheme.headline,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 8.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: (width * 0.16) + 16.0),
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
              _averages(_stuff),
            ],
          ),
        ),
        SizedBox(
          height: 32.0,
        ),
        Text(
          "Total",
          style: Theme.of(context).textTheme.headline,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 8.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: (width * 0.16) + 16.0),
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
              _totals(_stuff),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 100.0, vertical: 16.0),
          child: RaisedButton(
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
                          _stuff,
                        ),
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
