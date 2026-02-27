import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../shared/config/api_config.dart';
import '../../../../shared/services/storage_service.dart';
import '../models/document_verification_model.dart';

class DocumentVerificationRepository {
  Future<VehicleDocumentsModel> getDocuments() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.vehicleEndpoint));

      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch vehicle documents');
      }

      final jsonData = jsonDecode(response.body);
      final payload = (jsonData is Map && jsonData['data'] is Map)
          ? jsonData['data'] as Map<String, dynamic>
          : (jsonData as Map<String, dynamic>);

      return _mapVehicleDocuments(payload);
    } catch (e) {
      throw Exception('Failed to get vehicle documents: $e');
    }
  }

  VehicleDocumentsModel _mapVehicleDocuments(Map<String, dynamic> payload) {
    DocumentVerificationModel? buildDoc({
      required String type,
      required String? number,
      required String? expiry,
    }) {
      final cleanedNumber = (number ?? '').trim();
      final cleanedExpiry = (expiry ?? '').trim();
      if (cleanedNumber.isEmpty && cleanedExpiry.isEmpty) {
        return null;
      }

      return DocumentVerificationModel(
        documentType: type,
        isVerified: cleanedNumber.isNotEmpty,
        expiryDate: cleanedExpiry.isNotEmpty ? cleanedExpiry : null,
        documentNumber: cleanedNumber.isNotEmpty ? cleanedNumber : null,
      );
    }

    final rc = buildDoc(
      type: 'RC',
      number: payload['rcNumber']?.toString(),
      expiry: payload['rcExpiryDate']?.toString(),
    );

    final permit = buildDoc(
      type: 'PERMIT',
      number: payload['permitNumber']?.toString(),
      expiry: payload['permitExpiryDate']?.toString(),
    );

    final poc = buildDoc(
      type: 'PUC',
      number: payload['pucNumber']?.toString(),
      expiry: payload['pucExpiryDate']?.toString(),
    );

    return VehicleDocumentsModel(
      rc: rc,
      permit: permit,
      poc: poc,
    );
  }
}
