/// Chi tiết một đơn cho ADMIN: gom payment/contract/inspection/dispute để quyết
/// định can thiệp (hoàn tiền). photoKeys KHÔNG lộ — chỉ đếm số ảnh.
class AdminBookingDetail {
  const AdminBookingDetail({
    required this.id,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.deliveryRequested,
    required this.createdAt,
    required this.vehicle,
    required this.renter,
    required this.inspections,
    required this.disputes,
    this.payment,
    this.contract,
    this.damageReport,
  });

  final String id;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final bool deliveryRequested;
  final DateTime createdAt;
  final AdminBookingVehicle vehicle;
  final AdminBookingRenter renter;
  final AdminBookingPayment? payment;
  final AdminBookingContract? contract;
  final List<AdminBookingInspection> inspections;
  final List<AdminBookingDispute> disputes;
  final AdminBookingDamageReport? damageReport;
}

class AdminBookingVehicle {
  const AdminBookingVehicle({
    required this.id,
    required this.title,
    required this.type,
  });

  final String id;
  final String title;
  final String type;
}

class AdminBookingRenter {
  const AdminBookingRenter({
    required this.id,
    required this.phone,
    this.email,
  });

  final String id;
  final String phone;
  final String? email;
}

class AdminBookingPayment {
  const AdminBookingPayment({
    required this.method,
    required this.status,
    required this.amount,
    this.gatewayRef,
    this.paidAt,
  });

  final String method;
  final String status; // PENDING | PAID | FAILED | REFUNDED
  final double amount;
  final String? gatewayRef;
  final DateTime? paidAt;
}

class AdminBookingContract {
  const AdminBookingContract({required this.pdfUrl, this.signedAt});

  final String pdfUrl;
  final DateTime? signedAt;
}

class AdminBookingInspection {
  const AdminBookingInspection({
    required this.phase,
    required this.photoCount,
    required this.createdAt,
  });

  final String phase; // CHECKIN | CHECKOUT
  final int photoCount;
  final DateTime createdAt;
}

class AdminBookingDispute {
  const AdminBookingDispute({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final String priority;
  final DateTime createdAt;
}

class AdminBookingDamageReport {
  const AdminBookingDamageReport({
    required this.summary,
    required this.estimatedCost,
  });

  final String summary;
  final int estimatedCost;
}
