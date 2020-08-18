class Task {
  String uuid;
  String text;
  String dueDate;
  int estimatedMinutes;
  DateTime completedAt;
  DateTime createdAt;
  DateTime updatedAt;

  Task.fromMap(Map<String, dynamic> map)
      : this.uuid = map['uuid'] ?? null,
        this.text = map['text'],
        this.dueDate = map['due_date'] ?? null,
        this.estimatedMinutes = map['estimated_minutes'] ?? null,
        this.completedAt = map['completed_at'] != null
            ? DateTime.parse(map['completed_at'])
            : null,
        this.createdAt = map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : null,
        this.updatedAt = map['updated_at'] != null
            ? DateTime.parse(map['updated_at'])
            : null;

  Task.fromJson(Map<String, dynamic> json)
      : this.uuid = json['uuid'] ?? null,
        this.text = json['text'],
        this.dueDate = json['due_date'] ?? null,
        this.estimatedMinutes = json['estimated_minutes'] ?? null,
        this.completedAt = json['completed_at'] != null
            ? DateTime.parse(json['completed_at'])
            : null,
        this.createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        this.updatedAt = json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null;

  Map<String, dynamic> toJson() => {
        'uuid': this.uuid,
        'text': this.text,
        'due_date': this.dueDate,
        'estimated_minutes': this.estimatedMinutes,
        'completed_at': this.completedAt?.toIso8601String(),
        'created_at': this.createdAt?.toIso8601String(),
        'updated_at': this.updatedAt?.toIso8601String(),
      };
}
