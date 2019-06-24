import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuickAdd extends StatelessWidget {
  final FirebaseUser _user;

  QuickAdd(this._user);

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
        title: Text("Quick add"),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(_user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Loading...");
          return ListView.builder(
            itemExtent: 80.0,
            itemCount: snapshot.data['quickAdds'].length,
            itemBuilder: (context, index) {
              var list = Map<String, dynamic>.from(
                  List.from(snapshot.data['quickAdds'])[index]);
              return ListTile(
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
                              Firestore.instance
                                  .runTransaction((transaction) async {
                                DocumentSnapshot freshSnap = await transaction
                                    .get(snapshot.data.reference);
                                List<dynamic> newList =
                                    List.from(freshSnap['quickAdds']);
                                newList.removeAt(index);
                                await transaction.update(freshSnap.reference,
                                    {"quickAdds": newList});
                              });
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                leading: Icon(Icons.fastfood),
                title: Text(list['title']),
                subtitle: Text("Amount: ${list['amount']}g"),
                onTap: () {
                  Firestore.instance.runTransaction((transaction) async {
                    DocumentSnapshot freshSnap = await transaction.get(Firestore
                        .instance
                        .collection('users')
                        .document(_user.uid)
                        .collection('meals')
                        .document(_toDate(DateTime.now())));
                    if (freshSnap.exists) {
                      List<dynamic> newList = List.from(freshSnap['meals']);
                      list['time'] = DateTime.now().millisecondsSinceEpoch;
                      newList.add(list);
                      await transaction
                          .update(freshSnap.reference, {"meals": newList});
                    } else {
                      List<dynamic> newList = List();
                      list['time'] = DateTime.now().millisecondsSinceEpoch;
                      newList.add(list);
                      await transaction
                          .set(freshSnap.reference, {"meals": newList});
                    }
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
