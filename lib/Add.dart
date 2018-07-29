import 'package:flutter/material.dart';

// import 'package:food_tracker/NC.dart';
import 'package:food_tracker/QuickAdd.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Add extends StatelessWidget {
  final FirebaseUser _user;

  Add(this._user);

  @override
  Widget build(BuildContext context) {
    return MyAdd(_user);
  }
}

class MyAdd extends StatefulWidget {
  final FirebaseUser _user;

  MyAdd(this._user);

  @override
  _MyAddState createState() => _MyAddState(_user);
}

class _MyAddState extends State<MyAdd> {
  final FirebaseUser _user;

  _MyAddState(this._user);

  String _title;
  double _amount;
  DateTime _time = DateTime.now();
  bool _per100 = true;
  double _calories;
  double _protein;
  double _carbohydrates;
  double _sugars;
  double _fat;

  bool _disableSaveQuickAdd = false;

  bool _validFields() {
    return _title != null && _amount != null;
    // _calories != null &&
    // _protein != null &&
    // _carbohydrates != null &&
    // _fat != null;
  }

  String _toTime(DateTime t) {
    String h = t.hour < 10 ? "0${t.hour}" : t.hour.toString();
    String m = t.minute < 10 ? "0${t.minute}" : t.minute.toString();
    return "$h:$m";
  }

  String _toDate(DateTime t) {
    String d = t.day < 10 ? "0${t.day}" : t.day.toString();
    String m = t.month < 10 ? "0${t.month}" : t.month.toString();
    String y = t.year.toString();
    return "$d.$m.$y";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: !_validFields()
                ? null
                : () {
                    Firestore.instance.runTransaction((transaction) async {
                      DocumentSnapshot freshSnap = await transaction.get(
                          Firestore.instance
                              .collection('users')
                              .document(_user.uid)
                              .collection('meals')
                              .document(_toDate(_time)));
                      var data = {
                        'title': _title,
                        'amount': _amount,
                        'per100': _per100,
                        'calories': _calories == null ? 0.0 : _calories,
                        'protein': _protein == null ? 0.0 : _protein,
                        'carbohydrates':
                            _carbohydrates == null ? 0.0 : _carbohydrates,
                        'sugars': _sugars == null ? 0.0 : _sugars,
                        'fat': _fat == null ? 0.0 : _fat,
                        'time': _time.millisecondsSinceEpoch
                      };
                      if (freshSnap.exists) {
                        List<dynamic> newList = List.from(freshSnap['meals']);
                        newList.add(data);
                        await transaction
                            .update(freshSnap.reference, {"meals": newList});
                      } else {
                        List<dynamic> newList = List();
                        newList.add(data);
                        await transaction
                            .set(freshSnap.reference, {"meals": newList});
                      }
                      Navigator.pop(context);
                    });
                  },
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(32.0),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton(
                child: Text("Quick add"),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => QuickAdd(_user)));
                },
              ),
              RaisedButton(
                child: Text("Save to quick add"),
                onPressed: !_validFields() || _disableSaveQuickAdd
                    ? null
                    : () {
                        setState(() {
                          _disableSaveQuickAdd = true;
                        });
                        Firestore.instance.runTransaction((transaction) async {
                          DocumentSnapshot freshSnap = await transaction.get(
                              Firestore.instance
                                  .collection('users')
                                  .document(_user.uid));
                          List<dynamic> newList =
                              List.from(freshSnap['quickAdds']);
                          newList.add({
                            'title': _title,
                            'amount': _amount,
                            'per100': _per100,
                            'calories': _calories == null ? 0.0 : _calories,
                            'protein': _protein == null ? 0.0 : _protein,
                            'carbohydrates':
                                _carbohydrates == null ? 0.0 : _carbohydrates,
                            'sugars': _sugars == null ? 0.0 : _sugars,
                            'fat': _fat == null ? 0.0 : _fat,
                            'time': DateTime.now().millisecondsSinceEpoch
                          });
                          await transaction.update(
                              freshSnap.reference, {"quickAdds": newList});
                        });
                      },
              ),
            ],
          ),
          TextField(
            decoration: InputDecoration(labelText: "Title"),
            onChanged: (value) {
              setState(() {
                _title = value.length == 0 ? null : value;
                _disableSaveQuickAdd = false;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: "Amount (in grams)"),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _amount = value.length == 0.0 ? null : double.parse(value);
                _disableSaveQuickAdd = false;
              });
            },
          ),
          SizedBox(
            height: 16.0,
          ),
          // FlatButton(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: <Widget>[
          //       Text(
          //         "${_toDate(_time)}",
          //         style: Theme.of(context).textTheme.display1,
          //       ),
          //       Text(
          //         "${_toTime(_time)}",
          //         style: Theme.of(context).textTheme.display1,
          //       ),
          //     ],
          //   ),
          //   onPressed: () async {
          //     DateTime dt = await showDatePicker(
          //         context: context,
          //         initialDate: _time,
          //         firstDate: DateTime(2018),
          //         lastDate: DateTime(DateTime.now().year + 1));

          //     if (dt != null) {
          //       TimeOfDay dt2 = await showTimePicker(
          //           context: context, initialTime: TimeOfDay.now());

          //       if (dt2 != null) {
          //         setState(() {
          //           _time = DateTime(
          //               dt.year, dt.month, dt.day, dt2.hour, dt2.minute);
          //         });
          //       }
          //     }
          //   },
          // ),
          SizedBox(
            height: 32.0,
          ),
          Text(
            "Nutritional Content",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("per 100g"),
              Switch(
                onChanged: (bool value) {
                  setState(() {
                    _per100 = value;
                    _disableSaveQuickAdd = false;
                  });
                },
                value: _per100,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Calories"),
                    Container(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _calories = value.length == 0.0
                                ? null
                                : double.parse(value);
                            _disableSaveQuickAdd = false;
                          });
                        },
                      ),
                      width: MediaQuery.of(context).size.width / 3.0,
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Protein"),
                    Container(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _protein = value.length == 0.0
                                ? null
                                : double.parse(value);
                            _disableSaveQuickAdd = false;
                          });
                        },
                      ),
                      width: MediaQuery.of(context).size.width / 3.0,
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Carbohydrates"),
                    Container(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _carbohydrates = value.length == 0.0
                                ? null
                                : double.parse(value);
                            _disableSaveQuickAdd = false;
                          });
                        },
                      ),
                      width: MediaQuery.of(context).size.width / 3.0,
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Sugars"),
                    Container(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _sugars = value.length == 0.0
                                ? null
                                : double.parse(value);
                            _disableSaveQuickAdd = false;
                          });
                        },
                      ),
                      width: MediaQuery.of(context).size.width / 3.0,
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Fat"),
                    Container(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _fat = value.length == 0.0
                                ? null
                                : double.parse(value);
                            _disableSaveQuickAdd = false;
                          });
                        },
                      ),
                      width: MediaQuery.of(context).size.width / 3.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
