import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/document_verification_model.dart';
import '../../data/repositories/document_verification_repository.dart';

// Repository Provider
final documentVerificationRepositoryProvider = Provider<DocumentVerificationRepository>((ref) {
  return DocumentVerificationRepository();
});

// Document Verification Provider
final documentVerificationProvider = FutureProvider<VehicleDocumentsModel>((ref) async {
  final repository = ref.watch(documentVerificationRepositoryProvider);
  return await repository.getDocuments();
});
