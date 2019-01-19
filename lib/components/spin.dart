import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Spin extends StatelessWidget {
  @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return SpinKitFadingCircle(
        size: 30.0,
        itemBuilder: (_, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.blue,
            ),
          );
        },
      );
    }
}

