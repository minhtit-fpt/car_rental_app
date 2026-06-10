import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_doc_type.dart';
import 'package:frontend/features/kyc/domain/entities/kyc_status_info.dart';
import 'package:frontend/features/kyc/domain/kyc_exception.dart';
import 'package:frontend/features/kyc/domain/usecases/get_kyc_status_usecase.dart';
import 'package:frontend/features/kyc/domain/usecases/submit_kyc_usecase.dart';
import 'package:frontend/features/kyc/domain/usecases/upload_kyc_document_usecase.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_cubit.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_state.dart';

class MockGetKycStatusUseCase extends Mock implements GetKycStatusUseCase {}

class MockUploadKycDocumentUseCase extends Mock
    implements UploadKycDocumentUseCase {}

class MockSubmitKycUseCase extends Mock implements SubmitKycUseCase {}

class _FakeFile extends Fake implements File {}

void main() {
  late MockGetKycStatusUseCase getStatus;
  late MockUploadKycDocumentUseCase upload;
  late MockSubmitKycUseCase submit;

  final file = _FakeFile();

  setUpAll(() {
    registerFallbackValue(_FakeFile());
    registerFallbackValue(KycDocType.cccd);
  });

  setUp(() {
    getStatus = MockGetKycStatusUseCase();
    upload = MockUploadKycDocumentUseCase();
    submit = MockSubmitKycUseCase();
  });

  KycCubit build() =>
      KycCubit(getStatus: getStatus, upload: upload, submit: submit);

  const unverified = KycStatusInfo(status: KycStatus.unverified);
  const pending = KycStatusInfo(status: KycStatus.pending);

  group('load', () {
    blocTest<KycCubit, KycState>(
      'emits [loading, ready] with the fetched status',
      setUp: () =>
          when(() => getStatus()).thenAnswer((_) async => unverified),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => const [KycLoading(), KycReady(info: unverified)],
    );

    blocTest<KycCubit, KycState>(
      'emits [loading, loadFailure] when the status call fails',
      setUp: () =>
          when(() => getStatus()).thenThrow(const KycException('boom')),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => const [KycLoading(), KycLoadFailure('boom')],
    );
  });

  group('submitDocuments', () {
    blocTest<KycCubit, KycState>(
      'uploads all three docs then submits, ending in PENDING',
      setUp: () {
        when(() => upload(docType: any(named: 'docType'), file: any(named: 'file')))
            .thenAnswer((_) async => 'kyc/u1/key');
        when(() => submit(
              cccdKey: any(named: 'cccdKey'),
              licenseKey: any(named: 'licenseKey'),
              faceKey: any(named: 'faceKey'),
            )).thenAnswer((_) async => pending);
      },
      build: build,
      seed: () => const KycReady(info: unverified),
      act: (cubit) =>
          cubit.submitDocuments(cccd: file, license: file, face: file),
      expect: () => const [
        KycReady(info: unverified, submitting: true),
        KycReady(info: pending),
      ],
      verify: (_) {
        verify(() => upload(
            docType: any(named: 'docType'),
            file: any(named: 'file'))).called(3);
      },
    );

    blocTest<KycCubit, KycState>(
      'surfaces an error and stops submitting when an upload fails',
      setUp: () => when(() => upload(
            docType: any(named: 'docType'),
            file: any(named: 'file'),
          )).thenThrow(const KycException('upload failed')),
      build: build,
      seed: () => const KycReady(info: unverified),
      act: (cubit) =>
          cubit.submitDocuments(cccd: file, license: file, face: file),
      expect: () => const [
        KycReady(info: unverified, submitting: true),
        KycReady(info: unverified, error: 'upload failed'),
      ],
      verify: (_) => verifyNever(() => submit(
            cccdKey: any(named: 'cccdKey'),
            licenseKey: any(named: 'licenseKey'),
            faceKey: any(named: 'faceKey'),
          )),
    );
  });
}
