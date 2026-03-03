import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../shared/config/api_config.dart';
import '../../../../shared/services/storage_service.dart';
import '../models/document_verification_model.dart';

class DocumentVerificationRepository {
  Future<VehicleDocumentsModel> getDocuments() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.vehicleDocumentsEndpoint));

      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_readErrorMessage(response.body, response.statusCode));
      }

      final decodedBody = jsonDecode(response.body);
      final jsonData = _decodeNode(decodedBody);
      final payload = _extractPrimaryPayload(jsonData);

      if (payload is Map &&
          VehicleDocumentsModel.isFlatVehicleDocumentsPayload(payload)) {
        return VehicleDocumentsModel.fromFlatVehicleDocumentsPayload(payload);
      }

      final mapped = _mapVehicleDocuments(payload);
      if (mapped.allDocuments.isEmpty) {
        if (_looksLikeVehicleDetailsPayload(payload)) {
          throw Exception(
            'Documents API mismatch: received vehicle details payload. '
            'Expected rcNumber/rcExpiryDate, permitNumber/permitExpiryDate, pucNumber/pucExpiryDate.',
          );
        }
        throw Exception('Vehicle documents are missing in API response');
      }

      return mapped;
    } catch (e) {
      throw Exception('Failed to get vehicle documents: $e');
    }
  }

  bool _looksLikeVehicleDetailsPayload(dynamic payload) {
    final registration = _extractField(payload, ['registrationNumber', 'registration_number']);
    final model = _extractField(payload, ['model', 'vehicleModel', 'vehicle_model']);
    return (registration ?? '').trim().isNotEmpty && (model ?? '').trim().isNotEmpty;
  }

  String _readErrorMessage(String body, int statusCode) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map && parsed['message'] != null) {
        final text = parsed['message'].toString().trim();
        if (text.isNotEmpty) return text;
      }
    } catch (_) {}
    return 'Failed to fetch vehicle documents (HTTP $statusCode)';
  }

  dynamic _extractPrimaryPayload(dynamic root) {
    bool hasDocumentKeys(dynamic node) {
      if (node is! Map) return false;
      return VehicleDocumentsModel.isFlatVehicleDocumentsPayload(node) ||
          node.containsKey('rc') ||
          node.containsKey('permit') ||
          node.containsKey('puc') ||
          node.containsKey('poc');
    }

    dynamic candidateOrNull(dynamic node) {
      if (node == null) return null;
      final decoded = _decodeNode(node);
      if (hasDocumentKeys(decoded)) return decoded;
      return null;
    }

    if (root is Map) {
      final rootMatch = candidateOrNull(root);
      if (rootMatch != null) return rootMatch;

      final dataMatch = candidateOrNull(root['data']);
      if (dataMatch != null) return dataMatch;

      final docsMatch = candidateOrNull(
        root['documents'] ?? root['vehicleDocuments'] ?? root['vehicle_documents'],
      );
      if (docsMatch != null) return docsMatch;

      final nestedData = root['data'];
      if (nestedData is Map) {
        final nestedVehicleMatch = candidateOrNull(
          nestedData['documents'] ??
              nestedData['vehicleDocuments'] ??
              nestedData['vehicle_documents'] ??
              nestedData['vehicle'],
        );
        if (nestedVehicleMatch != null) return nestedVehicleMatch;
      }
    }
    return root;
  }

  String _normalizeKey(String key) {
    return key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  dynamic _decodeNode(dynamic node) {
    if (node is String) {
      final trimmed = node.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          return _decodeNode(jsonDecode(trimmed));
        } catch (_) {
          return node;
        }
      }
      return node;
    }

    if (node is List) {
      return node.map(_decodeNode).toList();
    }

    if (node is Map) {
      return node.map((key, value) => MapEntry(key, _decodeNode(value)));
    }

    return node;
  }

  String? _extractField(dynamic node, List<String> keys) {
    final normalizedTarget = keys
        .map(_normalizeKey)
        .toSet();

    String? normalizeValue(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return null;
      return text;
    }

    String? search(dynamic current) {
      if (current is Map) {
        for (final entry in current.entries) {
          final key = entry.key.toString();
          final normalizedKey = _normalizeKey(key);
          if (normalizedTarget.contains(normalizedKey)) {
            final value = normalizeValue(entry.value);
            if (value != null) return value;
          }
        }

        for (final entry in current.entries) {
          final value = search(entry.value);
          if (value != null) return value;
        }
      }

      if (current is List) {
        for (final item in current) {
          final value = search(item);
          if (value != null) return value;
        }
      }

      return null;
    }

    return search(node);
  }

  dynamic _extractContainer(dynamic node, List<String> containerKeys) {
    final normalizedTargets = containerKeys.map(_normalizeKey).toSet();

    dynamic search(dynamic current) {
      if (current is Map) {
        for (final entry in current.entries) {
          final normalized = _normalizeKey(entry.key.toString());
          if (normalizedTargets.contains(normalized)) {
            return entry.value;
          }
        }
        for (final entry in current.entries) {
          final found = search(entry.value);
          if (found != null) return found;
        }
      }
      if (current is List) {
        for (final item in current) {
          final found = search(item);
          if (found != null) return found;
        }
      }
      return null;
    }

    return search(node);
  }

  dynamic _extractTypedDocumentContainer(dynamic node, List<String> typeKeys) {
    final normalizedTypes = typeKeys.map(_normalizeKey).toSet();

    dynamic search(dynamic current) {
      if (current is List) {
        for (final item in current) {
          if (item is Map) {
            final type = _extractField(item, ['documentType', 'type', 'docType', 'name']);
            if (type != null && normalizedTypes.contains(_normalizeKey(type))) {
              return item;
            }
          }
          final found = search(item);
          if (found != null) return found;
        }
      }

      if (current is Map) {
        for (final entry in current.entries) {
          final found = search(entry.value);
          if (found != null) return found;
        }
      }

      return null;
    }

    return search(node);
  }

  VehicleDocumentsModel _mapVehicleDocuments(dynamic rawResponse) {
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

    final rcContainer = _extractContainer(rawResponse, ['rc', 'registrationCertificate', 'registration'])
      ?? _extractTypedDocumentContainer(rawResponse, ['rc', 'registration', 'registrationcertificate']);
    final permitContainer = _extractContainer(rawResponse, ['permit'])
      ?? _extractTypedDocumentContainer(rawResponse, ['permit']);
    final pucContainer = _extractContainer(rawResponse, ['puc', 'poc', 'pollutionCertificate', 'pollution'])
      ?? _extractTypedDocumentContainer(rawResponse, ['puc', 'poc', 'pollution', 'pollutioncertificate']);

    final rc = buildDoc(
      type: 'RC',
        number: _extractField(rawResponse, ['rcNumber', 'rc_number', 'RCNumber', 'rcNo', 'rc_no'])
          ?? _extractField(rcContainer, ['number', 'docNumber', 'documentNumber', 'value', 'documentId']),
        expiry: _extractField(rawResponse, ['rcExpiryDate', 'rc_expiry_date', 'RCExpiryDate', 'rcExpiry'])
          ?? _extractField(rcContainer, ['expiryDate', 'expiry', 'validTill', 'expiryOn', 'validUpto', 'validTillDate']),
    );

    final permit = buildDoc(
      type: 'PERMIT',
        number: _extractField(rawResponse, ['permitNumber', 'permit_number', 'PermitNumber', 'permitNo', 'permit_no'])
          ?? _extractField(permitContainer, ['number', 'docNumber', 'documentNumber', 'value', 'documentId']),
        expiry: _extractField(rawResponse, ['permitExpiryDate', 'permit_expiry_date', 'PermitExpiryDate', 'permitExpiry'])
          ?? _extractField(permitContainer, ['expiryDate', 'expiry', 'validTill', 'expiryOn', 'validUpto', 'validTillDate']),
    );

    final poc = buildDoc(
      type: 'PUC',
        number: _extractField(rawResponse, ['pucNumber', 'puc_number', 'PUCNumber', 'pucNo', 'puc_no', 'pocNumber', 'poc_number'])
          ?? _extractField(pucContainer, ['number', 'docNumber', 'documentNumber', 'value', 'documentId']),
        expiry: _extractField(rawResponse, ['pucExpiryDate', 'puc_expiry_date', 'PUCExpiryDate', 'pucExpiry', 'pocExpiryDate', 'poc_expiry_date'])
          ?? _extractField(pucContainer, ['expiryDate', 'expiry', 'validTill', 'expiryOn', 'validUpto', 'validTillDate']),
    );

    return VehicleDocumentsModel(
      rc: rc,
      permit: permit,
      poc: poc,
    );
  }
}
