import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/products_data.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [...products_data];

  var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }

    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  void addProduct(Product product) {
    final url = Uri.https(
        'shop-app-flutter-24-default-rtdb.firebaseio.com', '/products.json');
    http.post(
      url,
      body: json.encode(
        {
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        },
      ),
    );
    final newProduct = Product(
      id: DateTime.now().toString(),
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      isFavorite: product.isFavorite,
    );

    _items.add(newProduct);

    notifyListeners();
  }

  void updateProduct(String id, Product newProduct) {
    final productIndex = _items.indexWhere((prod) => prod.id == id);

    if (productIndex >= 0) {
      _items[productIndex] = newProduct;
    }

    notifyListeners();
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
