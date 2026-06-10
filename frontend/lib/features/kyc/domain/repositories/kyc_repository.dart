import 'dart:io';

import 'package:frontend/features/kyc/domain/entities/kyc_doc_type.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';

abstract interface class KycRepository {
  Future<KycStatusInfo> getStatus();

  /// Upload một giấy tờ lên bucket private, trả về objectKey để submit.
  Future<String> uploadDocument({
    required KycDocType docType,
    required File file,
  });

  Future<KycStatusInfo> submit({
    required String cccdKey,
    required String licenseKey,
    required String faceKey,
  });
}
