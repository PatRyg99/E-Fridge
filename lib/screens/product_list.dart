import 'dart:async';
import 'package:flutter/material.dart';
import 'package:e_fridge/models/product.dart';
import 'package:e_fridge/utils/database_helper.dart';
import 'package:e_fridge/screens/product_detail.dart';
import 'package:e_fridge/screens/info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ProductList extends StatefulWidget {
  int parentId;

  ProductList(this.parentId);

  @override
  _ProductListState createState() => _ProductListState(parentId);
}

class _ProductListState extends State<ProductList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Product> productList;
  int parentId;
  int count = 0;
  bool _sortDesc = false;
  String _sortBy = 'Name';

  final TextEditingController searchController = TextEditingController();

  _ProductListState(int parentId) {
    this.parentId = parentId;
  }

  Widget build(BuildContext context) {

    if(productList == null) {
      productList = List<Product>();
      refreshListView();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(parentId == 0 ? "My fridge" : "My shopping list"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info_outline), onPressed: () => _goToInfoPage(context)),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  refreshListView();
                },
                controller: searchController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search by name",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))
                    ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5.0),
                child: ListTile(
                  title: new Row(
                  children: <Widget>[
                    Text("Sort by: "),
                    Container(width: 10),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: sortOptions(),
                      onChanged: (String sortBy) {
                        _sortBy = sortBy;
                        _sort();
                      },
                    ),
                    Container(width: 10),
                    GestureDetector(
                      child: new Icon(
                        _sortDesc ? Icons.arrow_downward : Icons.arrow_upward,
                        color: Colors.black45
                      ),
                      onTap: () {
                        _sortDesc = !_sortDesc;
                        _sort();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            Expanded(
              child: count>0 ? getProductListView() : defaultText(),
            ),
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Product('',1,'','',parentId),'Add product');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  List<DropdownMenuItem<String>> sortOptions() {
    if(parentId == 0) {
      return <DropdownMenuItem<String>>[
        new DropdownMenuItem(child: new Text('Name'), value: 'Name'),
        new DropdownMenuItem(child: new Text('Quantity'), value: 'Quantity'),
        new DropdownMenuItem(child: new Text('Expiration date'), value: 'Expiration date'),
      ];
    } else {
      return <DropdownMenuItem<String>>[
        new DropdownMenuItem(child: new Text('Name'), value: 'Name'),
        new DropdownMenuItem(child: new Text('Quantity'), value: 'Quantity'),
      ];
    }
  }

  Widget defaultText(){
    return Center(
        child: Container(
          width: 300.0,
          child: Text(
            "There are no products.",
            textAlign: TextAlign.center,
          ),
        )
    );
  }

  ListView getProductListView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: getItemCard,
        padding: EdgeInsets.all(0.0)
    );
  }

  Card getItemCard(BuildContext context, int position) {
    return new Card(
        child: new ListTile(
            leading: productList[position].image=='' ? new Image.asset(
              "cutlery.png",
              width: 80,
              fit: BoxFit.contain,
            ) : new Image.memory(
              Base64Decoder().convert( productList[position].image),
              width: 80,
              fit: BoxFit.cover,
            ),

            title: new Text(
              this.productList[position].name,
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),

            subtitle: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  "Quantity: "+this.productList[position].quantity.toString(),
                  style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
                ),
                parentId==1 ? new Container() : new Text(
                  "Expiration date:\n"+this.productList[position].expirationDate,
                  style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
                )
              ],
            ),

            onTap: () {
              navigateToDetail(this.productList[position],"Edit product");
            },

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _deleteProductDialog(context, productList[position]);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      alignment: Alignment.center,
                      child: Icon(Icons.delete),
                    )
                ),

                parentId==0 ? Container() : GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _migrateProductDialog(context, productList[position]);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      alignment: Alignment.center,
                      child: Icon(Icons.forward),
                    )
                )
              ]
            )
        )
    );
  }

  // Methods and widgets to migrate product
  void _migrateProductDialog(BuildContext context, Product product) async{

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              title: new Text("Migrate a product?"),
              content: Container(
                  height: 130,
                  child: Column(
                    children: <Widget>[
                      Text(
                          "Product: "+product.name+" will be moved from shopping list to fridge."+
                              " You need to set its expiration date first."
                      ),
                      new ListTile(
                        leading:  const Icon(Icons.today),
                        title: const Text("Expiration date"),
                        subtitle: Text(product.expirationDate==null ? "Set expiration date" : product.expirationDate),
                        onTap: () {
                          Navigator.of(context).pop();
                         _selectDate(product);
                        }
                      )//),
                    ],
                  )
              ),
              actions: <Widget>[
                new FlatButton(
                    child: new Text("Cancel"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    }
                ),
                new FlatButton(
                    child: new Text("Accept"),
                    onPressed: (){
                      if(product.expirationDate!=null){
                        Navigator.of(context).pop();
                        _migrate(product);
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: new Text('Status'),
                                content: new Text('Expiration date cannot be empty'),
                              );
                            }
                        );
                      }
                    }
                )
              ]
          );
        }
    );
  }



  void  _migrate(Product product) async {
    int result = await databaseHelper.migrateProduct(product);
    if(result != 0) {
      _showSnackBar('Product Migrated Successfully');
      refreshListView();
    } else {
      _showSnackBar('Error occurred when migrating');
      refreshListView();
    }
  }

  Future _selectDate(Product product) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime.now().subtract(new Duration(days: 1)),
      lastDate: new DateTime(DateTime.now().year+10),
    );

    if(picked != null) {
      setState(() => product.expirationDate = DateFormat.yMMMd().format(picked));
    }
    _migrateProductDialog(context, product);
  }

  // Methods and widgets to delete product
  void _deleteProductDialog(BuildContext context, Product product) async {

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              title: new Text("Delete a product?"),
              content: Text("Product: "+product.name+" will be deleted"),
              actions: <Widget>[
                new FlatButton(
                    child: new Text("Cancel"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    }
                ),
                new FlatButton(
                    child: new Text("Accept"),
                    onPressed: (){
                      Navigator.of(context).pop();
                      _delete(product);
                    }
                ),
              ]
          );
        }
    );
  }

  void _delete(Product product) async {
    int result = await databaseHelper.deleteProduct(product.id);
    if(result != 0) {
      _showSnackBar('Product Deleted Successfully');
      refreshListView();
    }
  }

  void _sort() {

    switch (_sortBy) {

      case 'Name':
        setState(() {
          if(_sortDesc){
            productList.sort((x,y) => y.name.compareTo(x.name));
          } else {
            productList.sort((x,y) => x.name.compareTo(y.name));
          }
        });
        break;

      case 'Quantity':
        setState(() {
          if (_sortDesc) {
            productList.sort((x, y) => y.quantity < x.quantity ? 1 : 0);
          } else {
            productList.sort((x, y) => x.quantity < y.quantity ? 1 : 0);
          }
        });
        break;

      case 'Expiration date':
        setState(() {
          if (_sortDesc) {
            productList.sort((x, y) =>
                new DateFormat("yMMMd").parse(y.expirationDate).compareTo(
                    new DateFormat("yMMMd").parse(x.expirationDate)
                )
            );
          } else {
            productList.sort((x, y) =>
                new DateFormat("yMMMd").parse(x.expirationDate).compareTo(
                    new DateFormat("yMMMd").parse(y.expirationDate)
                )
            );
          }
        });
        break;
      }
  }

  void _showSnackBar(String message) {

    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void navigateToDetail(Product product, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProductDetail(product, title);
    }));

    if(result == true) {
      refreshListView();
    }
  }

  void refreshListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Product>> productListFuture = databaseHelper.getProductListByParentId(parentId);
      productListFuture.then((productList) {
        setState(() {

          this.productList = productList;
          if(productList.length > 0){
            productList.removeWhere((p) => !p.name.contains(searchController.text));
          }

          this.count = productList.length;
          if(count > 0){
            _sort();
          }
        });
      });
    });
  }

  void _goToInfoPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Info())
    );
  }
}