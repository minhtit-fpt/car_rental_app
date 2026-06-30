/// Presigned URL 3 giấy tờ KYC để ADMIN xem khi duyệt (`/api/kyc/:id/documents`).
/// URL ngắn hạn — không phải public URL của bucket private.
class KycDocuments {
  const KycDocuments({
    required this.cccdUrl,
    required this.licenseUrl,
    required this.faceUrl,
  });

  final String cccdUrl;
  final String licenseUrl;
  final String faceUrl;
}
