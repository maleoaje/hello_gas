import 'package:flutter/material.dart';

class Item1 extends StatelessWidget {
  const Item1({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            image: AssetImage("assets/images/slides/slide_1.png"),
          ),
        ],
      ),
    );
  }
}

class Item2 extends StatelessWidget {
  const Item2({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            image: AssetImage("assets/images/slides/slide_2.png"),
          ),
        ],
      ),
    );
  }
}

class Item3 extends StatelessWidget {
  const Item3({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            image: AssetImage("assets/images/slides/slide_3.png"),
          ),
        ],
      ),
    );
  }
}
