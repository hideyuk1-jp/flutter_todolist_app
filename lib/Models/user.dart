import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  User.fromMap(Map<String, dynamic> map)
      : this.id = map['id'],
        this.name = map['name'],
        this.createdAt = map['created_at'],
        this.updatedAt = map['updated_at'];

  User.fromJson(Map<String, dynamic> json)
      : this.id = json['id'],
        this.name = json['name'],
        this.createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        this.updatedAt = json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null;

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.id = snapshot.id,
        this.name = snapshot['name'],
        this.createdAt = snapshot['createdAt'] != null
            ? snapshot['createdAt'].toDate()
            : null,
        this.updatedAt = snapshot['updatedAt'] != null
            ? snapshot['updatedAt'].toDate()
            : null;

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'name': this.name,
        'created_at': this.createdAt?.toIso8601String(),
        'updated_at': this.updatedAt?.toIso8601String(),
      };
}
