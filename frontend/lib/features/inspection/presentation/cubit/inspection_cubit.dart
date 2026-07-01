import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/features/inspection/domain/entities/inspection_finding.dart';
import 'package:frontend/features/inspection/domain/repositories/inspection_repository.dart';
import 'package:frontend/features/inspection/presentation/cubit/inspection_state.dart';

export 'package:frontend/features/inspection/presentation/cubit/inspection_state.dart';

/// Luồng kiểm tra xe: chọn ảnh nhận/trả → presign+PUT+submit → phân tích VLM.
// ponytail: cubit gọi thẳng repository (4 thao tác passthrough, không cần lớp
// usecase riêng). Thêm usecase nếu sau này có business logic xen vào.
class InspectionCubit extends Cubit<InspectionState> {
  InspectionCubit({
    required this.bookingId,
    required InspectionRepository repository,
    ImagePicker? picker,
  }) : _repo = repository,
       _picker = picker ?? ImagePicker(),
       super(const InspectionState());

  final String bookingId;
  final InspectionRepository _repo;
  final ImagePicker _picker;

  static const _checkin = 'CHECKIN';
  static const _checkout = 'CHECKOUT';

  /// Tải báo cáo đã có (nếu có) khi mở màn. 404 = chưa có → bỏ qua.
  Future<void> loadExistingReport() async {
    try {
      final report = await _repo.getDamageReport(bookingId);
      emit(state.copyWith(report: report));
    } on ApiException {
      // Chưa có báo cáo — trạng thái mặc định.
    }
  }

  Future<void> pickCheckinPhotos() => _pickAndSubmit(_checkin);
  Future<void> pickCheckoutPhotos() => _pickAndSubmit(_checkout);

  Future<void> _pickAndSubmit(String phase) async {
    final images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;
    if (images.length > 8) {
      emit(state.copyWith(errorMessage: 'Tối đa 8 ảnh mỗi lượt'));
      return;
    }

    emit(_withPhase(phase, PhaseStatus.working, 0));
    try {
      final keys = <String>[];
      for (final image in images) {
        final contentType = _contentTypeOf(image.name);
        if (contentType == null) {
          emit(
            _withPhase(phase, PhaseStatus.error, 0).copyWith(
              errorMessage: 'Chỉ chấp nhận ảnh JPG hoặc PNG',
            ),
          );
          return;
        }
        final key = await _repo.uploadPhoto(
          bookingId: bookingId,
          phase: phase,
          bytes: await image.readAsBytes(),
          contentType: contentType,
        );
        keys.add(key);
      }
      final finding = await _repo.submitInspection(
        bookingId: bookingId,
        phase: phase,
        photoKeys: keys,
      );
      emit(_withPhase(phase, PhaseStatus.done, keys.length, finding: finding));
    } on ApiException catch (e) {
      emit(
        _withPhase(phase, PhaseStatus.error, 0).copyWith(
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> analyze() async {
    if (!state.canAnalyze) return;
    emit(state.copyWith(isAnalyzing: true, errorMessage: null));
    try {
      final report = await _repo.analyzeDamage(bookingId);
      emit(state.copyWith(isAnalyzing: false, report: report));
    } on ApiException catch (e) {
      emit(state.copyWith(isAnalyzing: false, errorMessage: e.message));
    }
  }

  InspectionState _withPhase(
    String phase,
    PhaseStatus status,
    int count, {
    InspectionFinding? finding,
  }) => phase == _checkin
      ? state.copyWith(
          checkin: status,
          checkinCount: count,
          checkinFinding: finding,
          errorMessage: null,
        )
      : state.copyWith(
          checkout: status,
          checkoutCount: count,
          checkoutFinding: finding,
          errorMessage: null,
        );

  String? _contentTypeOf(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return null;
  }
}
