class OrderItemModel {
  final String name;
  final int quantity;
  final double total;
  final String formattedTotal;
  final String image;

  OrderItemModel({
    required this.name,
    required this.quantity,
    required this.total,
    required this.formattedTotal,
    required this.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      total: (json['total'] is num) ? (json['total'] as num).toDouble() : 0.0,
      formattedTotal: json['formatted_total'] ?? '৳0',
      image: json['image'] ?? '',
    );
  }
}

class TrackingStep {
  final int step;
  final int stage;
  final String title;
  final String desc;
  final bool completed;
  final bool active;
  final String time;
  final String eta;

  TrackingStep({
    required this.step,
    int? stage,
    required this.title,
    required this.desc,
    required this.completed,
    this.active = false,
    required this.time,
    this.eta = '',
  }) : stage = stage ?? step;

  String get description => desc;

  factory TrackingStep.fromJson(Map<String, dynamic> json) {
    final st = json['stage'] ?? json['step'] ?? 1;
    return TrackingStep(
      step: st,
      stage: st,
      title: json['title'] ?? '',
      desc: json['desc'] ?? json['description'] ?? '',
      completed: json['completed'] ?? false,
      active: json['active'] ?? false,
      time: json['time'] ?? '',
      eta: json['eta'] ?? '',
    );
  }
}

class SteadfastTelemetry {
  final String name;
  final String consignmentId;
  final String trackingCode;
  final bool hasTracking;
  final String status;
  final String statusBengali;
  final String hubLocation;
  final String lastUpdated;
  final bool isDelivered;
  final double codBalance;
  final String codBalanceFormatted;

  SteadfastTelemetry({
    this.name = 'Steadfast Courier',
    this.consignmentId = '',
    this.trackingCode = '',
    this.hasTracking = false,
    this.status = 'in_transit',
    this.statusBengali = 'পার্সেলটি ডেলিভারির জন্য রাইডারের কাছে আছে',
    this.hubLocation = 'ঢাকা সেন্ট্রাল সর্টিং হাব, তেজগাঁও',
    this.lastUpdated = '',
    this.isDelivered = false,
    this.codBalance = 0.0,
    this.codBalanceFormatted = '৳0',
  });

  factory SteadfastTelemetry.fromJson(Map<String, dynamic> json) {
    final code = (json['consignment_id'] ?? json['tracking_code'] ?? '').toString();
    return SteadfastTelemetry(
      name: json['name'] ?? 'Steadfast Courier',
      consignmentId: code,
      trackingCode: code,
      hasTracking: json['has_tracking'] == true || code.trim().isNotEmpty,
      status: json['status'] ?? 'in_transit',
      statusBengali: json['status_bengali'] ?? 'পার্সেলটি ডেলিভারির জন্য রাইডারের কাছে আছে',
      hubLocation: json['hub_location'] ?? 'ঢাকা সেন্ট্রাল সর্টিং হাব, তেজগাঁও',
      lastUpdated: json['last_updated'] ?? '',
      isDelivered: json['is_delivered'] == true,
      codBalance: (json['cod_balance'] is num) ? (json['cod_balance'] as num).toDouble() : 0.0,
      codBalanceFormatted: json['cod_balance_formatted'] ?? '৳0',
    );
  }
}

class OrderTrackingModel {
  final int orderId;
  final int currentStage;
  final String status;
  final String statusLabel;
  final bool isInsideDhaka;
  final String etaLabel;
  final String deliveryEta;
  final double total;
  final String formattedTotal;
  final double paidAmount;
  final double codBalance;
  final String codBalanceFormatted;
  final String billingName;
  final String billingPhone;
  final String shippingAddress;
  final List<OrderItemModel> items;
  final List<TrackingStep> timeline;
  final SteadfastTelemetry? courierTelemetry;
  final String trackingStage;
  final String courierName;
  final String courierCode;
  final String courierTrackingUrl;
  final String klScanTime;
  final String dhakaScanTime;
  final bool readyForCourier;
  final bool isCancelled;
  final bool isRefunded;
  final String funnelCategory;
  final String paymentStatus;
  final String paymentRejectionReason;
  final int paymentDeadlineTs;
  final int remainingPaymentSeconds;
  final String fulfillmentStage;
  final bool canCancel;
  final bool canReturn;
  final String returnStatus;
  final String cancellationReason;

  OrderTrackingModel({
    required this.orderId,
    this.currentStage = 1,
    required this.status,
    required this.statusLabel,
    this.isInsideDhaka = true,
    this.etaLabel = '২–৪ দিনের মধ্যে ঢাকায় পৌঁছাবে',
    this.deliveryEta = '১–২ দিনের মধ্যে ডেলিভারি',
    required this.total,
    required this.formattedTotal,
    this.paidAmount = 0.0,
    this.codBalance = 0.0,
    this.codBalanceFormatted = '৳0',
    required this.billingName,
    required this.billingPhone,
    required this.shippingAddress,
    required this.items,
    required this.timeline,
    this.courierTelemetry,
    this.trackingStage = 'order_placed',
    this.courierName = 'Steadfast',
    this.courierCode = '',
    this.courierTrackingUrl = '',
    this.klScanTime = '',
    this.dhakaScanTime = '',
    this.readyForCourier = false,
    this.isCancelled = false,
    this.isRefunded = false,
    this.funnelCategory = 'to_pay',
    this.paymentStatus = 'pending',
    this.paymentRejectionReason = '',
    this.paymentDeadlineTs = 0,
    this.remainingPaymentSeconds = 0,
    this.fulfillmentStage = 'sourcing',
    this.canCancel = false,
    this.canReturn = false,
    this.returnStatus = '',
    this.cancellationReason = '',
  });

  bool get isOrderCancelled => isCancelled || status.toLowerCase().contains('cancel');
  bool get isOrderRefunded => isRefunded || status.toLowerCase().contains('refund');
  bool get isPaymentRejected => paymentStatus == 'rejected';
  bool get isPaymentUnderReview => paymentStatus == 'under_review';
  bool get isPaymentApproved => paymentStatus == 'approved';

  bool get hasCourierTracking => !isOrderCancelled && ((courierTelemetry?.hasTracking ?? false) || courierCode.trim().isNotEmpty);

  String get directSteadfastUrl {
    if (courierTrackingUrl.isNotEmpty) return courierTrackingUrl;
    if (courierCode.isNotEmpty) return 'https://steadfast.com.bd/t/$courierCode';
    if (courierTelemetry != null && courierTelemetry!.consignmentId.isNotEmpty) {
      return 'https://steadfast.com.bd/t/${courierTelemetry!.consignmentId}';
    }
    return '';
  }

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List? ?? []).map((e) => OrderItemModel.fromJson(e)).toList();
    final timelineList = (json['timeline'] as List? ?? []).map((e) => TrackingStep.fromJson(e)).toList();
    
    // Parse courier telemetry if available
    SteadfastTelemetry? courier;
    if (json['courier'] is Map<String, dynamic>) {
      courier = SteadfastTelemetry.fromJson(json['courier']);
    }

    final code = courier?.consignmentId.isNotEmpty == true 
        ? courier!.consignmentId 
        : (json['courier_code'] ?? json['courier_tracking_code'] ?? json['steadfast_code'] ?? '').toString();
    final url = (json['courier_tracking_url'] ?? json['tracking_url'] ?? '').toString();
    final stage = json['current_stage'] ?? json['stage'] ?? 1;

    return OrderTrackingModel(
      orderId: json['order_id'] ?? 0,
      currentStage: stage is int ? stage : int.tryParse(stage.toString()) ?? 1,
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'] ?? 'Processing',
      isInsideDhaka: json['is_inside_dhaka'] == true,
      etaLabel: json['eta_label'] ?? '২–৪ দিনের মধ্যে ঢাকায় পৌঁছাবে',
      deliveryEta: json['delivery_eta'] ?? (json['is_inside_dhaka'] == true ? '১–২ দিনের মধ্যে ডেলিভারি' : '২–৩ দিনের মধ্যে ডেলিভারি'),
      total: (json['total'] is num) ? (json['total'] as num).toDouble() : 0.0,
      formattedTotal: json['formatted_total'] ?? '৳0',
      paidAmount: (json['paid_amount'] is num) ? (json['paid_amount'] as num).toDouble() : 0.0,
      codBalance: (json['cod_balance'] is num) ? (json['cod_balance'] as num).toDouble() : (courier?.codBalance ?? 0.0),
      codBalanceFormatted: json['cod_balance_formatted'] ?? (courier?.codBalanceFormatted ?? '৳0'),
      billingName: json['billing_name'] ?? '',
      billingPhone: json['billing_phone'] ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      items: itemsList,
      timeline: timelineList,
      courierTelemetry: courier,
      trackingStage: json['tracking_stage'] ?? 'order_placed',
      courierName: json['courier_name'] ?? courier?.name ?? 'Steadfast',
      courierCode: code,
      courierTrackingUrl: url.isNotEmpty ? url : (code.isNotEmpty ? 'https://steadfast.com.bd/t/$code' : ''),
      klScanTime: json['kl_scan_time'] ?? '',
      dhakaScanTime: json['dhaka_scan_time'] ?? '',
      readyForCourier: json['ready_for_courier_pickup'] == true || json['ready_for_courier'] == true || (stage >= 5),
      isCancelled: json['is_cancelled'] == true || (json['status'] ?? '').toString().toLowerCase().contains('cancel'),
      isRefunded: json['is_refunded'] == true || (json['status'] ?? '').toString().toLowerCase().contains('refund'),
      funnelCategory: json['funnel_category'] ?? 'to_pay',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentRejectionReason: json['payment_rejection_reason'] ?? '',
      paymentDeadlineTs: json['payment_deadline_ts'] is int ? json['payment_deadline_ts'] : int.tryParse(json['payment_deadline_ts']?.toString() ?? '0') ?? 0,
      remainingPaymentSeconds: json['remaining_payment_seconds'] is int ? json['remaining_payment_seconds'] : int.tryParse(json['remaining_payment_seconds']?.toString() ?? '0') ?? 0,
      fulfillmentStage: json['fulfillment_stage'] ?? 'sourcing',
      canCancel: json['can_cancel'] == true,
      canReturn: json['can_return'] == true,
      returnStatus: json['return_status'] ?? '',
      cancellationReason: json['cancellation_reason'] ?? '',
    );
  }
}
