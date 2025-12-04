import 'recipient_model.dart';

class CampaignModel {
  final String id;
  final String userId;
  final String campaignName;
  final int sentCount;
  final int failedCount;
  final List<RecipientModel> recipients;
  final String emailSubject;
  final String emailContent;

  // ✅ NEW: Sender information
  final String? senderEmail;
  final String? senderName;

  final int openedCount;
  final int clickedCount;
  final DateTime completedAt;
  final DateTime sentStartedAt;
  final DateTime sentFinishedAt;

  CampaignModel( {
    required this.id,
    required this.userId,
    required this.campaignName,
    required this.sentCount,
    required this.failedCount,
    required this.recipients,
    required this.emailSubject,
    required this.emailContent,
    this.senderEmail, 
    this.senderName,
    this.openedCount = 0,
    this.clickedCount = 0,
    required this.completedAt,
    required this.sentStartedAt,
    required this.sentFinishedAt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      campaignName: json['campaignName'] ?? '',
      sentCount: json['sentCount'] ?? 0,
      failedCount: json['failedCount'] ?? 0,
      recipients: (json['recipients'] as List?)
          ?.map((r) => RecipientModel.fromJson(r))
          .toList() ?? [],
      emailSubject: json['emailSubject'] ?? '',
      emailContent: json['emailContent'] ?? '',
      senderEmail: json['senderEmail'],        // ✅ Added
      senderName: json['senderName'],   
      openedCount: json['openedCount'] ?? 0,
      clickedCount: json['clickedCount'] ?? 0,
      completedAt: DateTime.parse(json['completedAt'] ?? DateTime.now().toIso8601String()),
      sentStartedAt: DateTime.parse(json['sentStartedAt'] ?? DateTime.now().toIso8601String()),
      sentFinishedAt: DateTime.parse(json['sentFinishedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'campaignName': campaignName,
      'sentCount': sentCount,
      'failedCount': failedCount,
      'recipients': recipients.map((r) => r.toJson()).toList(),
      'emailSubject': emailSubject,
      'emailContent': emailContent,
      'senderEmail': senderEmail,        // ✅ Added
      'senderName': senderName,          // ✅ Added
      'openedCount': openedCount,
      'clickedCount': clickedCount,
      'completedAt': completedAt.toIso8601String(),
      'sentStartedAt': sentStartedAt.toIso8601String(),
      'sentFinishedAt': sentFinishedAt.toIso8601String(),
    };
  }
}
