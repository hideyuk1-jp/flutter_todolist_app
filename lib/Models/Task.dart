import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String uuid;
  String text;
  String dueDate;
  int estimatedMinutes;
  DateTime completedAt;
  DateTime createdAt;
  DateTime updatedAt;

  Task.fromMap(Map<String, dynamic> map)
      : this.uuid = map['uuid'],
        this.text = map['text'],
        this.dueDate = map['due_date'],
        this.estimatedMinutes = map['estimated_minutes'],
        this.completedAt = map['completed_at'],
        this.createdAt = map['created_at'],
        this.updatedAt = map['updated_at'];

  Task.fromJson(Map<String, dynamic> json)
      : this.uuid = json['uuid'],
        this.text = json['text'],
        this.dueDate = json['due_date'],
        this.estimatedMinutes = json['estimated_minutes'],
        this.completedAt = json['completed_at'] != null
            ? DateTime.parse(json['completed_at'])
            : null,
        this.createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        this.updatedAt = json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null;

  Task.fromSnapshot(DocumentSnapshot snapshot)
      : this.uuid = snapshot.documentID,
        this.text = snapshot['text'],
        this.dueDate = snapshot['dueDate'],
        this.estimatedMinutes = snapshot['estimatedMinutes'],
        this.completedAt = snapshot['completedAt'] != null
            ? snapshot['completedAt'].toDate()
            : null,
        this.createdAt = snapshot['createdAt'] != null
            ? snapshot['createdAt'].toDate()
            : null,
        this.updatedAt = snapshot['updatedAt'] != null
            ? snapshot['updatedAt'].toDate()
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
