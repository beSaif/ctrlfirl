enum OpenAIRole { system, assistant, user }

extension ParseToString on OpenAIRole {
  String toShortString() {
    return toString().split('.').last;
  }
}

class MessagesModel {
  String? id;
  OpenAIRole? role;
  String? content;

  MessagesModel({
    this.id,
    this.role,
    this.content,
  });

  factory MessagesModel.fromJson(Map<String, dynamic> json) {
    return MessagesModel(
      id: json['id'],
      role: OpenAIRole.values.firstWhere(
        (e) => e.toString() == 'OpenAIRole.${json['role']}',
      ),
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.toString().split('.').last,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'MessagesModel(id: $id, role: $role, content: $content)';
  }

  MessagesModel copyWith({
    String? id,
    OpenAIRole? role,
    String? content,
  }) {
    return MessagesModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }
}
