import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/core/db/app_database.dart';
import 'package:frontend/core/locale/locale_cubit.dart';
import 'package:frontend/core/location/location_service.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/search/search_session.dart';
import 'package:frontend/core/storage/kv_storage.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/core/theme/theme_mode_cubit.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:frontend/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_stats_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_kyc_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_users_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/get_admin_revenue_usecase.dart';
import 'package:frontend/features/admin/domain/usecases/list_admin_disputes_usecase.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_kyc_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_revenue_cubit.dart';
import 'package:frontend/features/admin/presentation/cubit/admin_disputes_cubit.dart';
import 'package:frontend/features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'package:frontend/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:frontend/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:frontend/features/vehicle/domain/usecases/create_vehicle_usecase.dart';
import 'package:frontend/features/vehicle/domain/usecases/delete_vehicle_usecase.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_nearby_vehicles_usecase.dart';
import 'package:frontend/features/vehicle/domain/usecases/list_vehicles_usecase.dart';
import 'package:frontend/features/vehicle/domain/usecases/update_vehicle_usecase.dart';
import 'package:frontend/features/vehicle/domain/usecases/get_vehicle_availability_usecase.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_list_cubit.dart';
import 'package:frontend/features/vehicle/presentation/cubit/vehicle_availability_cubit.dart';
import 'package:frontend/features/map/presentation/cubit/map_cubit.dart';
import 'package:frontend/features/owner/presentation/cubit/vehicle_form_cubit.dart';
import 'package:frontend/features/owner/data/datasources/owner_remote_datasource.dart';
import 'package:frontend/features/owner/data/repositories/owner_repository_impl.dart';
import 'package:frontend/features/owner/domain/repositories/owner_repository.dart';
import 'package:frontend/features/owner/domain/usecases/list_owner_bookings_usecase.dart';
import 'package:frontend/features/owner/domain/usecases/approve_booking_usecase.dart';
import 'package:frontend/features/owner/domain/usecases/reject_booking_usecase.dart';
import 'package:frontend/features/owner/domain/usecases/get_owner_revenue_usecase.dart';
import 'package:frontend/features/owner/presentation/cubit/owner_bookings_cubit.dart';
import 'package:frontend/features/owner/presentation/cubit/owner_revenue_cubit.dart';
import 'package:frontend/features/owner/presentation/cubit/my_vehicles_cubit.dart';
import 'package:frontend/features/owner/presentation/cubit/booking_action_cubit.dart';
import 'package:frontend/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:frontend/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:frontend/features/booking/domain/repositories/booking_repository.dart';
import 'package:frontend/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:frontend/features/booking/domain/usecases/list_bookings_usecase.dart';
import 'package:frontend/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:frontend/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:frontend/features/booking/presentation/cubit/my_trips_cubit.dart';
import 'package:frontend/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:frontend/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:frontend/features/payment/domain/repositories/payment_repository.dart';
import 'package:frontend/features/payment/domain/usecases/confirm_payment_usecase.dart';
import 'package:frontend/features/payment/domain/usecases/create_payment_usecase.dart';
import 'package:frontend/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:frontend/features/review/data/datasources/review_remote_datasource.dart';
import 'package:frontend/features/review/data/repositories/review_repository_impl.dart';
import 'package:frontend/features/review/domain/repositories/review_repository.dart';
import 'package:frontend/features/review/domain/usecases/create_review_usecase.dart';
import 'package:frontend/features/review/domain/usecases/list_user_reviews_usecase.dart';
import 'package:frontend/features/review/presentation/cubit/review_cubit.dart';
import 'package:frontend/features/review/presentation/cubit/user_reviews_cubit.dart';
import 'package:frontend/features/kyc/data/datasources/kyc_remote_datasource.dart';
import 'package:frontend/features/kyc/data/repositories/kyc_repository_impl.dart';
import 'package:frontend/features/kyc/domain/repositories/kyc_repository.dart';
import 'package:frontend/features/kyc/domain/usecases/get_kyc_status_usecase.dart';
import 'package:frontend/features/kyc/domain/usecases/submit_kyc_usecase.dart';
import 'package:frontend/features/kyc/domain/usecases/upload_kyc_document_usecase.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_status_cubit.dart';
import 'package:frontend/features/kyc/presentation/cubit/kyc_upload_cubit.dart';
import 'package:frontend/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:frontend/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:frontend/features/notification/domain/repositories/notification_repository.dart';
import 'package:frontend/features/notification/domain/usecases/list_notifications_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_all_read_usecase.dart';
import 'package:frontend/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:frontend/features/loyalty/data/datasources/loyalty_remote_datasource.dart';
import 'package:frontend/features/loyalty/data/repositories/loyalty_repository_impl.dart';
import 'package:frontend/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:frontend/features/loyalty/domain/usecases/get_loyalty_summary_usecase.dart';
import 'package:frontend/features/loyalty/presentation/cubit/loyalty_cubit.dart';
import 'package:frontend/features/community/data/datasources/community_remote_datasource.dart';
import 'package:frontend/features/community/data/repositories/community_repository_impl.dart';
import 'package:frontend/features/community/domain/repositories/community_repository.dart';
import 'package:frontend/features/community/domain/usecases/create_story_usecase.dart';
import 'package:frontend/features/community/domain/usecases/like_story_usecase.dart';
import 'package:frontend/features/community/domain/usecases/list_stories_usecase.dart';
import 'package:frontend/features/community/presentation/cubit/community_cubit.dart';
import 'package:frontend/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:frontend/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';
import 'package:frontend/features/chat/domain/usecases/create_or_get_conversation_usecase.dart';
import 'package:frontend/features/chat/domain/usecases/list_conversations_usecase.dart';
import 'package:frontend/features/chat/domain/usecases/list_messages_usecase.dart';
import 'package:frontend/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:frontend/features/chat/presentation/cubit/conversation_list_cubit.dart';
import 'package:frontend/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:frontend/features/chat/presentation/cubit/start_conversation_cubit.dart';
import 'package:frontend/features/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:frontend/features/favorite/data/repositories/favorite_repository_impl.dart';
import 'package:frontend/features/favorite/domain/repositories/favorite_repository.dart';
import 'package:frontend/features/favorite/domain/usecases/list_favorites_usecase.dart';
import 'package:frontend/features/favorite/domain/usecases/toggle_favorite_usecase.dart';
import 'package:frontend/features/favorite/presentation/cubit/favorite_cubit.dart';

/// Service locator toàn cục.
final GetIt sl = GetIt.instance;

/// Đăng ký 3 kho lưu trữ trên máy. Gọi 1 lần trong main() trước runApp().
Future<void> setupStorage() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<AppDatabase>(AppDatabase())
    ..registerSingleton<SecureStorage>(
      const SecureStorage(FlutterSecureStorage()),
    )
    ..registerSingleton<KvStorage>(KvStorage(prefs))
    ..registerSingleton<LocaleCubit>(LocaleCubit(sl<KvStorage>()))
    ..registerSingleton<ThemeModeCubit>(ThemeModeCubit(sl<KvStorage>()));
}

/// Đăng ký network + auth (data → domain → presentation). Gọi sau [setupStorage].
/// [AuthCubit] là singleton để router và các màn auth dùng chung 1 phiên.
void setupAuth() {
  sl.registerSingleton<ApiClient>(ApiClient(sl<SecureStorage>()));

  final repository = AuthRepositoryImpl(
    AuthRemoteDataSource(sl<ApiClient>()),
    sl<SecureStorage>(),
  );

  sl
    ..registerSingleton<AuthRepository>(repository)
    ..registerSingleton<AuthCubit>(
      AuthCubit(
        login: LoginUseCase(sl<AuthRepository>()),
        register: RegisterUseCase(sl<AuthRepository>()),
        logout: LogoutUseCase(sl<AuthRepository>()),
        getCurrentUser: GetCurrentUserUseCase(sl<AuthRepository>()),
        updateProfile: UpdateProfileUseCase(sl<AuthRepository>()),
        deleteAccount: DeleteAccountUseCase(sl<AuthRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho admin. Gọi sau [setupAuth] (cần [ApiClient]).
/// [AdminCubit] là factory — mỗi lần mở màn admin tạo mới + load lại số liệu.
void setupAdmin() {
  sl
    ..registerSingleton<AdminRepository>(
      AdminRepositoryImpl(AdminRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<AdminCubit>(
      () => AdminCubit(getStats: GetAdminStatsUseCase(sl<AdminRepository>())),
    )
    ..registerFactory<AdminUsersCubit>(
      () => AdminUsersCubit(
        listUsers: ListAdminUsersUseCase(sl<AdminRepository>()),
      ),
    )
    ..registerFactory<AdminKycCubit>(
      () => AdminKycCubit(listKyc: ListAdminKycUseCase(sl<AdminRepository>())),
    )
    ..registerFactory<AdminRevenueCubit>(
      () => AdminRevenueCubit(
        getRevenue: GetAdminRevenueUseCase(sl<AdminRepository>()),
      ),
    )
    ..registerFactory<AdminDisputesCubit>(
      () => AdminDisputesCubit(
        listDisputes: ListAdminDisputesUseCase(sl<AdminRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho xe. Gọi sau [setupAuth] (cần [ApiClient]).
/// [VehicleListCubit] là factory — mỗi lần vào shell người thuê tạo mới + load.
void setupVehicle() {
  sl
    ..registerSingleton<SearchSession>(SearchSession())
    ..registerSingleton<VehicleRepository>(
      VehicleRepositoryImpl(VehicleRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<VehicleListCubit>(
      () => VehicleListCubit(
        listVehicles: ListVehiclesUseCase(sl<VehicleRepository>()),
        listNearbyVehicles: ListNearbyVehiclesUseCase(sl<VehicleRepository>()),
      ),
    )
    ..registerFactory<VehicleFormCubit>(
      () => VehicleFormCubit(
        createVehicle: CreateVehicleUseCase(sl<VehicleRepository>()),
        updateVehicle: UpdateVehicleUseCase(sl<VehicleRepository>()),
      ),
    )
    ..registerFactory<VehicleAvailabilityCubit>(
      () => VehicleAvailabilityCubit(
        getAvailability: GetVehicleAvailabilityUseCase(sl<VehicleRepository>()),
      ),
    );
}

/// Đăng ký bản đồ trực tiếp (Phase C). Gọi sau [setupVehicle]
/// (cần [VehicleRepository] cho xe quanh đây). [MapCubit] là factory.
void setupMap() {
  sl
    ..registerSingleton<LocationService>(const GeolocatorLocationService())
    ..registerFactory<MapCubit>(
      () => MapCubit(
        locationService: sl<LocationService>(),
        listNearbyVehicles: ListNearbyVehiclesUseCase(sl<VehicleRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho chủ xe. Gọi sau [setupVehicle]
/// (cần [ApiClient] + [VehicleRepository] cho "xe của tôi").
void setupOwner() {
  sl
    ..registerSingleton<OwnerRepository>(
      OwnerRepositoryImpl(OwnerRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<OwnerBookingsCubit>(
      () => OwnerBookingsCubit(
        listBookings: ListOwnerBookingsUseCase(sl<OwnerRepository>()),
        approveBooking: ApproveBookingUseCase(sl<OwnerRepository>()),
        rejectBooking: RejectBookingUseCase(sl<OwnerRepository>()),
      ),
    )
    ..registerFactory<OwnerRevenueCubit>(
      () => OwnerRevenueCubit(
        getRevenue: GetOwnerRevenueUseCase(sl<OwnerRepository>()),
      ),
    )
    ..registerFactory<MyVehiclesCubit>(
      () => MyVehiclesCubit(
        listVehicles: ListVehiclesUseCase(sl<VehicleRepository>()),
        deleteVehicle: DeleteVehicleUseCase(sl<VehicleRepository>()),
      ),
    )
    ..registerFactory<BookingActionCubit>(
      () => BookingActionCubit(
        approveBooking: ApproveBookingUseCase(sl<OwnerRepository>()),
        rejectBooking: RejectBookingUseCase(sl<OwnerRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho đơn đặt. Gọi sau [setupAuth] (cần [ApiClient]).
/// [BookingCubit] là factory — mỗi luồng đặt xe tạo mới + giữ form riêng.
void setupBooking() {
  sl
    ..registerSingleton<BookingRepository>(
      BookingRepositoryImpl(BookingRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<BookingCubit>(
      () => BookingCubit(
        createBooking: CreateBookingUseCase(sl<BookingRepository>()),
      ),
    )
    ..registerFactory<MyTripsCubit>(
      () => MyTripsCubit(
        listBookings: ListBookingsUseCase(sl<BookingRepository>()),
        cancelBooking: CancelBookingUseCase(sl<BookingRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho thanh toán. Gọi sau [setupAuth].
/// [PaymentCubit] là factory — mỗi màn thanh toán một phiên riêng.
void setupPayment() {
  sl
    ..registerSingleton<PaymentRepository>(
      PaymentRepositoryImpl(PaymentRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<PaymentCubit>(
      () => PaymentCubit(
        createPayment: CreatePaymentUseCase(sl<PaymentRepository>()),
        confirmPayment: ConfirmPaymentUseCase(sl<PaymentRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho đánh giá. Gọi sau [setupAuth].
/// [ReviewCubit] là factory — mỗi màn đánh giá một phiên riêng.
void setupReview() {
  sl
    ..registerSingleton<ReviewRepository>(
      ReviewRepositoryImpl(ReviewRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<ReviewCubit>(
      () => ReviewCubit(
        createReview: CreateReviewUseCase(sl<ReviewRepository>()),
      ),
    )
    ..registerFactory<UserReviewsCubit>(
      () => UserReviewsCubit(
        listUserReviews: ListUserReviewsUseCase(sl<ReviewRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho KYC. Gọi sau [setupAuth] (cần [ApiClient]).
void setupKyc() {
  sl
    ..registerSingleton<KycRepository>(
      KycRepositoryImpl(KycRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<KycStatusCubit>(
      () => KycStatusCubit(getStatus: GetKycStatusUseCase(sl<KycRepository>())),
    )
    ..registerFactory<KycUploadCubit>(
      () => KycUploadCubit(
        uploadDocument: UploadKycDocumentUseCase(sl<KycRepository>()),
        submitKyc: SubmitKycUseCase(sl<KycRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho thông báo. Gọi sau [setupAuth].
void setupNotification() {
  sl
    ..registerSingleton<NotificationRepository>(
      NotificationRepositoryImpl(NotificationRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<NotificationCubit>(
      () => NotificationCubit(
        listNotifications: ListNotificationsUseCase(
          sl<NotificationRepository>(),
        ),
        markRead: MarkNotificationReadUseCase(sl<NotificationRepository>()),
        markAllRead: MarkAllNotificationsReadUseCase(
          sl<NotificationRepository>(),
        ),
      ),
    );
}

/// Đăng ký data layer + cubit cho điểm thưởng. Gọi sau [setupAuth].
void setupLoyalty() {
  sl
    ..registerSingleton<LoyaltyRepository>(
      LoyaltyRepositoryImpl(LoyaltyRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<LoyaltyCubit>(
      () => LoyaltyCubit(
        getSummary: GetLoyaltySummaryUseCase(sl<LoyaltyRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho cộng đồng. Gọi sau [setupAuth].
void setupCommunity() {
  sl
    ..registerSingleton<CommunityRepository>(
      CommunityRepositoryImpl(CommunityRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<CommunityCubit>(
      () => CommunityCubit(
        listStories: ListStoriesUseCase(sl<CommunityRepository>()),
        createStory: CreateStoryUseCase(sl<CommunityRepository>()),
        likeStory: LikeStoryUseCase(sl<CommunityRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho xe yêu thích. Gọi sau [setupAuth].
/// [FavoriteCubit] là singleton — giữ trạng thái tim dùng chung toàn app.
void setupFavorite() {
  sl
    ..registerSingleton<FavoriteRepository>(
      FavoriteRepositoryImpl(FavoriteRemoteDataSource(sl<ApiClient>())),
    )
    ..registerSingleton<FavoriteCubit>(
      FavoriteCubit(
        listFavorites: ListFavoritesUseCase(sl<FavoriteRepository>()),
        toggleFavorite: ToggleFavoriteUseCase(sl<FavoriteRepository>()),
      ),
    );
}

/// Đăng ký data layer + cubit cho chat (REST + polling). Gọi sau [setupAuth].
void setupChat() {
  sl
    ..registerSingleton<ChatRepository>(
      ChatRepositoryImpl(ChatRemoteDataSource(sl<ApiClient>())),
    )
    ..registerFactory<ConversationListCubit>(
      () => ConversationListCubit(
        listConversations: ListConversationsUseCase(sl<ChatRepository>()),
      ),
    )
    ..registerFactory<ChatCubit>(
      () => ChatCubit(
        listMessages: ListMessagesUseCase(sl<ChatRepository>()),
        sendMessage: SendMessageUseCase(sl<ChatRepository>()),
      ),
    )
    ..registerFactory<StartConversationCubit>(
      () => StartConversationCubit(
        createOrGetConversation: CreateOrGetConversationUseCase(
          sl<ChatRepository>(),
        ),
      ),
    );
}
