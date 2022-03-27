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

  final String authToken;

  Orders(this.authToken, this._orders);

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https('shop-app-flutter-24-default-rtdb.firebaseio.com',
        '/orders.json', {'auth': '$authToken'});

    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ))
              .toList(),
        ),
      );
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();

    print('This is the body: ${json.decode(response.body)}');
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
        'shop-app-flutter-24-default-rtdb.firebaseio.com', '/orders.json', {'auth': '$authToken'});

    final timestamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'dateTime': timestamp
              .toIso8601String(), // this function is a uniform representation of dates which we can later convert to a datetime object.
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
