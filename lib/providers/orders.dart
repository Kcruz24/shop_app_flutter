import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../widgets/cart_item.dart';
import '../widgets/order_item.dart';

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
        'shop-app-flutter-24-default-rtdb.firebaseio.com', '/orders.json');

    final timestamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'dateTime': timestamp.toIso8601String(), // this function is a uniform representation of dates which we can later convert to a datetime object.
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        },
      ),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );

    notifyListeners();
  }
}
