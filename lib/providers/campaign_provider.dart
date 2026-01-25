import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/draft_model.dart';
import '../models/campaign_model.dart';
import '../services/campaign_service.dart';
import '../core/utils/storage_helper.dart'; // ✅ Add this import

class CampaignProvider with ChangeNotifier {
  final CampaignService _campaignService = CampaignService();
  final Logger _logger = Logger();
 
  List<DraftModel> _drafts = [];
  List<CampaignModel> _campaigns = [];
  DraftModel? _selectedDraft;
  
  bool _isLoading = false;
  String? _errorMessage;

  List<DraftModel> get drafts => _drafts;
  List<CampaignModel> get campaigns => _campaigns;
  DraftModel? get selectedDraft => _selectedDraft;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Upload Excel
  Future<bool> uploadExcel(String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final draft = await _campaignService.uploadExcel(filePath);
      _selectedDraft = draft;
      await fetchDrafts(); // Refresh list
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Upload Excel Error: $e');
      _errorMessage = 'Failed to upload Excel file';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create Draft Manually
  Future<bool> createDraft({
    required String campaignName,
    required List<Map<String, String>> recipients,
    required String emailSubject,
    required String emailContent,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final draft = await _campaignService.createDraft(
        campaignName: campaignName,
        recipients: recipients,
        emailSubject: emailSubject,
        emailContent: emailContent,
      );
      
      _selectedDraft = draft;
      await fetchDrafts();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Create Draft Error: $e');
      _errorMessage = 'Failed to create draft';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch All Drafts
  Future<void> fetchDrafts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _drafts = await _campaignService.getDrafts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Fetch Drafts Error: $e');
      _errorMessage = 'Failed to load drafts';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Single Draft
  Future<void> fetchDraftById(String draftId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedDraft = await _campaignService.getDraftById(draftId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Fetch Draft Error: $e');
      _errorMessage = 'Failed to load draft';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Draft
  Future<bool> updateDraft({
    required String draftId,
    String? campaignName,
    String? emailSubject,
    String? emailContent,
    List<Map<String, String>>? recipients,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedDraft = await _campaignService.updateDraft(
        draftId: draftId,
        campaignName: campaignName,
        emailSubject: emailSubject,
        emailContent: emailContent,
        recipients: recipients,
      );
      
      await fetchDrafts();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Update Draft Error: $e');
      _errorMessage = 'Failed to update draft';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete Draft
  Future<bool> deleteDraft(String draftId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _campaignService.deleteDraft(draftId);
      await fetchDrafts();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Delete Draft Error: $e');
      _errorMessage = 'Failed to delete draft';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Send Campaign
  Future<bool> sendCampaign(String draftId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _campaignService.sendCampaign(draftId);
      await fetchDrafts();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Send Campaign Error: $e');
      _errorMessage = 'Failed to send campaign';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ FIXED: Fetch Success Campaigns - Get MongoDB userId from storage
  Future<void> fetchCampaigns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Get MongoDB userId from storage (not Firebase UID)
      final userId = await StorageHelper.getUserId();
      
      if (userId == null) {
        _logger.w('No userId found in storage');
        _errorMessage = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _logger.d('Fetching campaigns for userId: $userId');
      
      _campaigns = await _campaignService.getSuccessCampaigns(userId);
      
      _logger.d('Fetched ${_campaigns.length} campaigns');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Fetch Campaigns Error: $e');
      _errorMessage = 'Failed to load campaigns';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear selected draft
  void clearSelectedDraft() {
    _selectedDraft = null;
    notifyListeners();
  }
}
