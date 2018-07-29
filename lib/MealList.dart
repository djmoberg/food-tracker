import 'package:flutter/material.dart';

import 'package:food_tracker/Edit.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealList extends StatelessWidget {
  final FirebaseUser _user;
  final List<dynamic> _fList;
  final Map<int, int> _indexMap;

  MealList(this._user, this._fList, this._indexMap);

  @override
  Widget build(BuildContext context) {
    return MyMealList(_user, _fList, _indexMap);
  }
}

class MyMealList extends StatefulWidget {
  final List<dynamic> _fList;
  final FirebaseUser _user;
  final Map<int, int> _indexMap;

  MyMealList(this._user, this._fList, this._indexMap);

  @override
  _MyMealListState createState() => _MyMealListState(_user, _fList, _indexMap);
}

class _MyMealListState extends State<MyMealList> {
  final List<dynamic> _fList;
  final FirebaseUser _user;
  final Map<int, int> _indexMap;

  _MyMealListState(this._user, this._fList, this._indexMap);

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
            itemCount: _fList.length + 1,
            itemBuilder: (context, index) {
              if (index == _fList.length)
                return SizedBox(
                  height: 70.0,
                );
              var list = Map<String, dynamic>.from(_fList[index]);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: ListTile(
                    onTap: () => _edit(list, _indexMap[index]),
                    onLongPress: () => _delete(_indexMap[index]),
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
                            Text(list['amount'].toString() + "g"),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Calories: ",
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                  Text(
                                    "Protein: ",
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                  Text(
                                    "Carbs: ",
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  _getValue(list['calories'], list['amount'],
                                      list['per100']),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Sugars: ",
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                  Text(
                                    "Fat: ",
                                    style: Theme.of(context).textTheme.body1,
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
              );
            },
          ),
        ),
      ],
    );
  }
}
