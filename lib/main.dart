import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:social/login_signup/screens/signin_screen.dart';
import 'package:social/login_signup/services/auth_services.dart';
import 'package:social/model/chatData.dart';
import 'package:social/model/message.dart';
import 'package:social/models/poll.dart';
import 'package:social/providers/user_provider.dart';
import 'package:social/screens/chat/camera_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PollAdapter());
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(ChatDataAdapter());
  }
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  Hive.registerAdapter(MessageStatusAdapter());
  Hive.registerAdapter(MessageContentAdapter());
  Hive.registerAdapter(ContactInfoAdapter());
  Hive.registerAdapter(ReadStatusAdapter());
  Hive.registerAdapter(DeliveryStatusAdapter());
  Hive.registerAdapter(ReactionAdapter());
  Hive.registerAdapter(DeleteStatusAdapter());

  await Hive.openBox<Poll>('polls');
  await Hive.openBox<Message>('messages');
await Hive.openBox<ChatData>('chatData');
  // Debug: Print the path where Hive stores data
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();

  cameras = await availableCameras();
  // runApp(const MyApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignInScreen(),
    );
  }
}
