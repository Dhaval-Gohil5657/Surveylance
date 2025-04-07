import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:surveylance/App%20colors/colors.dart';

class CustomLoader extends StatelessWidget {
  final Color color;
  
  CustomLoader({this.color = appcolor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitThreeBounce( 
        color: color,
        size: 30.0,
      ),
    );
  }
}
