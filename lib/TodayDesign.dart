import 'package:flutter/material.dart';

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

  bool _isToday(DateTime date) {
    DateTime today = DateTime.now();
    return today.day == date.day &&
        today.month == date.month &&
        today.year == date.year;
  }

  List<dynamic> _filterList(List<dynamic> list) {
    List<dynamic> newList = List();

    list.forEach((value) {
      if (_isToday(DateTime.fromMillisecondsSinceEpoch(
          Map<String, dynamic>.from(value)['time']))) {
        newList.add(value);
      }
    });

    return newList;
  }

  Widget _totals(List<dynamic> list) {
    List<dynamic> fList = _filterList(list);
    double _calories = 0.0;
    double _protein = 0.0;
    double _carbohydrates = 0.0;
    double _fat = 0.0;

    double total = 1.0;

    fList.forEach((value) {
      if (value['per100']) {
        total = value['amount'] / 100.0;
      } else {
        total = 1.0;
      }
      _calories = double
          .parse((_calories + value['calories'] * total).toStringAsFixed(2));
      _protein = double
          .parse((_protein + value['protein'] * total).toStringAsFixed(2));
      _carbohydrates = double.parse(
          (_carbohydrates + value['carbohydrates'] * total).toStringAsFixed(2));
      _fat = double.parse((_fat + value['fat'] * total).toStringAsFixed(2));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text("$_calories kcal"),
        Text("$_protein g"),
        Text("$_carbohydrates g"),
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

  Map<int, int> _indexMap(List<dynamic> list) {
    int index = 0;
    int fIndex = 0;
    Map<int, int> map = Map();

    list.forEach((value) {
      if (_isToday(DateTime.fromMillisecondsSinceEpoch(
          Map<String, dynamic>.from(value)['time']))) {
        map[fIndex] = index;
        fIndex++;
      }
      index++;
    });

    return map;
  }

  @override
  Widget build(BuildContext context) {
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
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text("Loading...");
              if (snapshot.data['meals'].length == 0)
                return const Text("Welcome!");
              if (_filterList(snapshot.data['meals']).length == 0)
                return const Text("No meals today");
              double width = MediaQuery.of(context).size.width;
              return Expanded(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Calories: "),
                              Text("Protein: "),
                              Text("Carbohydrates: "),
                              Text("Fat: "),
                            ],
                          ),
                          _totals(snapshot.data['meals']),
                        ],
                      ),
                    ),
                    Row(
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
                    // DropdownButton(
                    //   value: _sortAllBy100,
                    //   items: <DropdownMenuItem>[
                    //     DropdownMenuItem(
                    //       child: Text("Total"),
                    //       value: false,
                    //     ),
                    //     DropdownMenuItem(
                    //       child: Text("Per 100g"),
                    //       value: true,
                    //     ),
                    //   ],
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _sortAllBy100 = value;
                    //     });
                    //   },
                    // ),
                    // FlatButton(
                    //         child: Text(_sortAllBy100 ? "Per 100g" : "Total"),
                    //         onPressed: () {
                    //           setState(() {
                    //             _sortAllBy100 = !_sortAllBy100;
                    //           });
                    //         },
                    //       ),
                    // SizedBox(
                    //   height: 16.0,
                    // ),
                    Expanded(
                      child: ListView.builder(
                        itemExtent: 125.0,
                        itemCount: _filterList(snapshot.data['meals']).length,
                        itemBuilder: (context, index) {
                          var list = Map<String, dynamic>.from(
                              _filterList(snapshot.data['meals'])[index]);
                          var indexMap = _indexMap(snapshot.data['meals']);
                          // return ListTile(
                          //   title: Row(
                          //     children: <Widget>[
                          //       Text(list['title']),
                          //       Text(list['amount'].toString()),
                          //       Text(list['title']),
                          //     ],
                          //   ),
                          // );
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Card(
                              child: ListTile(
                                onLongPress: () {
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
                                              Firestore.instance.runTransaction(
                                                  (transaction) async {
                                                DocumentSnapshot freshSnap =
                                                    await transaction.get(
                                                        snapshot
                                                            .data.reference);
                                                List<dynamic> newList = List
                                                    .from(freshSnap['meals']);
                                                newList
                                                    .removeAt(indexMap[index]);
                                                await transaction.update(
                                                    freshSnap.reference,
                                                    {"meals": newList});
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                onTap: () {},
                                title: Column(
                                  children: <Widget>[
                                    // Text(_sortAllBy100 ? "Per 100g" : "Total"),
                                    // SizedBox(
                                    //   height: 16.0,
                                    // ),
                                    Text(
                                      list['title'],
                                      style: Theme.of(context).textTheme.body2,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(_toTime(list['time'])),
                                          // Text(_sortAllBy100
                                          //     ? "Per 100g"
                                          //     : "Total"),
                                          Text("" +
                                              list['amount'].toString() +
                                              "g"),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text("Calories: "),
                                              Text("Protein: "),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Text(_getValue(
                                                  list['calories'],
                                                  list['amount'],
                                                  list['per100'])),
                                              Text(_getValue(
                                                  list['protein'],
                                                  list['amount'],
                                                  list['per100'])),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text("Carbs: "),
                                              Text("Fat: "),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Text(_getValue(
                                                  list['carbohydrates'],
                                                  list['amount'],
                                                  list['per100'])),
                                              Text(_getValue(
                                                  list['fat'],
                                                  list['amount'],
                                                  list['per100'])),
                                            ],
                                          ),
                                        ],
                                      ),
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
