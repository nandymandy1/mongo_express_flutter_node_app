import 'package:intl/intl.dart';

class PostClass {
  String title;
  String body;
  String id;
  String imageUrl;
  String createdAt;
  String updatedAt;
  PostClass({
    this.body,
    updatedAt,
    createdAt,
    this.id,
    this.imageUrl,
    this.title,
  }) {
    DateTime created = DateTime.parse(createdAt);
    DateTime updated = DateTime.parse(updatedAt);
    this.updatedAt = DateFormat.yMMMMd().format(updated);
    this.createdAt = DateFormat.yMMMMd().format(created);
  }
}
