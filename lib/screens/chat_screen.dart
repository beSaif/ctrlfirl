import 'package:ctrlfirl/models/chat_document_model.dart';
import 'package:ctrlfirl/services/openai_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';

import 'package:ctrlfirl/controllers/chat_controller.dart';

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.

class ChatScreen extends StatefulWidget {
  final String recognizedText;
  final ChatDocumentModel? chatDocumentModel;
  const ChatScreen(
      {super.key, this.recognizedText = "", this.chatDocumentModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController chatController;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      chatController = Provider.of<ChatController>(context, listen: false);
      chatController.reset();
      if (widget.recognizedText.isNotEmpty) {
        String systemMesssage =
            '''You're a bot that helps users help answer questions about 
        a particular content. You can see the content below and answer 
        to any questions user may ask regarding them. Do not make up any false answers.''';
        chatController.setSystemMessage(systemMesssage,
            text: "\n Content: ${widget.recognizedText}");
        // chatController.startStream();
      } else if (widget.chatDocumentModel != null) {
        chatController.setChatDocumentModel(widget.chatDocumentModel);
        chatController.setAppbarSubtitle(widget.chatDocumentModel?.title ?? '');
        chatController
            .addMessagesFromFirebase(widget.chatDocumentModel?.messages ?? []);
        chatController.setChatDocCreatedinFirebase(true);
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
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                OpenaiHelper().generateTitle(
                    chatControllerConsumer.generateMessageForOpenAI());
              },
              child: const Icon(Icons.refresh),
            ),
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
                    : chatControllerConsumer.isPostRequestFailed
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: SizedBox(
                                child: IconButton(
                              onPressed: () {
                                // Since for user input and to regenerate, we are using the
                                // same function. The function requires types.PartialText.
                                // When generating, we pass a random value which will be ignored
                                // inside the function if regenerateResponse is set as true.
                                // this way user don't have to type the same message twice and the
                                // same thing won't be repeated twice in the data being sent to openai.
                                onSendPressed(
                                  const types.PartialText(text: 'Placeholder'),
                                  regenerateResponse: true,
                                );
                              },
                              icon: const Icon(Icons.refresh),
                            )),
                          )
                        : const SizedBox()
              ],
            ),
            body: Chat(
              theme: const DefaultChatTheme(
                backgroundColor: Colors.black26,
              ),
              messages: chatControllerConsumer.chatMessages,
              onSendPressed: chatControllerConsumer.isGeneratingResponse
                  ? handleGeneratingResponse
                  : onSendPressed,
              user: chatControllerConsumer.user,
            ),
          );
        }),
      );

  void onSendPressed(types.PartialText partialText,
      {bool regenerateResponse = false}) async {
    chatController.handleOnPressed(partialText,
        context: context, regenerateResponse: regenerateResponse);
  }

  handleGeneratingResponse(_) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 3),
        content: Text('Please wait while the current response is generated')));
  }
}
