/// A live campaign as returned by GET /api/v1/campaigns/public (CampaignPublicOut).
/// All money fields are integer TIYIN (1 UZS = 100 tiyin).
class Campaign {
  final String id;
  final String referenceNumber;
  final String titleUz;
  final String? titleRu;
  final String? titleEn;
  final String description;
  final String category;
  final String? coverImageUrl;
  final String? anonymousTitle;
  final String regionId;
  final int targetAmountTiyin;
  final int raisedAmountTiyin;
  final int donorCount;
  final bool isUrgent;

  const Campaign({
    required this.id,
    required this.referenceNumber,
    required this.titleUz,
    required this.titleRu,
    required this.titleEn,
    required this.description,
    required this.category,
    required this.coverImageUrl,
    required this.anonymousTitle,
    required this.regionId,
    required this.targetAmountTiyin,
    required this.raisedAmountTiyin,
    required this.donorCount,
    required this.isUrgent,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      referenceNumber: json['reference_number'] as String,
      titleUz: json['title_uz'] as String,
      titleRu: json['title_ru'] as String?,
      titleEn: json['title_en'] as String?,
      description: json['description'] as String,
      category: json['category'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      anonymousTitle: json['anonymous_title'] as String?,
      regionId: json['region_id'] as String,
      // Defensive: these are ints, but JSON numbers can arrive as num.
      targetAmountTiyin: (json['target_amount_tiyin'] as num).toInt(),
      raisedAmountTiyin: (json['raised_amount_tiyin'] as num).toInt(),
      donorCount: (json['donor_count'] as num).toInt(),
      isUrgent: json['is_urgent'] as bool,
    );
  }

  /// The title to show publicly — prefer the anonymous title to protect
  /// the beneficiary's identity, fall back to the Uzbek title.
  String get displayTitle =>
      (anonymousTitle != null && anonymousTitle!.isNotEmpty)
          ? anonymousTitle!
          : titleUz;

  /// Progress 0.0–1.0 for the progress bar (clamped so it never overflows).
  double get progress {
    if (targetAmountTiyin <= 0) return 0;
    return (raisedAmountTiyin / targetAmountTiyin).clamp(0.0, 1.0);
  }

  int get progressPercent => (progress * 100).round();
}