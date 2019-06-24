import 'package:flutter/material.dart';

import 'package:food_tracker/Edit.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealList extends StatelessWidget {
  final FirebaseUser _user;
  final List<dynamic> _fList;

  MealList(this._user, this._fList);

  @override
  Widget build(BuildContext context) {
    return MyMealList(_user, _fList);
  }
}

class MyMealList extends StatefulWidget {
  final List<dynamic> _fList;
  final FirebaseUser _user;

  MyMealList(this._user, this._fList);

  @override
  _MyMealListState createState() => _MyMealListState(_user, _fList);
}

class _MyMealListState extends State<MyMealList> {
  final List<dynamic> _fList;
  final FirebaseUser _user;

  _MyMealListState(this._user, this._fList);

  bool _sortAllBy100 = false;

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

  String _toDate(int time) {
    DateTime t = DateTime.fromMillisecondsSinceEpoch(time);
    String d = t.day < 10 ? "0${t.day}" : t.day.toString();
    String m = t.month < 10 ? "0${t.month}" : t.month.toString();
    String y = t.year.toString();
    return "$d.$m.$y";
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

  void _delete(index) {
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
                  DocumentSnapshot freshSnap = await transaction.get(Firestore
                      .instance
                      .collection('users')
                      .document(_user.uid));
                  List<dynamic> newList = List.from(freshSnap['meals']);
                  newList.removeAt(index);
                  await transaction
                      .update(freshSnap.reference, {"meals": newList});
                  setState(() {});
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _addSpace(index) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(
        Map<String, dynamic>.from(_fList[index])['time']);
    if (index != 0) {
      DateTime dt2 = DateTime.fromMillisecondsSinceEpoch(
          Map<String, dynamic>.from(_fList[index - 1])['time']);
      if (dt.day != dt2.day) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: 16.0,
            ),
            Text(
              _toDate(dt.millisecondsSinceEpoch),
              style: Theme.of(context).textTheme.headline,
            ),
          ],
        );
      }
    } else {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          Text(
            _toDate(dt.millisecondsSinceEpoch),
            style: Theme.of(context).textTheme.headline,
          ),
        ],
      );
    }
    return SizedBox(
      height: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            // itemExtent: 110.0,
            itemCount: _fList.length,
            itemBuilder: (context, index) {
              var list = Map<String, dynamic>.from(_fList[index]);

              return Column(
                children: <Widget>[
                  _addSpace(index),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      child: ListTile(
                        // onTap: () => _edit(list, index),
                        // onLongPress: () => _delete(index),
                        title: Column(
                          children: <Widget>[
                            Center(
                              child: Text(
                                list['title'],
                                style: Theme.of(context).textTheme.title,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_toTime(list['time'])),
                                // Text(_toDate(list['time'])),
                                Text(list['amount'].toString() + "g"),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Calories: ",
                                        style:
                                            Theme.of(context).textTheme.body1,
                                      ),
                                      Text(
                                        "Protein: ",
                                        style:
                                            Theme.of(context).textTheme.body1,
                                      ),
                                      Text(
                                        "Carbs: ",
                                        style:
                                            Theme.of(context).textTheme.body1,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      _getValue(list['calories'],
                                          list['amount'], list['per100']),
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                    Text(
                                      _getValue(list['protein'], list['amount'],
                                          list['per100']),
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                    Text(
                                      _getValue(list['carbohydrates'],
                                          list['amount'], list['per100']),
                                      style: Theme.of(context).textTheme.body2,
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
                                        style:
                                            Theme.of(context).textTheme.body1,
                                      ),
                                      Text(
                                        "Fat: ",
                                        style:
                                            Theme.of(context).textTheme.body1,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      _getValue(list['sugars'], list['amount'],
                                          list['per100']),
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                    Text(
                                      _getValue(list['fat'], list['amount'],
                                          list['per100']),
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
