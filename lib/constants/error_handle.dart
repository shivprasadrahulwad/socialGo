import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:social/constants/utils.dart';

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  switch (response.statusCode) {
    
    case 200:
      onSuccess();
      break;
    case 400:
      CustomSnackBar.show(context, jsonDecode(response.body)['msg']);
      break;
    case 500:
      CustomSnackBar.show(context, jsonDecode(response.body)['error']);
      break;
    default:
      CustomSnackBar.show(context, response.body);
  }
}