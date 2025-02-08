// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:social/confession/confession_card.dart';
import 'package:social/constants/global_variables.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:social/group/groupo_messge_widget.dart';
import 'package:social/group/groupr_messge_widget.dart';
import 'package:social/model/groupMessag.dart';

class ConfessionScreen extends StatefulWidget {
  final String name;
  final String userId;

  const ConfessionScreen({
    Key? key,
    required this.name,
    required this.userId,
  }) : super(key: key);

  @override
  _ConfessionScreenState createState() => _ConfessionScreenState();
}

class _ConfessionScreenState extends State<ConfessionScreen> {
  final TextEditingController _messageController = TextEditingController();
  IO.Socket? socket;
  List<MsgModel> listMsg = [];

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    socket = IO.io('http://192.168.1.112:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket!.onConnect((_) {
      print('✅ Socket connected into frontend successfully');
      socket!.on('sendMsgServer', (msg) {
        print(msg);
        if (msg["userId"] != widget.userId) {
          setState(() {
            listMsg.add(MsgModel(
                type: msg["msg"], msg: msg["type"], sender: msg["senderName"]));
          });
        }
      });
    });

    socket!.onConnectError((err) {
      print('❌ Connection Error: $err');
    });

    socket!.onError((err) {
      print('❌ Socket Error: $err');
    });

    socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });
  }

  void sendMsg(String msg, String senderName) {
    MsgModel ownMsg = MsgModel(msg: msg, sender: senderName, type: "ownMsg");
    listMsg.add(ownMsg);
    setState(() {
      listMsg;
    });
    socket!.emit('sendMsg', {
      "type": "ownMsg",
      "msg": msg,
      "senderName": senderName,
      "userId": widget.userId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confession')),
      body: Container(
        color: GlobalVariables.backgroundColor,
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
              itemCount: listMsg.length,
              itemBuilder: (context, index) {
                // final msg = listMsg[index];
                if (listMsg[index].type == "ownMsg") {
                  return OwnMsgWidget(
                      sender: listMsg[index].sender, msg: listMsg[index].msg);
                } else {
                  return OtherMsgWidget(
                      sender: listMsg[index].sender, msg: listMsg[index].msg);
                }
              },
            )),
            ConfessionCard(
              content:
                  "I've been pretending to understand calculus all semester. My friends think I'm helping them, but I'm actually learning from teaching them 😅",
              category: "Academic Life",
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              likes: 234,
              supports: 89,
              isAnonymous: true,
              onLike: () {
                // Handle like action
              },
              onShare: () {
                // Handle share action
              },
              onReport: () {
                // Handle report action
              },
            ),
            // if(user == 'admin')
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: TextField(
            //           controller: _messageController,
            //           decoration: InputDecoration(
            //             hintText: 'Type a message...',
            //             border: OutlineInputBorder(),
            //           ),
            //         ),
            //       ),
            //       IconButton(
            //         icon: Icon(Icons.send),
            //         onPressed: () {
            //           print('tapped');
            //           final msg = _messageController.text;
            //           if (msg.isNotEmpty) {
            //             sendMsg(msg, widget.name);
            //             _messageController.clear();
            //           }
            //         },
            //       ),
            //     ],
            //   ),
            // ),

            // if(user != 'admin')
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "Your today's quota has been ended, it will be renewed on 12:00 AM in Midnight",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
