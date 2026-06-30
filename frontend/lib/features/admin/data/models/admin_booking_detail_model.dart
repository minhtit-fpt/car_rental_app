import 'package:frontend/features/admin/domain/entities/admin_booking_detail.dart';

abstract final class AdminBookingDetailModel {
  static AdminBookingDetail fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>;
    final renter = json['renter'] as Map<String, dynamic>;
    final payment = json['payment'] as Map<String, dynamic>?;
    final contract = json['contract'] as Map<String, dynamic>?;
    final damage = json['damageReport'] as Map<String, dynamic>?;

    return AdminBookingDetail(
      id: json['id'] as String,
      status: json['status'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      deliveryRequested: json['deliveryRequested'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      vehicle: AdminBookingVehicle(
        id: vehicle['id'] as String,
        title: vehicle['title'] as String,
        type: vehicle['type'] as String,
      ),
      renter: AdminBookingRenter(
        id: renter['id'] as String,
        phone: renter['phone'] as String,
        email: renter['email'] as String?,
      ),
      payment: payment == null
          ? null
          : AdminBookingPayment(
              method: payment['method'] as String,
              status: payment['status'] as String,
              amount: (payment['amount'] as num).toDouble(),
              gatewayRef: payment['gatewayRef'] as String?,
              paidAt: payment['paidAt'] == null
                  ? null
                  : DateTime.parse(payment['paidAt'] as String),
            ),
      contract: contract == null
          ? null
          : AdminBookingContract(
              pdfUrl: contract['pdfUrl'] as String,
              signedAt: contract['signedAt'] == null
                  ? null
                  : DateTime.parse(contract['signedAt'] as String),
            ),
      inspections: (json['inspections'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .map(
            (i) => AdminBookingInspection(
              phase: i['phase'] as String,
              photoCount: i['photoCount'] as int,
              createdAt: DateTime.parse(i['createdAt'] as String),
            ),
          )
          .toList(growable: false),
      disputes: (json['disputes'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .map(
            (d) => AdminBookingDispute(
              id: d['id'] as String,
              title: d['title'] as String,
              status: d['status'] as String,
              priority: d['priority'] as String,
              createdAt: DateTime.parse(d['createdAt'] as String),
            ),
          )
          .toList(growable: false),
      damageReport: damage == null
          ? null
          : AdminBookingDamageReport(
              summary: damage['summary'] as String,
              estimatedCost: damage['estimatedCost'] as int,
            ),
    );
  }
}
