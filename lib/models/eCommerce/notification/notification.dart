class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final String url;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.url,
    required this.createdAt,
    required this.isRead,
  });
}
