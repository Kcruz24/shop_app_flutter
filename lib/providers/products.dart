import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../data/products_data.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

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

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var params = {
      'auth': '$authToken',
      'orderBy': '"creatorId"',
      'equalTo': '"$userId"',
    };

    var filterString;

    if (filterByUser) {
      filterString = params;
    } else {
      filterString = {'auth': '$authToken'};
    }

    var url = Uri.https(
      'shop-app-flutter-24-default-rtdb.firebaseio.com',
      '/products.json',
      filterString,
    );

    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      url = Uri.https('shop-app-flutter-24-default-rtdb.firebaseio.com',
          '/userFavorites/$userId.json', {'auth': '$authToken'});

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite: favoriteData == null
                ? false
                : favoriteData[prodId] ?? false, // after the "??" is a fallback
            imageUrl: prodData['imageUrl'],
          ),
        );
      });

      _items = loadedProducts;
      notifyListeners();
      // print(json.decode(res.body));
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https('shop-app-flutter-24-default-rtdb.firebaseio.com',
        '/products.json', {'auth': '$authToken'});

    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );

      final newProduct = Product(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);

    if (productIndex >= 0) {
      final url = Uri.https('shop-app-flutter-24-default-rtdb.firebaseio.com',
          '/products/$id.json', {'auth': '$authToken'});

      try {
        await http.patch(
          url,
          body: json.encode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            },
          ),
        );
      } catch (error) {
        print('HERE IS THE ERROR $error');
        throw error;
      }

      _items[productIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https('shop-app-flutter-24-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': '$authToken'});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    // Delete before getting the response
    _items.removeAt(existingProductIndex);
    notifyListeners();

    try {
      final res = await http.delete(url);
      if (res.statusCode >= 400) {
        // This is known as "Optimistic updating"
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException('Could not delete product.', res.statusCode);
      }
    } catch (error) {
      print('ERROR UPDATING: $error');

      // reset the product
      existingProduct = null;

      throw error;
    }
  }
}
