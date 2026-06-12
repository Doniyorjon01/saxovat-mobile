/// One row from GET /api/v1/donor/me/notifications (NotificationOut).
class NotificationItem {
  final String id;
  final String type; // donation_delivered | payout_received
  final String title;
  final String body;
  final String? campaignId;
  final int? amountTiyin;
  final bool isRead;
  final String createdAt;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.campaignId,
    required this.amountTiyin,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      campaignId: json['campaign_id'] as String?,
      amountTiyin:
          json['amount_tiyin'] == null ? null : (json['amount_tiyin'] as num).toInt(),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );
  }
}
