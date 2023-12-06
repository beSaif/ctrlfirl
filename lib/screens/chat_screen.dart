import 'package:ctrlfirl/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ChatController chatController =
          Provider.of<ChatController>(context, listen: false);
      // chatController.startStream();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child:
            Consumer<ChatController>(builder: (context, chatController, child) {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chat'),
                  Text(
                    'with ${chatController.appbarSubtitle}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  )
                ],
              ),
              actions: const [],
            ),
            body: Chat(
              theme: const DefaultChatTheme(
                // inputBackgroundColor: Colors.white,
                // inputTextColor: Colors.black,
                // primaryColor: Colors.blue,
                backgroundColor: Colors.black26,
              ),
              messages: chatController.chatMessages,
              onSendPressed: chatController.handleOnPressed,
              user: chatController.user,
            ),
          );
        }),
      );
}
