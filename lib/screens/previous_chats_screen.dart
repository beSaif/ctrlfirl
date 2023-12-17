import 'package:ctrlfirl/controllers/chat_controller.dart';
import 'package:ctrlfirl/models/chat_document_model.dart';
import 'package:ctrlfirl/screens/chat_screen.dart';
import 'package:ctrlfirl/services/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

class PreviousChatsScreen extends StatefulWidget {
  const PreviousChatsScreen({super.key});

  @override
  State<PreviousChatsScreen> createState() => _PreviousChatsScreenState();
}

class _PreviousChatsScreenState extends State<PreviousChatsScreen> {
  List<ChatDocumentModel> chatDocumentModelList = [];
  bool _isLoading = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      chatDocumentModelList = await FirebaseHelper().getAllChats();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Previous Chats"),
      ),
      body: Skeletonizer(
        enabled: _isLoading,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: chatDocumentModelList.map((e) {
                String date = DateFormat('MMM dd, yyyy').format(e.createdAt!);

                String today =
                    DateFormat('MMM dd, yyyy').format(DateTime.now());
                if (date == today) {
                  date = 'Today';
                }
                return ListTile(
                  onTap: () {
                    Provider.of<ChatController>(context, listen: false).reset();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                  chatDocumentModel: e,
                                )));
                  },
                  title: Text(
                    "${e.title}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text("$date "),
                );
              }).toList(),
            )),
      ),
    ));
  }
}
