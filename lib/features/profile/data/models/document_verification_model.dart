class DocumentVerificationModel {
  final String documentType; // 'RC', 'PUC', 'Permit'
  final bool isVerified;
  final String? expiryDate; // ISO 8601 format
  final String? documentNumber;
  final String? uploadedAt;

  DocumentVerificationModel({
    required this.documentType,
    required this.isVerified,
    this.expiryDate,
    this.documentNumber,
    this.uploadedAt,
  });

  // Check if document is expired
  bool get isExpired {
    if (expiryDate == null || expiryDate!.isEmpty) return false;
    try {
      final expiry = DateTime.parse(expiryDate!);
      return expiry.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Get status text
  String get status {
    if (!isVerified) return 'Pending Verification';
    if (isExpired) return 'Expired';
    return 'Verified';
  }

  // Get status color
  DocumentStatus get statusType {
    if (!isVerified) return DocumentStatus.pending;
    if (isExpired) return DocumentStatus.expired;
    return DocumentStatus.verified;
  }

  // Get display name
  String get displayName {
    switch (documentType.toUpperCase()) {
      case 'RC':
        return 'Registration Certificate (RC)';
      case 'PUC':
        return 'Pollution Certificate (PUC)';
      case 'POC':
        return 'Pollution Certificate (PUC)';
      case 'PERMIT':
        return 'Permit';
      default:
        return documentType;
    }
  }

  factory DocumentVerificationModel.fromJson(Map<String, dynamic> json) {
    return DocumentVerificationModel(
      documentType: json['documentType'] ?? json['type'] ?? '',
      isVerified: json['isVerified'] ?? json['verified'] ?? false,
      expiryDate: json['expiryDate'] ?? json['expiry'] ?? '',
      documentNumber: json['documentNumber'] ?? json['number'] ?? '',
      uploadedAt: json['uploadedAt'] ?? json['uploaded_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'isVerified': isVerified,
      'expiryDate': expiryDate,
      'documentNumber': documentNumber,
      'uploadedAt': uploadedAt,
    };
  }

  DocumentVerificationModel copyWith({
    String? documentType,
    bool? isVerified,
    String? expiryDate,
    String? documentNumber,
    String? uploadedAt,
  }) {
    return DocumentVerificationModel(
      documentType: documentType ?? this.documentType,
      isVerified: isVerified ?? this.isVerified,
      expiryDate: expiryDate ?? this.expiryDate,
      documentNumber: documentNumber ?? this.documentNumber,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

enum DocumentStatus {
  verified,
  expired,
  pending,
}

class VehicleDocumentsModel {
  final DocumentVerificationModel? rc;
  final DocumentVerificationModel? poc;
  final DocumentVerificationModel? permit;

  VehicleDocumentsModel({
    this.rc,
    this.poc,
    this.permit,
  });

    static bool isFlatVehicleDocumentsPayload(Map<dynamic, dynamic> json) {
    return json.containsKey('rcNumber') ||
      json.containsKey('rc_number') ||
        json.containsKey('permitNumber') ||
      json.containsKey('permit_number') ||
        json.containsKey('pucNumber') ||
      json.containsKey('puc_number') ||
        json.containsKey('pocNumber');
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static DocumentVerificationModel? _buildBackendDoc({
    required String type,
    required dynamic number,
    required dynamic expiry,
  }) {
    final docNumber = _toNullableString(number);
    final expiryDate = _toNullableString(expiry);

    if (docNumber == null && expiryDate == null) {
      return null;
    }

    return DocumentVerificationModel(
      documentType: type,
      isVerified: docNumber != null,
      documentNumber: docNumber,
      expiryDate: expiryDate,
    );
  }

  factory VehicleDocumentsModel.fromFlatVehicleDocumentsPayload(
      Map<dynamic, dynamic> json) {
    return VehicleDocumentsModel(
      rc: _buildBackendDoc(
        type: 'RC',
        number: json['rcNumber'] ?? json['rc_number'],
        expiry: json['rcExpiryDate'] ?? json['rc_expiry_date'],
      ),
      permit: _buildBackendDoc(
        type: 'PERMIT',
        number: json['permitNumber'] ?? json['permit_number'],
        expiry: json['permitExpiryDate'] ?? json['permit_expiry_date'],
      ),
      poc: _buildBackendDoc(
        type: 'PUC',
        number: json['pucNumber'] ?? json['puc_number'] ?? json['pocNumber'] ?? json['poc_number'],
        expiry: json['pucExpiryDate'] ?? json['puc_expiry_date'] ?? json['pocExpiryDate'] ?? json['poc_expiry_date'],
      ),
    );
  }

  factory VehicleDocumentsModel.fromJson(Map<String, dynamic> json) {
    if (isFlatVehicleDocumentsPayload(json)) {
      return VehicleDocumentsModel.fromFlatVehicleDocumentsPayload(json);
    }

    return VehicleDocumentsModel(
      rc: json['rc'] != null
          ? DocumentVerificationModel.fromJson(json['rc'])
          : null,
      poc: json['poc'] != null
          ? DocumentVerificationModel.fromJson(json['poc'])
          : null,
      permit: json['permit'] != null
          ? DocumentVerificationModel.fromJson(json['permit'])
          : null,
    );
  }

  // Alternative factory for list-based JSON response
  factory VehicleDocumentsModel.fromDocumentsList(List<dynamic> documents) {
    DocumentVerificationModel? rc;
    DocumentVerificationModel? poc;
    DocumentVerificationModel? permit;

    for (var doc in documents) {
      final docModel = DocumentVerificationModel.fromJson(doc);
      final type = docModel.documentType.toUpperCase();
      
      if (type == 'RC') {
        rc = docModel;
      } else if (type == 'POC' || type == 'PUC') {
        poc = docModel;
      } else if (type == 'PERMIT') {
        permit = docModel;
      }
    }

    return VehicleDocumentsModel(rc: rc, poc: poc, permit: permit);
  }

  Map<String, dynamic> toJson() {
    return {
      'rc': rc?.toJson(),
      'poc': poc?.toJson(),
      'permit': permit?.toJson(),
    };
  }

  // Get list of all documents
  List<DocumentVerificationModel> get allDocuments {
    return [
      if (rc != null) rc!,
      if (poc != null) poc!,
      if (permit != null) permit!,
    ];
  }

  // Check if all documents are verified
  bool get allVerified {
    return (rc?.isVerified ?? false) &&
           (poc?.isVerified ?? false) &&
           (permit?.isVerified ?? false);
  }

  // Check if any document is expired
  bool get hasExpiredDocuments {
    return (rc?.isExpired ?? false) ||
           (poc?.isExpired ?? false) ||
           (permit?.isExpired ?? false);
  }
}
