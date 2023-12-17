import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrlfirl/models/chat_document_model.dart';
import 'package:ctrlfirl/models/messages_model.dart';
import 'package:ctrlfirl/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseHelper {
  final CollectionReference chatsCollection =
      FirebaseFirestore.instance.collection('chats');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<bool> doesUserDocumentExist() async {
    final DocumentSnapshot documentSnapshot =
        await userCollection.doc(FirebaseAuth.instance.currentUser!.uid).get();
    return documentSnapshot.exists;
  }

  Future<bool> createUserDocument(UserModel user) async {
    debugPrint('Adding user to firestore');
    try {
      userCollection.doc(user.uid).set(user.toJson());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<String> uploadProfilePicture(XFile imageFile, String uid) async {
    debugPrint('uploadProfilePicture: $imageFile');
    final String fileName = uid;
    final Reference reference =
        FirebaseStorage.instance.ref().child('images/$fileName');
    final UploadTask uploadTask = reference.putFile(File(imageFile.path));
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    debugPrint('downloadUrl: $downloadUrl');
    return downloadUrl;
  }

  Future<bool> checkIfDocumentExists(String id) async {
    try {
      DocumentSnapshot documentSnapshot = await chatsCollection.doc(id).get();
      return documentSnapshot.exists;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<ChatDocumentModel> createDocument(
      List<MessagesModel> chats, String title,
      {String model = "gpt-3.5-turbo"}) async {
    try {
      DocumentReference documentReference = chatsCollection.doc();

      await documentReference.set({
        'id': documentReference.id,
        'title': title,
        'messages': chats.map((e) => e.toJson()).toList(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'model': model,
        'uid': FirebaseAuth.instance.currentUser?.uid,
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

  // getUserDataStream - returns a stream of user data
  StreamSubscription getUserDocumentStream() {
    debugPrint('user_helper:getUserDocumentStream called');
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .listen((event) {
        debugPrint('getUserDocumentStream: $event');
        if (event.exists) {
        } else {
          debugPrint('getUserDocumentStream: User document does not exist');
          debugPrint('getUserDocumentStream: Signing out user');

          FirebaseAuth.instance.signOut();
          throw Exception('User document does not exist');
        }
      });
    } catch (e) {
      debugPrint('Error getting user data stream: $e');
      return const Stream.empty().listen((event) {
        debugPrint('getUserDocumentStreamCatch: $event');
      });
    }
  }

  Future<void> updateUserRecord(UserModel user) async {
    debugPrint("updateUserRecord");
    try {
      await userCollection.doc(user.uid).update(user.toJson());
      // getUserData(user.uid!);
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  void closeUserDocumentStream() {
    debugPrint('user_helper:closeUserDocumentStream called');
    getUserDocumentStream().cancel();
  }

  Future<bool> updateDocument(List<MessagesModel> chats, String id) async {
    try {
      await chatsCollection.doc(id).update({
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
      QuerySnapshot querySnapshot = await chatsCollection
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('createdAt', descending: true)
          .get();
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

  // logout
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }
}
