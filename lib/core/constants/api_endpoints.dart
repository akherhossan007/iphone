class ApiEndpoints {
  static const String baseUrl = 'https://glowbaybd.com/wp-json/glowbay-app/v1';

  static const String home = '$baseUrl/home';
  static const String flashSale = '$baseUrl/flash-sale';
  static const String categories = '$baseUrl/categories';
  static const String brands = '$baseUrl/brands';
  static const String products = '$baseUrl/products';
  static const String productDetail = '$baseUrl/products/';
  static const String createOrder = '$baseUrl/orders/create';
  static const String trackOrder = '$baseUrl/orders/track/';
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String userDashboard = '$baseUrl/user/dashboard';
  static const String userOrders = '$baseUrl/user/orders';
  static const String userAddresses = '$baseUrl/user/addresses';
  static const String vouchers = '$baseUrl/vouchers';
  static const String requestProduct = '$baseUrl/request-product';
  static const String affiliateStats = '$baseUrl/affiliate/stats';
  static const String paymentMethods = '$baseUrl/payment-methods';
  static const String validateCoupon = '$baseUrl/coupons/validate';
  static const String reviews = '$baseUrl/reviews';
  static const String socialLogin = '$baseUrl/auth/social-login';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String sendEmailOtp = '$baseUrl/auth/email/send-otp';
  static const String verifyEmailOtp = '$baseUrl/auth/email/verify-otp';
  static const String liveBaseUrl = 'https://glowbaybd.com/wp-json/glowbay/v1';
  static const String whatsAppSendOtp = '$liveBaseUrl/auth/whatsapp/send-otp';
  static const String whatsAppVerifyOtp = '$liveBaseUrl/auth/whatsapp/verify-otp';
  static const String liveTrackOrder = '$liveBaseUrl/track-order/';
  static const String scanBarcode = '$liveBaseUrl/scan-barcode';
  static const String scanBarcodeApp = '$baseUrl/scan-barcode';
  static String cancelOrder(int id) => '$baseUrl/orders/$id/cancel';
  static String resubmitPayment(int id) => '$baseUrl/orders/$id/resubmit-payment';
  static String requestReturn(int id) => '$baseUrl/orders/$id/request-return';
}
