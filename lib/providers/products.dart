import 'package:flutter/material.dart';

import '../data/products_data.dart';
import '../models/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [...products_data];

  List<Product> get items {
    return [..._items];
  }

  void addProduct() {
    // _items.add(value);
    notifyListeners();
  }
}
