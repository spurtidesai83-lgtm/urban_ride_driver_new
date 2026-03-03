import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../../data/models/document_verification_model.dart';
import '../providers/document_verification_provider.dart';

class VehicleDocumentsScreen extends ConsumerWidget {
  const VehicleDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentVerificationProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vehicle Documents',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () async {
              try {
                ref.invalidate(documentVerificationProvider);
                await ref.read(documentVerificationProvider.future);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vehicle documents refreshed'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: documentsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFFFFC200),
            ),
          ),
        ),
        error: (error, stack) => _buildErrorState(context, ref, error.toString()),
        data: (documents) => _buildDocumentsContent(context, documents),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC200),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ref.invalidate(documentVerificationProvider);
              },
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsContent(BuildContext context, VehicleDocumentsModel documents) {
    final rc = documents.rc;
    final permit = documents.permit;
    final puc = documents.poc;

    final availableCount = [rc, permit, puc]
      .where((doc) => doc != null && ((doc.documentNumber ?? '').trim().isNotEmpty || (doc.expiryDate ?? '').trim().isNotEmpty))
        .length;

    return SingleChildScrollView(
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: Color(0xFFB45309)),
                SizedBox(width: ResponsiveUtils.padding(context, 10)),
                Expanded(
                  child: Text(
                    '$availableCount of 3 document records available',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                      color: const Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 18)),
          _buildDocumentDataCard(
            context,
            title: 'Registration Certificate (RC)',
            number: rc?.documentNumber,
            expiryDate: rc?.expiryDate,
            icon: Icons.badge_outlined,
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 14)),
          _buildDocumentDataCard(
            context,
            title: 'Permit',
            number: permit?.documentNumber,
            expiryDate: permit?.expiryDate,
            icon: Icons.card_membership_outlined,
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 14)),
          _buildDocumentDataCard(
            context,
            title: 'Pollution Certificate (PUC)',
            number: puc?.documentNumber,
            expiryDate: puc?.expiryDate,
            icon: Icons.eco_outlined,
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 20)),
        ],
      ),
    );
  }

  Widget _buildDocumentDataCard(
    BuildContext context, {
    required String title,
    required String? number,
    required String? expiryDate,
    required IconData icon,
  }) {
    final normalizedNumber = (number ?? '').trim();
    final normalizedExpiry = (expiryDate ?? '').trim();

    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFB45309), size: ResponsiveUtils.iconSize(context, 20)),
              SizedBox(width: ResponsiveUtils.padding(context, 8)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 15),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 12)),
          _buildDataRow(
            context,
            label: 'Number',
            value: normalizedNumber.isNotEmpty ? normalizedNumber : 'Not available',
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 8)),
          _buildDataRow(
            context,
            label: 'Expiry Date',
            value: normalizedExpiry.isNotEmpty ? _formatDate(normalizedExpiry) : 'Not available',
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, {required String label, required String value}) {
    return Row(
      children: [
        SizedBox(
          width: ResponsiveUtils.width(context, 90),
          child: Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 13),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14),
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}
