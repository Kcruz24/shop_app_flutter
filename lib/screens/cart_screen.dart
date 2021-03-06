import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/order_button.dart';
import '../providers/cart.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final themeContext = Theme.of(context);
    final listMapValues = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: themeContext.primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: themeContext.primaryColor,
                  ),
                  OrderButton(cart: cart, themeContext: themeContext),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (ctx, i) => CartItem(
                id: listMapValues[i].id,
                productId: cart.items.keys.toList()[i],
                price: listMapValues[i].price,
                quantity: listMapValues[i].quantity,
                title: listMapValues[i].title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
