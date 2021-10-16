import 'package:flutter/material.dart';

import '../data/products_data.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [...products_data];

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void addProduct() {
    // _items.add(value);
    notifyListeners();
  }
}
