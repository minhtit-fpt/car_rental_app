import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_doc_type.dart';
import 'package:frontend/features/kyc/domain/kyc_exception.dart';
import 'package:frontend/features/kyc/domain/usecases/get_kyc_status_usecase.dart';
import 'package:frontend/features/kyc/domain/usecases/submit_kyc_usecase.dart';
import 'package:frontend/features/kyc/domain/usecases/upload_kyc_document_usecase.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_state.dart';

class KycCubit extends Cubit<KycState> {
  KycCubit({
    required GetKycStatusUseCase getStatus,
    required UploadKycDocumentUseCase upload,
    required SubmitKycUseCase submit,
  })  : _getStatus = getStatus,
        _upload = upload,
        _submit = submit,
        super(const KycLoading());

  final GetKycStatusUseCase _getStatus;
  final UploadKycDocumentUseCase _upload;
  final SubmitKycUseCase _submit;

  Future<void> load() async {
    emit(const KycLoading());
    try {
      emit(KycReady(info: await _getStatus()));
    } on KycException catch (e) {
      emit(KycLoadFailure(e.message));
    }
  }

  /// Upload tuần tự 3 giấy tờ → nộp hồ sơ → cập nhật trạng thái PENDING.
  Future<void> submitDocuments({
    required File cccd,
    required File license,
    required File face,
  }) async {
    final current = state;
    if (current is! KycReady || current.submitting) return;

    emit(current.copyWith(submitting: true));
    try {
      final cccdKey = await _upload(docType: KycDocType.cccd, file: cccd);
      final licenseKey =
          await _upload(docType: KycDocType.license, file: license);
      final faceKey = await _upload(docType: KycDocType.face, file: face);
      final info = await _submit(
        cccdKey: cccdKey,
        licenseKey: licenseKey,
        faceKey: faceKey,
      );
      emit(KycReady(info: info));
    } on KycException catch (e) {
      emit(current.copyWith(submitting: false, error: e.message));
    }
  }
}
