import 'package:dio/dio.dart';
import 'package:email_automation_app/models/recipient_model.dart';
import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../models/draft_model.dart';
import '../models/campaign_model.dart';
import 'api_service.dart';

class CampaignService {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  // Upload Excel - FIXED to match backend
  Future<DraftModel> uploadExcel(String filePath) async {
    try {
      _logger.d('Uploading Excel: $filePath');

      // Get filename
      final fileName = filePath.split('/').last;

      // Create multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(  // ✅ CHANGED to 'file'
          filePath,
          filename: fileName,
        ),
        'campaignName': 'Campaign - ${DateTime.now().toString().split(' ')[0]}',
      });

      _logger.d('Sending upload request...');

      // Make request
      final response = await _apiService.dio.post(
        ApiConstants.uploadExcel,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      _logger.d('Upload response: ${response.statusCode}');
      _logger.d('Response data: ${response.data}');

      if (response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final draftData = responseData['data'] as Map<String, dynamic>?;

        if (draftData == null) {
          throw Exception('No data in response');
        }
        
        // Parse recipients safely
        final recipientsList = (draftData['recipients'] as List?)
            ?.map((r) {
              if (r is Map<String, dynamic>) {
                return RecipientModel(
                  name: r['name']?.toString() ?? '',
                  email: r['email']?.toString() ?? '',
                  status: r['status']?.toString() ?? 'pending',
                );
              }
              return null;
            })
            .whereType<RecipientModel>()
            .toList() ?? [];

        // Parse the draft
        final draft = DraftModel(
          id: draftData['draftId']?.toString() ?? '',
          userId: '',
          campaignName: draftData['fileName']?.toString() ?? 'Campaign',
          excelFileName: draftData['fileName']?.toString(),
          excelFilePath: filePath,
          emailSubject: '',
          emailContent: '',
          recipients: recipientsList,
          totalRecipients: draftData['totalRecipients'] as int? ?? recipientsList.length,
          status: 'draft',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _logger.d('Draft created successfully: ${draft.id} with ${draft.totalRecipients} recipients');

        return draft;
      }

      throw Exception('Upload failed with status: ${response.statusCode}');
    } catch (e, stackTrace) {
      _logger.e('Upload Excel Error: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Create Draft Manually
  Future<DraftModel> createDraft({
    required String campaignName,
    required List<Map<String, String>> recipients,
    required String emailSubject,
    required String emailContent,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.createDraft,
        data: {
          'campaignName': campaignName,
          'recipients': recipients,
          'emailSubject': emailSubject,
          'emailContent': emailContent,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('No data in response');
      }

      return DraftModel.fromJson(data);
    } catch (e) {
      _logger.e('Create Draft Error: $e');
      rethrow;
    }
  }

  // Get All Drafts
  Future<List<DraftModel>> getDrafts() async {
    try {
      final response = await _apiService.get(ApiConstants.getDrafts);

      final List<dynamic> draftsData = response.data['data'] ?? [];
      return draftsData
          .map((json) {
            if (json is Map<String, dynamic>) {
              return DraftModel.fromJson(json);
            }
            return null;
          })
          .whereType<DraftModel>()
          .toList();
    } catch (e) {
      _logger.e('Get Drafts Error: $e');
      rethrow;
    }
  }

  // Get Single Draft
  Future<DraftModel> getDraftById(String draftId) async {
    try {
      final response = await _apiService.get('${ApiConstants.getDraftById}/$draftId');
      
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('No draft data in response');
      }

      return DraftModel.fromJson(data);
    } catch (e) {
      _logger.e('Get Draft Error: $e');
      rethrow;
    }
  }

  // Update Draft
  Future<DraftModel> updateDraft({
    required String draftId,
    String? campaignName,
    String? emailSubject,
    String? emailContent,
    List<Map<String, String>>? recipients,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (campaignName != null) data['campaignName'] = campaignName;
      if (emailSubject != null) data['emailSubject'] = emailSubject;
      if (emailContent != null) data['emailContent'] = emailContent;
      if (recipients != null) data['recipients'] = recipients;

      final response = await _apiService.put(
        '${ApiConstants.updateDraft}/$draftId',
        data: data,
      );

      final responseData = response.data['data'] as Map<String, dynamic>?;
      if (responseData == null) {
        throw Exception('No data in response');
      }

      return DraftModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Update Draft Error: $e');
      rethrow;
    }
  }

  // Delete Draft
  Future<void> deleteDraft(String draftId) async {
    try {
      await _apiService.delete('${ApiConstants.deleteDraft}/$draftId');
      _logger.d('Draft deleted successfully');
    } catch (e) {
      _logger.e('Delete Draft Error: $e');
      rethrow;
    }
  }

  // Send Campaign
  Future<void> sendCampaign(String draftId) async {
    try {
      _logger.d('Sending campaign: $draftId');
      await _apiService.post('${ApiConstants.sendCampaign}/$draftId');
      _logger.d('Campaign sent successfully');
    } catch (e) {
      _logger.e('Send Campaign Error: $e');
      rethrow;
    }
  }

  // Get Success Campaigns
  Future<List<CampaignModel>> getSuccessCampaigns(String userId) async {
    try {
      final response = await _apiService.get('${ApiConstants.getSuccessCampaigns}/$userId');

      final List<dynamic> campaignsData = response.data['data'] ?? [];
      return campaignsData
          .map((json) {
            if (json is Map<String, dynamic>) {
              return CampaignModel.fromJson(json);
            }
            return null;
          })
          .whereType<CampaignModel>()
          .toList();
    } catch (e) {
      _logger.e('Get Success Campaigns Error: $e');
      rethrow;
    }
  }
}
