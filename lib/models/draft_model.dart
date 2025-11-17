import 'recipient_model.dart';

class DraftModel {
  final String id;
  final String userId;
  final String campaignName;
  final String? excelFileName;
  final String? excelFilePath;
  final List<RecipientModel> recipients;
  final int totalRecipients;
  final String emailSubject;
  final String emailContent;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DraftModel({
    required this.id,
    required this.userId,
    required this.campaignName,
    this.excelFileName,
    this.excelFilePath,
    required this.recipients,
    required this.totalRecipients,
    required this.emailSubject,
    required this.emailContent,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DraftModel.fromJson(Map<String, dynamic> json) {
    return DraftModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      campaignName: json['campaignName'] ?? 'Untitled Campaign',
      excelFileName: json['excelFileName'],
      excelFilePath: json['excelFilePath'],
      recipients: (json['recipients'] as List?)
          ?.map((r) => RecipientModel.fromJson(r))
          .toList() ?? [],
      totalRecipients: json['totalRecipients'] ?? 0,
      emailSubject: json['emailSubject'] ?? '',
      emailContent: json['emailContent'] ?? '',
      status: json['status'] ?? 'draft',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'campaignName': campaignName,
      'excelFileName': excelFileName,
      'excelFilePath': excelFilePath,
      'recipients': recipients.map((r) => r.toJson()).toList(),
      'totalRecipients': totalRecipients,
      'emailSubject': emailSubject,
      'emailContent': emailContent,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
