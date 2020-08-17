class Task {
  String text;
  String completedAt;

  Task();

  Task.fromMap(Map<String, dynamic> map) {
    this.text = map['text'];
    this.completedAt = map['completed_at'];
  }

  Task.fromJson(Map<String, dynamic> json) {
    this.text = json['text'];
    this.completedAt = json['completed_at'];
  }

  Map<String, dynamic> toJson() => {
        'text': this.text,
        'completed_at': this.completedAt,
      };
}
