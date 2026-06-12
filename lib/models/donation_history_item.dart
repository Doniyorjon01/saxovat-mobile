/// One row from GET /api/v1/donor/me/donations (DonorDonationHistoryItem).
class DonationHistoryItem {
  final String externalId;
  final String campaignId;
  final int amountTiyin;
  final int tipTiyin;
  final String intent;
  final String status;
  final bool isAnonymous;
  final String? completedAt;
  final String createdAt;

  const DonationHistoryItem({
    required this.externalId,
    required this.campaignId,
    required this.amountTiyin,
    required this.tipTiyin,
    required this.intent,
    required this.status,
    required this.isAnonymous,
    required this.completedAt,
    required this.createdAt,
  });

  factory DonationHistoryItem.fromJson(Map<String, dynamic> json) {
    return DonationHistoryItem(
      externalId: json['external_id'] as String,
      campaignId: json['campaign_id'] as String,
      amountTiyin: (json['amount_tiyin'] as num).toInt(),
      tipTiyin: (json['tip_tiyin'] as num? ?? 0).toInt(),
      intent: json['intent'] as String,
      status: json['status'] as String,
      isAnonymous: json['is_anonymous'] as bool? ?? true,
      completedAt: json['completed_at'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}
