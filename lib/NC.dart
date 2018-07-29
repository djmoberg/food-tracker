import 'package:flutter/material.dart';

class NC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyNC();
  }
}

class MyNC extends StatefulWidget {
  @override
  _MyNCState createState() => _MyNCState();
}

class _MyNCState extends State<MyNC> {
  bool _per100 = true;
  List<Food> _food = [];
  String _ncName;
  int _ncAmount;

  TextEditingController _ncNameController = TextEditingController();
  TextEditingController _ncAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
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
                  });
                },
                value: _per100,
              ),
            ],
          ),
          TextField(
            decoration: InputDecoration(labelText: "Name"),
            controller: _ncNameController,
            onChanged: (value) {
              setState(() {
                _ncName = value.length == 0 ? null : value;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: "Amount (in grams)"),
            controller: _ncAmountController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _ncAmount = value.length == 0 ? null : int.parse(value);
              });
            },
          ),
          RaisedButton(
              child: Text("Add"),
              onPressed: _ncName != null && _ncAmount != null
                  ? () {
                      _food.add(Food(name: _ncName, amount: _ncAmount));
                      setState(() {
                        _ncName = null;
                        _ncAmount = null;
                      });
                      _ncNameController.clear();
                      _ncAmountController.clear();
                    }
                  : null),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _food.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_food[index].name),
                  leading: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {},
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Food {
  final String name;
  final int amount;

  Food({this.name, this.amount});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(name: json['name'], amount: json['amount']);
  }
}
