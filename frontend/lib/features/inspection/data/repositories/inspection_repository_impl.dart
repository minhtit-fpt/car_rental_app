import 'package:frontend/features/inspection/data/datasources/inspection_remote_datasource.dart';
import 'package:frontend/features/inspection/data/models/damage_report_model.dart';
import 'package:frontend/features/inspection/domain/entities/damage_report.dart';
import 'package:frontend/features/inspection/domain/repositories/inspection_repository.dart';

class InspectionRepositoryImpl implements InspectionRepository {
  const InspectionRepositoryImpl(this._remote);

  final InspectionRemoteDataSource _remote;

  @override
  Future<String> uploadPhoto({
    required String bookingId,
    required String phase,
    required List<int> bytes,
    required String contentType,
  }) async {
    final presign = await _remote.createUploadUrl(
      bookingId: bookingId,
      phase: phase,
      contentType: contentType,
    );
    await _remote.uploadBinary(
      uploadUrl: presign['uploadUrl'] as String,
      bytes: bytes,
      contentType: contentType,
    );
    return presign['objectKey'] as String;
  }

  @override
  Future<void> submitInspection({
    required String bookingId,
    required String phase,
    required List<String> photoKeys,
  }) => _remote.submit(
    bookingId: bookingId,
    phase: phase,
    photoKeys: photoKeys,
  );

  @override
  Future<DamageReport> analyzeDamage(String bookingId) async =>
      DamageReportModel.fromJson(await _remote.analyze(bookingId));

  @override
  Future<DamageReport> getDamageReport(String bookingId) async =>
      DamageReportModel.fromJson(await _remote.getReport(bookingId));
}
