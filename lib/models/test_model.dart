class TestModel {
  String? id;

  TestModel({this.id});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  TestModel copyWith({
    String? id,
  }) {
    return TestModel(
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
