import 'package:ctrlfirl/models/messages_model.dart';

class ChatDocumentModel {
  String? id;
  String? title; // Added title property
  List<MessagesModel>? messages;
  DateTime? createdAt;

  ChatDocumentModel({
    this.id,
    this.title,
    this.messages,
    this.createdAt,
  });

  factory ChatDocumentModel.fromJson(Map<String, dynamic> json) {
    return ChatDocumentModel(
      id: json['id'],
      title: json['title'], // Added title property
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => MessagesModel.fromJson(e))
          .toList(),
      // createdAt is a timestamp in firestore
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title, // Added title property
      'messages': messages?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  ChatDocumentModel copyWith({
    String? id,
    String? title, // Added title property
    List<MessagesModel>? messages,
    DateTime? createdAt,
  }) {
    return ChatDocumentModel(
      id: id ?? this.id,
      title: title ?? this.title, // Added title property
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ChatDocumentModel(id: $id, title: $title, messages: $messages, createdAt: $createdAt)';
  }
}
