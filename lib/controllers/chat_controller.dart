import 'dart:convert';
import 'dart:math';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatController extends ChangeNotifier {
  String _appbarSubtitle = "";
  String get appbarSubtitle => _appbarSubtitle;
  setAppbarSubtitle(String newTitle) {
    _appbarSubtitle = newTitle;
    notifyListeners();
  }

  startStream() async {
    await createStream();
    await listenStream();
  }

  final user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  List<types.Message> _userMessages = [];
  List<types.Message> get userMessages => _userMessages;
  setUserMessages(List<types.Message> newUserMessages) {
    _userMessages = newUserMessages;
    notifyListeners();
  }

  addMessage(types.TextMessage newMessage) {
    _userMessages.insert(0, newMessage);
    notifyListeners();
  }

  // The user message to be sent to the request.
  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "Hello my friend!",
      ),
    ],
    role: OpenAIChatMessageRole.user,
  );

  Stream<OpenAIStreamChatCompletionModel>? _chatStream;
  Stream<OpenAIStreamChatCompletionModel>? get chatStream => _chatStream;
  setChatStream(Stream<OpenAIStreamChatCompletionModel> newChatStream) {
    _chatStream = newChatStream;
    notifyListeners();
  }

  Future createStream() async {
    debugPrint("Creating Stream");
    try {
      var localChatStream = OpenAI.instance.chat.createStream(
        model: "gpt-3.5-turbo",
        messages: [
          userMessage,
        ],
        seed: 423,
        n: 2,
      );
      setChatStream(localChatStream);
    } catch (e) {
      debugPrint("Error occured while creating chat stream: $e");
      rethrow;
    }
  }

  listenStream() async {
    if (chatStream == null) {
      debugPrint("chatStream: $_chatStream");
      return;
    }
    debugPrint("Listenting to stream: $_chatStream");

    return chatStream?.listen(
      (streamChatCompletion) {
        final content = streamChatCompletion.choices.first.delta.content;
        debugPrint("Stream content: $content");
      },
      onDone: () {
        debugPrint("Stream Done");
      },
    );
  }

  handleOnPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    addMessage(textMessage);
  }

// Listen to the stream.
}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}
