import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/orders.dart';

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
    @required this.themeContext,
  }) : super(key: key);

  final Cart cart;
  final ThemeData themeContext;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;


  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('Order Now'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              );

              setState(() {
                _isLoading = false;
              });

              widget.cart.clearCart();
            },
      textColor: widget.themeContext.primaryColor,
    );
  }
}
