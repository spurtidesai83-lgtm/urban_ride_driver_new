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
            onPressed: () {
              ref.refresh(documentVerificationProvider);
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
            SizedBox(height: 16),
            Text(
              'Failed to load documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC200),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ref.refresh(documentVerificationProvider);
              },
              child: Text(
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
    return SingleChildScrollView(
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          _buildSummaryCard(context, documents),
          
          SizedBox(height: ResponsiveUtils.padding(context, 20)),
          
          // Documents Section Header
          Text(
            'Required Documents',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          
          // RC Document
          if (documents.rc != null) ...[
            _buildDocumentCard(context, documents.rc!),
            SizedBox(height: ResponsiveUtils.padding(context, 16)),
          ],
          
          // POC Document
          if (documents.poc != null) ...[
            _buildDocumentCard(context, documents.poc!),
            SizedBox(height: ResponsiveUtils.padding(context, 16)),
          ],
          
          // Permit Document
          if (documents.permit != null) ...[
            _buildDocumentCard(context, documents.permit!),
            SizedBox(height: ResponsiveUtils.padding(context, 16)),
          ],
          
          // No documents message
          if (documents.allDocuments.isEmpty)
            _buildNoDocumentsMessage(context),
          
          SizedBox(height: ResponsiveUtils.padding(context, 20)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, VehicleDocumentsModel documents) {
    final totalDocs = documents.allDocuments.length;
    final verifiedDocs = documents.allDocuments.where((d) => d.isVerified && !d.isExpired).length;
    final expiredDocs = documents.allDocuments.where((d) => d.isExpired).length;
    final pendingDocs = documents.allDocuments.where((d) => !d.isVerified).length;

    Color summaryColor;
    IconData summaryIcon;
    String summaryText;

    if (expiredDocs > 0) {
      summaryColor = Colors.red;
      summaryIcon = Icons.warning;
      summaryText = '$expiredDocs document(s) expired';
    } else if (pendingDocs > 0) {
      summaryColor = Colors.orange;
      summaryIcon = Icons.pending;
      summaryText = '$pendingDocs document(s) pending verification';
    } else if (verifiedDocs == totalDocs && totalDocs > 0) {
      summaryColor = Colors.green;
      summaryIcon = Icons.check_circle;
      summaryText = 'All documents verified';
    } else {
      summaryColor = Colors.grey;
      summaryIcon = Icons.info_outline;
      summaryText = 'No documents available';
    }

    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: summaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
        border: Border.all(color: summaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(summaryIcon, color: summaryColor, size: ResponsiveUtils.iconSize(context, 28)),
          SizedBox(width: ResponsiveUtils.padding(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summaryText,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: summaryColor,
                  ),
                ),
                if (totalDocs > 0) ...[
                  SizedBox(height: ResponsiveUtils.padding(context, 4)),
                  Text(
                    '$verifiedDocs of $totalDocs verified',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 13),
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDocumentsMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No Documents Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Documents will appear here once uploaded',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentVerificationModel document) {
    final statusColor = _getStatusColor(document.statusType);
    final statusIcon = _getStatusIcon(document.statusType);

    return Container(
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
                ),
                child: Icon(
                  _getDocumentIcon(document.documentType),
                  color: statusColor,
                  size: ResponsiveUtils.iconSize(context, 24),
                ),
              ),
              SizedBox(width: ResponsiveUtils.padding(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.displayName,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (document.documentNumber != null && document.documentNumber!.isNotEmpty) ...[
                      SizedBox(height: ResponsiveUtils.padding(context, 4)),
                      Text(
                        document.documentNumber!,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.padding(context, 12),
                  vertical: ResponsiveUtils.padding(context, 6),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 20)),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: ResponsiveUtils.iconSize(context, 14),
                      color: statusColor,
                    ),
                    SizedBox(width: ResponsiveUtils.padding(context, 4)),
                    Text(
                      document.status,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12),
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Expiry Date (if available)
          if (document.expiryDate != null && document.expiryDate!.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.padding(context, 12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.padding(context, 12),
                vertical: ResponsiveUtils.padding(context, 8),
              ),
              decoration: BoxDecoration(
                color: document.isExpired
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: ResponsiveUtils.iconSize(context, 16),
                    color: document.isExpired ? Colors.red : Colors.grey[700],
                  ),
                  SizedBox(width: ResponsiveUtils.padding(context, 8)),
                  Text(
                    'Expiry: ${_formatDate(document.expiryDate!)}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 13),
                      color: document.isExpired ? Colors.red : Colors.grey[700],
                      fontWeight: document.isExpired ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (document.isExpired) ...[
                    Spacer(),
                    Icon(
                      Icons.warning_rounded,
                      size: ResponsiveUtils.iconSize(context, 18),
                      color: Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          // Uploaded Date (if available)
          if (document.uploadedAt != null && document.uploadedAt!.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.padding(context, 8)),
            Row(
              children: [
                Icon(
                  Icons.upload_file,
                  size: ResponsiveUtils.iconSize(context, 14),
                  color: Colors.grey[500],
                ),
                SizedBox(width: ResponsiveUtils.padding(context, 6)),
                Text(
                  'Uploaded: ${_formatDate(document.uploadedAt!)}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 12),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType.toUpperCase()) {
      case 'RC':
        return Icons.description;
      case 'POC':
        return Icons.eco;
      case 'PERMIT':
        return Icons.card_membership;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return Colors.green;
      case DocumentStatus.expired:
        return Colors.red;
      case DocumentStatus.pending:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return Icons.check_circle;
      case DocumentStatus.expired:
        return Icons.cancel;
      case DocumentStatus.pending:
        return Icons.pending;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}

