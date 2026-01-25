import 'package:email_automation_app/models/campaign_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import 'campaign_detail_screen.dart';

class SuccessCampaignsScreen extends StatefulWidget {
  const SuccessCampaignsScreen({Key? key}) : super(key: key);

  @override
  State<SuccessCampaignsScreen> createState() => _SuccessCampaignsScreenState();
}

class _SuccessCampaignsScreenState extends State<SuccessCampaignsScreen> {
  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    final authProvider = context.read<AuthProvider>();
    final campaignProvider = context.read<CampaignProvider>();

    if (authProvider.currentUser != null) {
      await campaignProvider.fetchCampaigns();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CampaignProvider>(
        builder: (context, campaignProvider, _) {
          if (campaignProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (campaignProvider.campaigns.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No campaigns sent yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your sent campaigns will appear here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadCampaigns,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: campaignProvider.campaigns.length,
              itemBuilder: (context, index) {
                final campaign = campaignProvider.campaigns[index];
                final successRate = campaign.sentCount > 0
                    ? (campaign.sentCount /
                        (campaign.sentCount + campaign.failedCount) *
                        100)
                    : 0.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CampaignDetailScreen(campaign: campaign),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  campaign.campaignName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[600],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (campaign.senderEmail != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Sent by: ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    campaign.senderName ??
                                        campaign.senderEmail!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[800],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _StatChip(
                                icon: Icons.send,
                                label: 'Sent',
                                value: campaign.sentCount.toString(),
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              _StatChip(
                                icon: Icons.error_outline,
                                label: 'Failed',
                                value: campaign.failedCount.toString(),
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              _StatChip(
                                icon: Icons.percent,
                                label: 'Success',
                                value: '${successRate.toStringAsFixed(1)}%',
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, yyyy - hh:mm a')
                                    .format(campaign.completedAt),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
