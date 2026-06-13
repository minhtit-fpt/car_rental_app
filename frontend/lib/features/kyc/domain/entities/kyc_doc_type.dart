/// Loại giấy tờ KYC. wireValue khớp với backend (cccd|license|face).
enum KycDocType { cccd, license, face }

extension KycDocTypeX on KycDocType {
  String get wireValue => switch (this) {
        KycDocType.cccd => 'cccd',
        KycDocType.license => 'license',
        KycDocType.face => 'face',
      };

  String get label => switch (this) {
        KycDocType.cccd => 'CCCD / CMND',
        KycDocType.license => 'Giấy phép lái xe',
        KycDocType.face => 'Ảnh chân dung',
      };

  String get hint => switch (this) {
        KycDocType.cccd => 'Chụp rõ mặt trước CCCD/CMND',
        KycDocType.license => 'Chụp rõ giấy phép lái xe còn hạn',
        KycDocType.face => 'Ảnh khuôn mặt rõ nét, đủ sáng',
      };
}
