class DocumentVerificationModel {
  final String documentType; // 'RC', 'POC', 'Permit'
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
      case 'POC':
        return 'Pollution Certificate (POC)';
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

  factory VehicleDocumentsModel.fromJson(Map<String, dynamic> json) {
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
      } else if (type == 'POC') {
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
