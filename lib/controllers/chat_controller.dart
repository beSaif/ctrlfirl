import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:ctrlfirl/models/chat_document_model.dart';
import 'package:ctrlfirl/models/messages_model.dart';
import 'package:ctrlfirl/services/firebase_helper.dart';
import 'package:ctrlfirl/services/openai_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart';

class ChatController extends ChangeNotifier {
  String _selectedModel = 'gpt-3.5-turbo';
  String get selectedModel => _selectedModel;
  setSelectedModel(String newValue) {
    _selectedModel = newValue;
    debugPrint('selectedModel: $_selectedModel');
    notifyListeners();
  }

  List<String> llmModels = [
    'gpt-3.5-turbo',
    "gpt-4-1106-preview",
  ];
  final FirebaseHelper firebasedHelper = FirebaseHelper();

  bool _chatDocCreatedinFirebase = false;
  bool get chatDocCreatedinFirebase => _chatDocCreatedinFirebase;
  setChatDocCreatedinFirebase(bool newValue) {
    _chatDocCreatedinFirebase = newValue;
    notifyListeners();
  }

  ChatDocumentModel? _chatDocumentModel;
  ChatDocumentModel? get chatDocumentModel => _chatDocumentModel;
  setChatDocumentModel(ChatDocumentModel? newValue) {
    _chatDocumentModel = newValue;
    notifyListeners();
  }

  bool _isPostRequestFailed = false;
  bool get isPostRequestFailed => _isPostRequestFailed;
  setIsPostRequestFailed(bool newIsPostRequest) {
    _isPostRequestFailed = newIsPostRequest;
    notifyListeners();
  }

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

  final user = const types.User(id: 'user');
  final assistant = const types.User(id: 'assistant');
  final system = const types.User(id: 'system');

  types.Message? _systemMessage;
  types.Message? get systemMessage => _systemMessage;

  setSystemMessage(String systemMessage, {String text = ''}) {
    types.TextMessage sysMessage = types.TextMessage(
        author: system,
        id: randomString(),
        text: systemMessage + text,
        createdAt: DateTime.now().millisecondsSinceEpoch);
    _systemMessage = sysMessage;
    notifyListeners();
  }

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

  List<MessagesModel> generateMessageForOpenAI() {
    List<MessagesModel> messageToSendToOpenAI = _chatMessages.map((e) {
      types.TextMessage textMessage = e as types.TextMessage;

      OpenAIRole role = OpenAIRole.values.byName(textMessage.author.id);
      return MessagesModel(id: e.id, role: role, content: textMessage.text);
    }).toList();
    if (systemMessage != null) {
      types.TextMessage systemMessageTextModel =
          systemMessage as types.TextMessage;
      messageToSendToOpenAI.add(MessagesModel(
          id: systemMessageTextModel.id,
          role: OpenAIRole.system,
          content: systemMessageTextModel.text));
    }
    return messageToSendToOpenAI;
  }

  handleOnPressed(types.PartialText message,
      {BuildContext? context, bool regenerateResponse = false}) async {
    setIsPostRequestFailed(false);
    setIsGeneratingResponse(true);
    if (!regenerateResponse) {
      final textMessage = types.TextMessage(
        author: user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: message.text,
      );
      addMessage(textMessage);
    }

    final assistantTestMessage = types.TextMessage(
      author: assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: "",
    );
    addMessage(assistantTestMessage);
    List<MessagesModel> messages = generateMessageForOpenAI();
    messages.removeAt(0);
    Stream<String> stream =
        OpenaiHelper().streamAPIResponse(messages, model: selectedModel);
    stream.listen((event) {
      if (event.contains('data:')) {
        final response = event.split('data:')[1];
        if (response.contains('content')) {
          Map<String, dynamic> json = jsonDecode(response);
          final assistantText = json['choices'][0]['delta']['content'];
          updateAMessageById(assistantTestMessage.id, assistantText);
        }
      }
    }, onDone: () async {
      if (chatDocCreatedinFirebase) {
        firebasedHelper.updateDocument(
            generateMessageForOpenAI(), chatDocumentModel!.id!);
      } else {
        List<MessagesModel> messages = generateMessageForOpenAI();
        String title = await OpenaiHelper().generateTitle(messages);
        setAppbarSubtitle(title);
        setChatDocumentModel(await firebasedHelper
            .createDocument(messages, title, model: selectedModel));
        setChatDocCreatedinFirebase(true);
      }
      setIsGeneratingResponse(false);
    }, onError: (error) {
      setIsGeneratingResponse(false);
      debugPrint("handleOnPressed error: $error");
      if (error is ClientException ||
          error is SocketException && context != null) {
        setIsPostRequestFailed(true);
        ScaffoldMessenger.of(context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Your connection is very slow..."),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
            },
          ),
        ));
        // remove the last message
        _chatMessages.removeAt(0);
      }
      setIsGeneratingResponse(false);
    });
  }

  addMessagesFromFirebase(List<MessagesModel> message) {
    List<types.Message> newMessages = [];
    for (var i = 0; i < message.length; i++) {
      OpenAIRole role = message[i].role!;
      if (role == OpenAIRole.system) {
        setSystemMessage(message[i].content!);
        continue;
      }

      final messageModel = message[i];
      final textMessage = types.TextMessage(
          id: messageModel.id ?? randomString(),
          author: types.User(id: role.name),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          text: messageModel.content!);
      newMessages.add(textMessage);
    }
    setchatMessages(newMessages);
  }

  reset() {
    setIsGeneratingResponse(false);
    setIsPostRequestFailed(false);
    setAppbarSubtitle("");
    setChatDocCreatedinFirebase(false);
    setChatDocumentModel(null);
    setchatMessages([]);
    setSystemMessage("");
  }
}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}
