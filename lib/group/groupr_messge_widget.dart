// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class OtherMsgWidget extends StatelessWidget {
  final String sender;
  final String msg;
  const OtherMsgWidget({
    Key? key,
    required this.sender,
    required this.msg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          color: Colors.yellow,
          child: Column(
            children: [
              Text('~${sender}',textAlign: TextAlign.right,),
              Text(msg
              ,textAlign: TextAlign.right,),
            ],
          ),
        ),
      ),
    );
  }
}
