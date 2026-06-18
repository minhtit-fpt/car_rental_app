enum DocStatus { empty, uploading, uploaded, error }

class KycDocState {
  const KycDocState({
    this.status = DocStatus.empty,
    this.fileName,
    this.objectKey,
  });
  final DocStatus status;
  final String? fileName;

  /// Key trên storage do backend cấp sau khi upload thành công — dùng khi submit.
  final String? objectKey;

  KycDocState copyWith({
    DocStatus? status,
    String? fileName,
    String? objectKey,
  }) => KycDocState(
    status: status ?? this.status,
    fileName: fileName ?? this.fileName,
    objectKey: objectKey ?? this.objectKey,
  );
}

class KycUploadState {
  const KycUploadState({
    this.cccd = const KycDocState(),
    this.license = const KycDocState(),
    this.selfie = const KycDocState(),
    this.isSubmitting = false,
    this.submitted = false,
    this.errorMessage,
  });

  final KycDocState cccd;
  final KycDocState license;
  final KycDocState selfie;
  final bool isSubmitting;
  final bool submitted;

  /// Thông báo lỗi gần nhất (upload hoặc submit) để UI hiển thị.
  final String? errorMessage;

  bool get allUploaded =>
      cccd.status == DocStatus.uploaded &&
      license.status == DocStatus.uploaded &&
      selfie.status == DocStatus.uploaded;

  KycUploadState copyWith({
    KycDocState? cccd,
    KycDocState? license,
    KycDocState? selfie,
    bool? isSubmitting,
    bool? submitted,
    String? errorMessage,
  }) => KycUploadState(
    cccd: cccd ?? this.cccd,
    license: license ?? this.license,
    selfie: selfie ?? this.selfie,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    submitted: submitted ?? this.submitted,
    errorMessage: errorMessage,
  );
}
