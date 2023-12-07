import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrlfirl/models/chat_document_model.dart';
import 'package:ctrlfirl/models/messages_model.dart';
import 'package:ctrlfirl/models/test_model.dart';
import 'package:flutter/material.dart';

class FirebaseHelper {
  final CollectionReference _testCollection =
      FirebaseFirestore.instance.collection('chats');

  Future<bool> checkIfDocumentExists(String id) async {
    try {
      DocumentSnapshot documentSnapshot = await _testCollection.doc(id).get();
      return documentSnapshot.exists;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Future<bool> createDocument(List<MessagesModel> chats) async {
  //   try {
  //     DocumentReference documentReference = _testCollection.doc();
  //     await documentReference.set({
  //       'id': documentReference.id,
  //       'messages': chats.map((e) => e.toJson()).toList(),
  //       'createdAt': DateTime.now().millisecondsSinceEpoch,
  //     });
  //     debugPrint('Document created');
  //     return true;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return false;
  //   }
  // }

  Future<ChatDocumentModel> createDocument(List<MessagesModel> chats) async {
    try {
      DocumentReference documentReference = _testCollection.doc();
      await documentReference.set({
        'id': documentReference.id,
        'messages': chats.map((e) => e.toJson()).toList(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('Document created');
      return ChatDocumentModel(
        id: documentReference.id,
        messages: chats,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint(e.toString());
      return ChatDocumentModel();
    }
  }

  Future<bool> updateDocument(List<MessagesModel> chats, String id) async {
    try {
      await _testCollection.doc(id).update({
        'messages': chats.map((e) => e.toJson()).toList(),
      });
      debugPrint('Document updated');
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<List<ChatDocumentModel>> getAllChats() async {
    try {
      QuerySnapshot querySnapshot = await _testCollection.get();
      List<ChatDocumentModel> chats = querySnapshot.docs
          .map((e) =>
              ChatDocumentModel.fromJson(e.data() as Map<String, dynamic>))
          .toList();
      return chats;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
