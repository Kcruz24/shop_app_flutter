import 'package:flutter/material.dart';
import 'package:shop_app_flutter/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final String _id;
  final String _title;
  final String _imageUrl;

  ProductItem(this._id, this._title, this._imageUrl);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: _id,
            );
          },
          child: Image.network(
            _imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => {},
            color: Theme.of(context).accentColor,
          ),
          title: Text(
            _title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () => {},
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
