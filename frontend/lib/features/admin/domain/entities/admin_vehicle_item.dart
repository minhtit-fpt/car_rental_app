/// Một xe trong hàng đợi duyệt của ADMIN (`/api/admin/vehicles`).
class AdminVehicleItem {
  const AdminVehicleItem({
    required this.id,
    required this.title,
    required this.type,
    required this.pricePerHour,
    required this.isElectric,
    required this.approvalStatus,
    required this.createdAt,
    required this.ownerId,
    required this.ownerPhone,
    this.city,
    this.rejectionReason,
    this.ownerEmail,
  });

  final String id;
  final String title;
  final String type; // CAR | MOTORBIKE | BICYCLE
  final double pricePerHour;
  final bool isElectric;
  final String? city;
  final String approvalStatus; // PENDING | APPROVED | REJECTED
  final String? rejectionReason;
  final DateTime createdAt;
  final String ownerId;
  final String ownerPhone;
  final String? ownerEmail;
}
