import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_state.dart';
import 'package:frontend/features/kyc/domain/usecases/submit_kyc_usecase.dart';
import 'package:frontend/features/kyc/domain/usecases/upload_kyc_document_usecase.dart';

export 'package:frontend/features/kyc/domain/entities/kyc_state.dart';

/// Quản lý luồng upload 3 giấy tờ KYC thật: chọn ảnh → presign + PUT → submit.
class KycUploadCubit extends Cubit<KycUploadState> {
  KycUploadCubit({
    required UploadKycDocumentUseCase uploadDocument,
    required SubmitKycUseCase submitKyc,
    ImagePicker? picker,
  }) : _uploadDocument = uploadDocument,
       _submitKyc = submitKyc,
       _picker = picker ?? ImagePicker(),
       super(const KycUploadState());

  final UploadKycDocumentUseCase _uploadDocument;
  final SubmitKycUseCase _submitKyc;
  final ImagePicker _picker;

  /// docType UI: 'cccd' | 'license' | 'selfie'. Backend nhận 'face' cho selfie.
  Future<void> uploadDoc(String docType) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    final contentType = _contentTypeOf(image.name);
    if (contentType == null) {
      emit(state.copyWith(errorMessage: 'Chỉ chấp nhận ảnh JPG hoặc PNG'));
      return;
    }

    emit(_withDoc(docType, const KycDocState(status: DocStatus.uploading)));
    try {
      final bytes = await image.readAsBytes();
      final objectKey = await _uploadDocument(
        docType: _apiDocType(docType),
        bytes: bytes,
        contentType: contentType,
      );
      emit(
        _withDoc(
          docType,
          KycDocState(
            status: DocStatus.uploaded,
            fileName: image.name,
            objectKey: objectKey,
          ),
        ),
      );
    } on ApiException catch (e) {
      emit(
        _withDoc(
          docType,
          const KycDocState(status: DocStatus.error),
        ).copyWith(errorMessage: e.message),
      );
    }
  }

  Future<void> submit() async {
    if (!state.allUploaded || state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _submitKyc(
        cccdKey: state.cccd.objectKey!,
        licenseKey: state.license.objectKey!,
        faceKey: state.selfie.objectKey!,
      );
      emit(state.copyWith(isSubmitting: false, submitted: true));
    } on ApiException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    }
  }

  String _apiDocType(String uiType) => uiType == 'selfie' ? 'face' : uiType;

  String? _contentTypeOf(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return null;
  }

  KycUploadState _withDoc(String type, KycDocState doc) => switch (type) {
    'cccd' => state.copyWith(cccd: doc),
    'license' => state.copyWith(license: doc),
    'selfie' => state.copyWith(selfie: doc),
    _ => state,
  };
}
