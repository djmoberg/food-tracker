import 'package:flutter/material.dart';

// import 'package:food_tracker/NC.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Edit extends StatelessWidget {
  final FirebaseUser _user;
  final Map<dynamic, dynamic> _values;

  Edit(this._user, this._values);

  @override
  Widget build(BuildContext context) {
    return MyEdit(_user, _values);
  }
}

class MyEdit extends StatefulWidget {
  final FirebaseUser _user;
  final Map<dynamic, dynamic> _values;

  MyEdit(this._user, this._values);

  @override
  _MyEditState createState() => _MyEditState(_user, _values);
}

class _MyEditState extends State<MyEdit> {
  final FirebaseUser _user;
  final Map<dynamic, dynamic> _values;

  _MyEditState(this._user, this._values);

  String _title;
  double _amount;
  DateTime _time;
  bool _per100;
  double _calories;
  double _protein;
  double _carbohydrates;
  double _sugars;
  double _fat;
  TextEditingController _titleController;
  TextEditingController _amountController;
  TextEditingController _caloriesController;
  TextEditingController _proteinController;
  TextEditingController _carbohydratesController;
  TextEditingController _sugarsController;
  TextEditingController _fatController;

  bool _disableSaveQuickAdd = false;

  @override
  void initState() {
    super.initState();

    _titleController =
        new TextEditingController(text: _values['title'].toString());
    _amountController =
        new TextEditingController(text: _values['amount'].toString());
    _caloriesController =
        new TextEditingController(text: _values['calories'].toString());
    _proteinController =
        new TextEditingController(text: _values['protein'].toString());
    _carbohydratesController =
        new TextEditingController(text: _values['carbohydrates'].toString());
    _sugarsController =
        new TextEditingController(text: _values['sugars'].toString());
    _fatController = new TextEditingController(text: _values['fat'].toString());
    _title = _values['title'].toString();
    _amount = double.parse(_values['amount'].toString());
    _time = DateTime.fromMillisecondsSinceEpoch(_values['time']);
    _per100 = _values['per100'];
    _calories = double.parse(_values['calories'].toString());
    _protein = double.parse(_values['protein'].toString());
    _carbohydrates = double.parse(_values['carbohydrates'].toString());
    _sugars = double.parse(_values['sugars'].toString());
    _fat = double.parse(_values['fat'].toString());
  }

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
        title: Text("Edit"),
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
                      List<dynamic> newList = List.from(freshSnap['meals']);
                      newList.removeAt(_values['index']);
                      newList.insert(_values['index'], {
                        'title': _title,
                        'amount': _amount,
                        'per100': _per100,
                        'calories': _calories == null ? 0.0 : _calories,
                        'protein': _protein == null ? 0.0 : _protein,
                        'carbohydrates':
                            _carbohydrates == null ? 0.0 : _carbohydrates,
                        'sugars': _sugars == null ? 0.0 : _sugars,
                        'fat': _fat == null ? 0.0 : _fat,
                        'time': _time.millisecondsSinceEpoch,
                      });
                      await transaction
                          .update(freshSnap.reference, {"meals": newList});
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
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
            controller: _titleController,
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
            controller: _amountController,
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
          //           context: context,
          //           initialTime:
          //               TimeOfDay(hour: _time.hour, minute: _time.minute));

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
                        controller: _caloriesController,
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
                        controller: _proteinController,
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
                        controller: _carbohydratesController,
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
                        controller: _sugarsController,
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
                        controller: _fatController,
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
