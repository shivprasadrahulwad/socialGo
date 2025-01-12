import 'package:flutter/material.dart';
import 'package:social/call/video_call_screen.dart';

class OwnVideoCallingHomeScreen extends StatefulWidget {
  const OwnVideoCallingHomeScreen({super.key});

  @override
  State<OwnVideoCallingHomeScreen> createState() => _OwnVideoCallingHomeScreenState();
}

class _OwnVideoCallingHomeScreenState extends State<OwnVideoCallingHomeScreen> {

  final TextEditingController _channelController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video calling'),
        centerTitle: true,
      ),
      body: SafeArea(child: Column(
        children: [
          TextFormField(
            controller: _channelController,
            decoration: InputDecoration(
              labelText: 'Enter channel name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20,),
          ElevatedButton(onPressed: () {
            final channelName = _channelController.text;
            if(channelName.isNotEmpty){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> VideoCallScreen(channelName:channelName, callerName: 'Shivam ',)));
            }
          }, child: Text('Join Call'))
        ],
      )),
    );
  }
}