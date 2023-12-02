import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ctrlfirl/models/test_model.dart';
import 'package:flutter/material.dart';

class FirebaseHelper {
  final CollectionReference _testCollection =
      FirebaseFirestore.instance.collection('test');

  // Create document
  Future<bool> createDocument(TestModel data) async {
    try {
      DocumentReference documentReference = _testCollection.doc();
      data.id = documentReference.id;
      await documentReference.set(data.toJson());
      debugPrint('Document created');
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<List<TestModel>> getAllTests() async {
    try {
      List<TestModel> tests = [];
      await _testCollection.get().then((value) {
        value.docs.forEach((element) {
          tests.add(TestModel.fromJson(element.data() as Map<String, dynamic>));
        });
      });
      return tests;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  // Future<bool> getAllDocumentsForACollection(String collectionName) async {

  // }
}
