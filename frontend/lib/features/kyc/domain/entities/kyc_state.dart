enum DocStatus { empty, uploading, uploaded, error }

class KycDocState {
  const KycDocState({this.status = DocStatus.empty, this.fileName});
  final DocStatus status;
  final String? fileName;

  KycDocState copyWith({DocStatus? status, String? fileName}) =>
      KycDocState(status: status ?? this.status, fileName: fileName ?? this.fileName);
}

class KycUploadState {
  const KycUploadState({
    this.cccd = const KycDocState(),
    this.license = const KycDocState(),
    this.selfie = const KycDocState(),
    this.isSubmitting = false,
    this.submitted = false,
  });

  final KycDocState cccd;
  final KycDocState license;
  final KycDocState selfie;
  final bool isSubmitting;
  final bool submitted;

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
  }) =>
      KycUploadState(
        cccd: cccd ?? this.cccd,
        license: license ?? this.license,
        selfie: selfie ?? this.selfie,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        submitted: submitted ?? this.submitted,
      );
}
