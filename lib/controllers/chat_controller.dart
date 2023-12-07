import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:ctrlfirl/models/messages_model.dart';
import 'package:ctrlfirl/services/openai_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart';

class ChatController extends ChangeNotifier {
  bool _isGeneratingResponse = false;
  bool get isGeneratingResponse => _isGeneratingResponse;
  setIsGeneratingResponse(bool newValue) {
    _isGeneratingResponse = newValue;
    notifyListeners();
  }

  String _appbarSubtitle = "";
  String get appbarSubtitle => _appbarSubtitle;
  setAppbarSubtitle(String newTitle) {
    _appbarSubtitle = newTitle;
    notifyListeners();
  }

  final user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final assistant = const types.User(id: 'assistant');
  final system = const types.User(id: 'system');

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

  addSystemMessage(String systemMessage, {String text = ''}) {
    types.TextMessage sysMessage = types.TextMessage(
        author: system,
        id: randomString(),
        text: systemMessage + text,
        createdAt: DateTime.now().millisecondsSinceEpoch);
    _chatMessages.insert(0, sysMessage);
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

  List<MessagesModel> generateMessageForOpenAI() {
    return _chatMessages.map((e) {
      types.TextMessage textMessage = e as types.TextMessage;
      return MessagesModel(
          id: e.id,
          role: e.author.id == user.id ? OpenAIRole.user : OpenAIRole.assistant,
          content: textMessage.text);
    }).toList();
  }

  handleOnPressed(types.PartialText message, {BuildContext? context}) async {
    setIsGeneratingResponse(true);
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    addMessage(textMessage);

    final assistantTestMessage = types.TextMessage(
      author: assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: "",
    );
    addMessage(assistantTestMessage);
    List<MessagesModel> messages = generateMessageForOpenAI();
    messages.removeAt(0);
    Stream<String> stream = OpenaiHelper().streamAPIResponse(messages);
    stream.listen((event) {
      if (event.contains('data:')) {
        final response = event.split('data:')[1];
        if (response.contains('content')) {
          Map<String, dynamic> json = jsonDecode(response);
          final assistantText = json['choices'][0]['delta']['content'];
          updateAMessageById(assistantTestMessage.id, assistantText);
        }
      }
    }, onDone: () {
      setIsGeneratingResponse(false);
    }, onError: (error) {
      debugPrint("handleOnPressed error: $error");
      if (error is ClientException ||
          error is SocketException && context != null) {
        ScaffoldMessenger.of(context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Your connection is very slow...")));
        // remove the last message
        _chatMessages.removeAt(0);
      }
      setIsGeneratingResponse(false);
      throw error;
    });
  }
}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}
