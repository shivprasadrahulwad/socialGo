// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:social/group/groupo_messge_widget.dart';
import 'package:social/group/groupr_messge_widget.dart';
import 'package:social/model/groupMessag.dart';

class GroupChatScreen extends StatefulWidget {
  final String name;
  final String userId;

  const GroupChatScreen({
    Key? key,
    required this.name,
    required this.userId,
  }) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  IO.Socket? socket;
  List<MsgModel> listMsg = [];

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    socket = IO.io('http://192.168.2.140:3000', <String, dynamic>{
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Name;${widget.name}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    print('tapped');
                    final msg = _messageController.text;
                    if (msg.isNotEmpty) {
                      sendMsg(msg, widget.name);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
