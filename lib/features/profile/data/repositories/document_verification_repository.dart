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
      final payload = _extractPayload(jsonData);

      return _mapVehicleDocuments(payload);
    } catch (e) {
      throw Exception('Failed to get vehicle documents: $e');
    }
  }

  Map<String, dynamic> _extractPayload(dynamic raw) {
    bool hasDocumentKeys(Map<String, dynamic> map) {
      const keys = {
        'rcnumber',
        'rcexpirydate',
        'permitnumber',
        'permitexpirydate',
        'pucnumber',
        'pucexpirydate',
        'pocnumber',
        'pocexpirydate',
      };
      final normalizedKeys = map.keys.map((k) => k.toLowerCase().replaceAll('_', '')).toSet();
      return normalizedKeys.any(keys.contains);
    }

    if (raw is Map<String, dynamic>) {
      if (hasDocumentKeys(raw)) {
        return raw;
      }

      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        if (hasDocumentKeys(data)) {
          return data;
        }

        final nested = data['documents'] ?? data['vehicleDocuments'] ?? data['vehicle_documents'];
        if (nested is Map<String, dynamic>) {
          return nested;
        }

        return data;
      }
      if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
        final first = data.first as Map<String, dynamic>;
        if (hasDocumentKeys(first)) {
          return first;
        }
        final nested = first['documents'] ?? first['vehicleDocuments'] ?? first['vehicle_documents'];
        if (nested is Map<String, dynamic>) {
          return nested;
        }
        return first;
      }

      final nested = raw['documents'] ?? raw['vehicleDocuments'] ?? raw['vehicle_documents'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }

      return raw;
    }

    if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      return raw.first as Map<String, dynamic>;
    }

    return <String, dynamic>{};
  }

  String? _readString(Map<String, dynamic> payload, List<String> keys) {
    final normalizedMap = <String, dynamic>{};
    payload.forEach((key, value) {
      normalizedMap[key.toLowerCase().replaceAll('_', '')] = value;
    });

    for (final key in keys) {
      final normalizedKey = key.toLowerCase().replaceAll('_', '');
      final value = payload[key] ?? normalizedMap[normalizedKey];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      }
    }
    return null;
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
      number: _readString(payload, ['rcNumber', 'rc_number', 'RCNumber', 'rcNo', 'rc_no']),
      expiry: _readString(payload, ['rcExpiryDate', 'rc_expiry_date', 'RCExpiryDate', 'rcExpiry']),
    );

    final permit = buildDoc(
      type: 'PERMIT',
      number: _readString(payload, ['permitNumber', 'permit_number', 'PermitNumber', 'permitNo', 'permit_no']),
      expiry: _readString(payload, ['permitExpiryDate', 'permit_expiry_date', 'PermitExpiryDate', 'permitExpiry']),
    );

    final poc = buildDoc(
      type: 'PUC',
      number: _readString(payload, ['pucNumber', 'puc_number', 'PUCNumber', 'pucNo', 'puc_no', 'pocNumber', 'poc_number']),
      expiry: _readString(payload, ['pucExpiryDate', 'puc_expiry_date', 'PUCExpiryDate', 'pucExpiry', 'pocExpiryDate', 'poc_expiry_date']),
    );

    return VehicleDocumentsModel(
      rc: rc,
      permit: permit,
      poc: poc,
    );
  }
}
