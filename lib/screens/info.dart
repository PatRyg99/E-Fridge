import 'package:flutter/material.dart';

class Info extends StatefulWidget {

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Info'),
        ),
        body: new SingleChildScrollView(
          child: Column(
            children: <Widget>[
              new Container(height: 25),
              new Container(
                width: MediaQuery.of(context).size.width,
                height: 150.0,
                child: Image.asset('app_icon.png'),
              ),
              new Container(height: 25),
              new ListTile(
                title: Text("Author", style: new TextStyle(fontSize: 25.0)),
                subtitle: Text("Patryk Rygiel", style: new TextStyle(fontSize: 18.0))
              ),
              new ListTile(
                title: Text("Version", style: new TextStyle(fontSize: 25.0)),
                subtitle: Text("1.0.0", style: new TextStyle(fontSize: 18.0))
              ),
              new ListTile(
                title: Text("Usability"),
                subtitle: Text(
                    "Application E-Fridge is intended to store information about food products. "
                    "They can be stored in two places: 'My Fridge' and 'My Shopping List'. "
                    "Products in the shopping list do not contain expiration date and can be "
                    "migrated to fridge by pressing arrow button and filling expiration date. "
                    "Each product contains fields: name, quantity, expiration date and image which can "
                    "be added from local gallery or be made via built-in camera - option of adding image "
                    "is currently disabled.",
                )
              ),
              new ListTile(
                title: Text("Credits"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text("- Fridge icon:"),
                    new Text("     Icon made by Roundicons"),
                    new Text("     from www.flaticon.com"),
                    new Text("- Shopping list icon:"),
                    new Text("     Icon made by Jason Chalibert"),
                    new Text("     from www.myiconfinder.com"),
                    new Text("- Cutlery icon:"),
                    new Text("     Icon made by Freepik"),
                    new Text("     from www.flaticon.com"),
                    new Text("- Main app icon:"),
                    new Text("     Icon made by Freepik"),
                    new Text("     from www.flaticon.com")
                  ],
                ),
              ),
              new Container(height: 25),
            ],
          ),
        ),
    );
  }
}