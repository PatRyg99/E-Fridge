import 'package:flutter/material.dart';
import 'dart:async';
import 'package:e_fridge/models/product.dart';
import 'package:e_fridge/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ProductDetail extends StatefulWidget {
  final String appBarTitle;
  final Product product;

  ProductDetail(this.product, this.appBarTitle);

  @override
  ProductDetailState createState() => ProductDetailState(this.product, this.appBarTitle);
}

class ProductDetailState extends State<ProductDetail> {
  DatabaseHelper helper = DatabaseHelper();
  Product product;
  String appBarTitle;
  String quantity = "1";

  //To encode image to string: base64Encode(List<int> = image.readAsBytesSync());
  //To decode image from string Base64Decoder().convert(image);
  var image;

  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  ProductDetailState(this.product, this.appBarTitle);

  initState(){
    super.initState();
    quantity = product.quantity.toString();
    image = Base64Decoder().convert(product.image);
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = product.name;
    quantityController.text = quantity;

    return Scaffold(
        appBar: AppBar(
            title: Text(appBarTitle),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              new GestureDetector(
                onTap: null,//updateImage, // Adding photos currently bugged, debugging in progress
                child: new Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200.0,
                  child: Image.asset("cutlery.png"),
                  //child: product.image=='' ? Image.asset('cutlery.png', fit: BoxFit.contain)
                  //    : Image.memory(image, fit: BoxFit.contain),
                ),
              ),

              new ListTile(
                leading:  const Icon(Icons.fastfood),
                title: new TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    updateName();
                  },
                ),
              ),

              new ListTile(
                leading:  const Icon(Icons.widgets),
                title: new TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      updateQuantity();
                    },
                ),
              ),

              product.parentId==1 ? new Container() : new ListTile(
                leading:  const Icon(Icons.today),
                title: const Text("Expiration date"),
                subtitle: Text(product.expirationDate=="" ? "Set expiration date" : product.expirationDate),
                onTap: updateExpirationDate,
              ),

              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0, left: 10.0, right: 10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.4,
                        ),
                        onPressed: () {
                          setState(() {
                            _save();
                          });
                        },
                      ),
                    ),
                    Container(width: 15.0,),
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.4,
                        ),
                        onPressed: () {
                          setState(() {
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]
          )
        )
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateName() {
    product.name = nameController.text;
  }

  void updateQuantity() {
    quantity = quantityController.text;
  }

  Future<void> updateImage() async {
    List<int> imageBytes;
    String base64Image;

    return showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: new Text('Take a picture'),
                    onTap: openCamera,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: new Text('Select from gallery'),
                    onTap: openGallery,
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  void openGallery() async {
    List<int> imageBytes;
    String base64Image;

    var _pickedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    imageBytes = _pickedImage.readAsBytesSync();
    base64Image = base64Encode(imageBytes);

    setState(() {
      product.image = base64Image;
      image = imageBytes;
    });
    Navigator.pop(context);
  }

  void openCamera() async {
    List<int> imageBytes;
    String base64Image;

    var _pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    imageBytes = _pickedImage.readAsBytesSync();
    base64Image = base64Encode(imageBytes);

    setState(() {
      product.image = base64Image;
      image = imageBytes;
    });
    Navigator.pop(context);
  }

  Future updateExpirationDate() async {

    DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime.now().subtract(new Duration(days: 1)),
      lastDate: new DateTime(DateTime.now().year+10),
    );

    if(picked != null) {
      setState(() => product.expirationDate = DateFormat.yMMMd().format(picked));
    }
  }

  void _save() async {
    int result;

    var value = int.tryParse(quantity);
    if(value == null) {
      _showAlertDialog('Status', 'Invalid quantity');
      return;
    }

    if(product.parentId == 1) {
      product.expirationDate = null;
      if(product.name=='' ||  value < 1) {
        _showAlertDialog('Status', 'Data is invalid or incomplete');
        return;
      }
    } else {
      if(product.name=='' || product.expirationDate=='' || value < 1) {
        _showAlertDialog('Status', 'Data is invalid or incomplete');
        return;
      }
    }

    moveToLastScreen();

    product.quantity = int.parse(quantity);

    if(product.id != null) {
      result = await helper.updateProduct(product);
    } else {
      result = await helper.insertProduct(product);
    }

    if(result != 0) {
      _showAlertDialog('Status', 'Product saved successfully');
    } else {
      _showAlertDialog('Status', 'Problem has occured when saving product');
    }

  }

  void _delete() async {
    moveToLastScreen();

    if(product.id == null) {
      _showAlertDialog('Status', 'No product has been deleted');
      return;
    }

    int result = await helper.deleteProduct(product.id);
    if(result != 0) {
      _showAlertDialog('Status', 'Product deleted successfully');
    } else {
      _showAlertDialog('Status', 'Error occured while deletin product');
    }
  }

  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}