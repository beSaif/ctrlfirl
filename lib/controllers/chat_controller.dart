import 'dart:convert';
import 'dart:math';

import 'package:ctrlfirl/models/messages_model.dart';
import 'package:ctrlfirl/services/openai_helper.dart';
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

  // startStream() async {
  //   await createStream();
  //   await listenStream();
  // }

  final user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final assistant = const types.User(id: 'assistant');

  // This is used for the Chat widget to render
  List<types.Message> _chatMessages = [];
  List<types.Message> get chatMessages => _chatMessages;
  setchatMessages(List<types.Message> newchatMessages) {
    _chatMessages = newchatMessages;
    notifyListeners();
  }

  addMessage(types.TextMessage newMessage) {
    _chatMessages.insert(0, newMessage);
    notifyListeners();
  }

  updateAMessageById(String id, String newText) {
    final textMessage = chatMessages.firstWhere((element) => element.id == id)
        as types.TextMessage;
    if (newText == textMessage.text) return;
    _chatMessages.removeWhere((element) => element.id == id);
    _chatMessages.insert(
        0, textMessage.copyWith(text: "${textMessage.text}$newText"));
    notifyListeners();
  }

  OpenAIChatCompletionChoiceMessageModel _userMessages =
      const OpenAIChatCompletionChoiceMessageModel(
          content: [], role: OpenAIChatMessageRole.user);
  OpenAIChatCompletionChoiceMessageModel get userMessages => _userMessages;

  addUserMessage(String newMessage) {
    OpenAIChatCompletionChoiceMessageContentItemModel contentItem =
        OpenAIChatCompletionChoiceMessageContentItemModel.text(newMessage);

    List<OpenAIChatCompletionChoiceMessageContentItemModel> content = [];
    content.add(contentItem);
    content.addAll(_userMessages.content!);
    _userMessages = OpenAIChatCompletionChoiceMessageModel(
        content: content, role: OpenAIChatMessageRole.user);
    notifyListeners();
  }

  OpenAIChatCompletionChoiceMessageModel _assistantMessages =
      const OpenAIChatCompletionChoiceMessageModel(
          content: [], role: OpenAIChatMessageRole.assistant);
  OpenAIChatCompletionChoiceMessageModel get assistantMessages =>
      _assistantMessages;

  addAssistantMessage(String newMessage) {
    OpenAIChatCompletionChoiceMessageContentItemModel contentItem =
        OpenAIChatCompletionChoiceMessageContentItemModel.text(newMessage);

    List<OpenAIChatCompletionChoiceMessageContentItemModel> content = [];
    content.add(contentItem);
    content.addAll(_assistantMessages.content!);
    _assistantMessages = OpenAIChatCompletionChoiceMessageModel(
        content: content, role: OpenAIChatMessageRole.assistant);
    notifyListeners();
  }

  Stream<OpenAIStreamChatCompletionModel>? _chatStream;
  Stream<OpenAIStreamChatCompletionModel>? get chatStream => _chatStream;
  setChatStream(Stream<OpenAIStreamChatCompletionModel> newChatStream) {
    _chatStream = newChatStream;
    notifyListeners();
  }

  Future createStream() async {
    debugPrint("Creating Stream");
    print("dbg userMessages: $userMessages");
    print("dbg assistantMessages: $assistantMessages");

    try {
      var localChatStream = OpenAI.instance.chat.createStream(
        model: "gpt-4-1106-preview",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                    "Hello, I'm a chatbot. I'm here to help you with your homework. I can help you with math, science, history, and english. What subject do you need help with?"),
              ]),
          userMessages,
          assistantMessages,
        ],
        // seed: 423,
        n: 1,
      );
      setChatStream(localChatStream);
      listenStream();
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

    String id = randomString();
    String streamMessage = '';
    var textMessage = types.TextMessage(
        author: assistant,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: id,
        text: streamMessage);
    addMessage(textMessage);
    String lastMessage = '';

    chatStream?.listen(
      (streamChatCompletion) {
        final content = streamChatCompletion.choices.first.delta.content;

        if (content != null) {
          String text = "${content[0].text}";
          debugPrint("Stream: $text");
          if (text == lastMessage) return;
          updateAMessageById(id, text);
          lastMessage = text;
          streamMessage += text;
        }
      },
      onDone: () {
        String assistantMessageText = streamMessage;
        print("assistantMessageText $assistantMessageText");
        addAssistantMessage(assistantMessageText);
        debugPrint("Stream Done");
      },
    );
  }

  disposeStream() {
    chatStream?.drain();
  }

  handleOnPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    addMessage(textMessage);
    List<MessagesModel> messages = [];
    messages.add(MessagesModel(
        id: randomString(),
        role: OpenAIRole.user,
        content: message.text.toString()));
    messages.add(MessagesModel(
        id: randomString(),
        role: OpenAIRole.assistant,
        content:
            "Hello, I'm a chatbot. I'm here to help you with your homework. I can help you with math, science, history, and english. What subject do you need help with?"));

    Stream<String> stream = OpenaiHelper().streamAPIResponse(messages);
    stream.listen((event) {
      print("event: $event");
    });

    // OpenaiHelper().chatCompletionStream(messages).listen((event) {
    //   print("event: $event");
    //   // addAssistantMessage(event);
    // });
    // addUserMessage(message.text);

    // createStream();
  }

// Listen to the stream.
}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}
