import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_doc_type.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';
import 'package:frontend/features/kyc/domain/kyc_exception.dart';

class KycRemoteDataSource {
  KycRemoteDataSource(this._dio);

  // _dio: client chính (có Bearer + base /api). _uploadDio: client trần để
  // PUT thẳng lên presigned URL của MinIO, không kèm interceptor/Authorization.
  final Dio _dio;
  final Dio _uploadDio = Dio();

  Future<KycStatusInfo> getStatus() async {
    try {
      final res = await _dio.get<dynamic>(KycEndpoints.status);
      return _statusFromJson(_data(res));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<String> uploadDocument({
    required KycDocType docType,
    required File file,
  }) async {
    final contentType = _contentTypeFor(file.path);
    try {
      final res = await _dio.post<dynamic>(
        KycEndpoints.uploadUrl,
        data: {'docType': docType.wireValue, 'contentType': contentType},
      );
      final data = _data(res) as Map<String, dynamic>;
      final uploadUrl = data['uploadUrl'] as String;
      final objectKey = data['objectKey'] as String;

      final bytes = await file.readAsBytes();
      await _uploadDio.put<dynamic>(
        uploadUrl,
        data: Stream<List<int>>.fromIterable([bytes]),
        options: Options(
          headers: {Headers.contentLengthHeader: bytes.length},
          contentType: contentType,
        ),
      );
      return objectKey;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<KycStatusInfo> submit({
    required String cccdKey,
    required String licenseKey,
    required String faceKey,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        KycEndpoints.submit,
        data: {
          'cccdKey': cccdKey,
          'licenseKey': licenseKey,
          'faceKey': faceKey,
        },
      );
      return _statusFromJson(_data(res));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // submit trả về bản ghi KYCVerification (có createdAt), status trả về
  // KycStatusResult (có submittedAt) — đọc linh hoạt cả hai shape.
  KycStatusInfo _statusFromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return KycStatusInfo(
      status: kycStatusFromWire(map['status'] as String?),
      rejectReason: map['rejectReason'] as String?,
      reviewedAt: _parseDate(map['reviewedAt']),
      submittedAt: _parseDate(map['submittedAt'] ?? map['createdAt']),
    );
  }

  DateTime? _parseDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  String _contentTypeFor(String path) =>
      path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

  dynamic _data(Response<dynamic> res) {
    final body = res.data as Map<String, dynamic>;
    return body['data'];
  }

  KycException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return KycException(
        (data['error'] as String?) ?? 'Đã xảy ra lỗi',
        code: data['code'] as String?,
      );
    }
    return const KycException('Không thể kết nối tới máy chủ');
  }
}
