import 'package:flutter/material.dart';

import 'package:food_tracker/Edit.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Today extends StatelessWidget {
  final FirebaseUser _user;

  Today(this._user);

  @override
  Widget build(BuildContext context) {
    return MyToday(_user);
  }
}

class MyToday extends StatefulWidget {
  final FirebaseUser _user;

  MyToday(this._user);

  @override
  _MyTodayState createState() => _MyTodayState(_user);
}

class _MyTodayState extends State<MyToday> {
  final FirebaseUser _user;

  _MyTodayState(this._user);

  bool _sortAllBy100 = false;
  bool _documentExists = false;

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

  String _getValue(value, amount, per100) {
    if (per100 && !_sortAllBy100) {
      return (value * (amount / 100.0)).toStringAsFixed(2);
    } else if (!per100 && _sortAllBy100) {
      return ((value / amount) * 100.0).toStringAsFixed(2);
    }
    return (value).toStringAsFixed(2);
  }

  String _toTime(int time) {
    DateTime t = DateTime.fromMillisecondsSinceEpoch(time);
    String h = t.hour < 10 ? "0${t.hour}" : t.hour.toString();
    String m = t.minute < 10 ? "0${t.minute}" : t.minute.toString();
    return "$h:$m";
  }

  void _edit(list, index) {
    Map<dynamic, dynamic> values = Map();
    values['title'] = list['title'];
    values['amount'] = list['amount'];
    values['per100'] = list['per100'];
    values['calories'] = list['calories'];
    values['protein'] = list['protein'];
    values['carbohydrates'] = list['carbohydrates'];
    values['sugars'] = list['sugars'];
    values['fat'] = list['fat'];
    values['time'] = list['time'];
    values['index'] = index;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Edit(_user, values)));
  }

  void _delete(snapshot, index) {
    showDialog<Null>(
      context: context,
      // barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Discard meal?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('DISCARD'),
              onPressed: () {
                Navigator.of(context).pop();
                Firestore.instance.runTransaction((transaction) async {
                  DocumentSnapshot freshSnap =
                      await transaction.get(snapshot.data.reference);
                  List<dynamic> newList = List.from(freshSnap['meals']);
                  newList.removeAt(index);
                  await transaction
                      .update(freshSnap.reference, {"meals": newList});
                });
              },
            ),
          ],
        );
      },
    );
  }

  String _toDate(int time) {
    DateTime t = DateTime.fromMillisecondsSinceEpoch(time);
    String d = t.day < 10 ? "0${t.day}" : t.day.toString();
    String m = t.month < 10 ? "0${t.month}" : t.month.toString();
    String y = t.year.toString();
    return "$d.$m.$y";
  }

  void _listen() {
    Firestore.instance
        .collection('users')
        .document(_user.uid)
        .collection('meals')
        .document(_toDate(DateTime.now().millisecondsSinceEpoch))
        .snapshots()
        .listen((dataSnapshot) {
      if (!dataSnapshot.exists) {
        setState(() {
          _documentExists = false;
        });
      } else {
        if (dataSnapshot.data.containsKey('meals')) {
          setState(() {
            _documentExists = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listen();
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 0.0, left: 0.0, right: 0.0, top: 16.0),
      child: Column(
        children: <Widget>[
          Text(
            "Meals Today",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(
            height: 16.0,
          ),
          StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(_user.uid)
                .collection('meals')
                .document(_toDate(DateTime.now().millisecondsSinceEpoch))
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text("Loading...");
              if (!_documentExists) return const Text("Ny dag!");
              if (snapshot.data['meals'].length == 0)
                return const Text("Welcome!");
              double width = MediaQuery.of(context).size.width;
              return Expanded(
                child: Column(
                  children: <Widget>[
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
                          _totals(snapshot.data['meals']),
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: 16.0,
                    // ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Radio(
                                groupValue: _sortAllBy100,
                                onChanged: (value) {
                                  setState(() {
                                    _sortAllBy100 = value;
                                  });
                                },
                                value: false,
                              ),
                              Text("Total"),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Radio(
                                groupValue: _sortAllBy100,
                                onChanged: (value) {
                                  setState(() {
                                    _sortAllBy100 = value;
                                  });
                                },
                                value: true,
                              ),
                              Text("Per 100g"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        // itemExtent: 125.0,
                        itemCount: snapshot.data['meals'].length + 1,
                        itemBuilder: (context, index) {
                          if (index == snapshot.data['meals'].length)
                            return SizedBox(
                              height: 70.0,
                            );
                          var list = Map<String, dynamic>.from(
                              List.from(snapshot.data['meals'])[index]);

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Card(
                              child: ListTile(
                                onTap: () => _edit(list, index),
                                onLongPress: () => _delete(snapshot, index),
                                title: Column(
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        list['title'],
                                        style:
                                            Theme.of(context).textTheme.title,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(_toTime(list['time'])),
                                        Text(list['amount'].toString() + "g"),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "Calories: ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1,
                                              ),
                                              Text(
                                                "Protein: ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1,
                                              ),
                                              Text(
                                                "Carbs: ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              _getValue(
                                                  list['calories'],
                                                  list['amount'],
                                                  list['per100']),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                            Text(
                                              _getValue(
                                                  list['protein'],
                                                  list['amount'],
                                                  list['per100']),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                            Text(
                                              _getValue(
                                                  list['carbohydrates'],
                                                  list['amount'],
                                                  list['per100']),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 30.0,
                                          width: 1.0,
                                          color: Theme.of(context).primaryColor,
                                          margin: const EdgeInsets.only(
                                              left: 10.0, right: 10.0),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "Sugars: ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1,
                                              ),
                                              Text(
                                                "Fat: ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              _getValue(
                                                  list['sugars'],
                                                  list['amount'],
                                                  list['per100']),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                            Text(
                                              _getValue(
                                                  list['fat'],
                                                  list['amount'],
                                                  list['per100']),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
