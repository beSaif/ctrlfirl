import 'package:ctrlfirl/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.

class ChatScreen extends StatefulWidget {
  final String recognizedText;
  const ChatScreen({super.key, this.recognizedText = ""});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController chatController;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.recognizedText.isNotEmpty) {
        String systemMesssage =
            '''You're a bot that helps users help answer questions about 
        a particular content. You can see the content below and answer 
        to any questions user may ask regarding them. Do not make up any false answers.''';
        chatController = Provider.of<ChatController>(context, listen: false);
        chatController.addSystemMessage(systemMesssage,
            text: "\n Content: ${widget.recognizedText}");
        // chatController.startStream();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Consumer<ChatController>(
            builder: (context, chatControllerConsumer, child) {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chat'),
                  Text(
                    'with ${chatControllerConsumer.appbarSubtitle}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  )
                ],
              ),
              actions: [
                chatControllerConsumer.isGeneratingResponse
                    ? const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox()
              ],
            ),
            body: Chat(
              theme: const DefaultChatTheme(
                // inputBackgroundColor: Colors.white,
                // inputTextColor: Colors.black,
                // primaryColor: Colors.blue,
                backgroundColor: Colors.black26,
              ),
              messages: chatControllerConsumer.chatMessages,
              onSendPressed: chatControllerConsumer.isGeneratingResponse
                  ? handleGeneratingResponse
                  : onSendPressed,
              user: chatController.user,
            ),
          );
        }),
      );

  void onSendPressed(types.PartialText partialText) async {
    chatController.handleOnPressed(partialText, context: context);
  }

  handleGeneratingResponse(_) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 3),
        content: Text('Please wait while the current response is generated')));
  }
}
