import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_state.dart';

export 'package:frontend/features/kyc/domain/entities/kyc_state.dart';

class KycUploadCubit extends Cubit<KycUploadState> {
  KycUploadCubit() : super(const KycUploadState());

  Future<void> uploadDoc(String docType) async {
    final uploading = const KycDocState(status: DocStatus.uploading);
    emit(_withDoc(docType, uploading));
    await Future.delayed(const Duration(milliseconds: 1400));
    final uploaded = KycDocState(
      status: DocStatus.uploaded,
      fileName: '${docType}_mock.jpg',
    );
    emit(_withDoc(docType, uploaded));
  }

  Future<void> submit() async {
    if (!state.allUploaded) return;
    emit(state.copyWith(isSubmitting: true));
    await Future.delayed(const Duration(milliseconds: 1200));
    emit(state.copyWith(isSubmitting: false, submitted: true));
  }

  KycUploadState _withDoc(String type, KycDocState doc) => switch (type) {
    'cccd' => state.copyWith(cccd: doc),
    'license' => state.copyWith(license: doc),
    'selfie' => state.copyWith(selfie: doc),
    _ => state,
  };
}
