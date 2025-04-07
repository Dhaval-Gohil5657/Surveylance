import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:surveylance/App%20colors/colors.dart';

void showToast({required String message}){
  Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: gridcolor,
        textColor: Colors.black,
        fontSize: 16.0
    );
}