
class Product {

  int _id;
  String _name;
  int _quantity;
  String _expirationDate;
  String _image;
  int _parentId; //0-fridge, 1-shopping_list

  Product(this._name, this._quantity, this._expirationDate, this._image, this._parentId);
  Product.withId(this._id, this._name, this._quantity, this._expirationDate, this._image, this._parentId);

  int get id => _id;
  String get name => _name;
  int get quantity => _quantity;
  String get expirationDate => _expirationDate;
  String get image => _image;
  int get parentId => _parentId;

  set id(int id){this._id = id;}
  set name(String name){this._name = name;}
  set quantity(int quantity){this._quantity = quantity;}
  set expirationDate(String expirationDate){this._expirationDate = expirationDate;}
  set image(String image){this._image = image;}
  set parentId(int parentId){
    if(parentId >= 1 && parentId <= 2){
      this._parentId = parentId;
    }
  }

  // Convert a Product object into a Map object
  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();
    if(id != null){
      map['id'] = _id;
    }
    map['name'] = _name;
    map['quantity'] = _quantity;
    map['expiration_date'] = _expirationDate;
    map['image'] = _image;
    map['parent_id'] = _parentId;

    return map;
  }

  // Extract a Product object from a Map object
  Product.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this.quantity = map['quantity'];
    this._expirationDate = map['expiration_date'];
    this._image = map['image'];
    this._parentId = map['parent_id'];
  }

}