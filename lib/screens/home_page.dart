import 'package:e_fridge/screens/info.dart';
import 'package:flutter/material.dart';
import 'package:e_fridge/screens/product_list.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.info_outline), onPressed: () => _goToInfoPage(context)),
          ],
        ),
        body: ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              GestureDetector(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: listElement(0)
                ),
                onTap: () => _goToProductsPage(context, 0),
              ),
              GestureDetector(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: listElement(1)
                ),
                onTap: () => _goToProductsPage(context, 1),
              ),
            ]
        )
    );
  }

  Widget listElement(int elementId){
    return Container(
        child: FittedBox(
            child: Material(
                color: Colors.indigo,
                elevation: 14.0,
                borderRadius: BorderRadius.circular(24.0),
                shadowColor: Colors.indigoAccent,
                child: Row(
                    children: <Widget>[
                      Container(
                        height: 200,
                        child: detailsContainer(elementId),
                      ),
                      Container(
                          width: 180,
                          height: 180,
                          child: Image(
                            fit: BoxFit.contain,
                            alignment: Alignment.topRight,
                            image: AssetImage(elementId==0 ? "fridge.png" : "shopping_list.png"),
                          )
                      )
                    ]
                )
            )
        )
    );
  }

  Widget detailsContainer(int elementId){
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 14.0),
              child: Container(
                child: Text(
                  elementId==0 ? "My Fridge" : "My shopping list",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Container(
              width: 200,
              child: Text(
                elementId==0 ? "Here you can store and manage content of your fridge."
                    : "Here you can create and manage your custom shopping list.",
                style: TextStyle(color: Colors.white70, fontSize: 18.0,),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ]
    );
  }

  void _goToProductsPage(BuildContext context, int index) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductList(index))
    );
  }

  void _goToInfoPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Info())
    );
  }
}