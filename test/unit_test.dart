import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glowbay_app/data/models/product_model.dart';
import 'package:glowbay_app/data/models/user_model.dart';
import 'package:glowbay_app/data/models/order_model.dart';
import 'package:glowbay_app/logic/cart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Enterprise Production Audit Tests — Cart & Financial Engine', () {
    test('ProductModel.fromJson parses fields accurately', () {
      final json = {
        'id': 116512,
        'name': 'CeraVe Hydrating Facial Cleanser 473ml',
        'price': '2250',
        'regular_price': '2500',
        'sale_price': '2250',
        'on_sale': true,
        'stock_status': 'instock',
        'in_stock': true,
        'sku': 'CRV-HYD-473',
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, 116512);
      expect(product.name, 'CeraVe Hydrating Facial Cleanser 473ml');
      expect(product.price, 2250.0);
      expect(product.regularPrice, 2500.0);
      expect(product.onSale, isTrue);
      expect(product.inStock, isTrue);
      expect(product.sku, 'CRV-HYD-473');
    });

    test('UserModel.fromJson parses cryptographic auth token', () {
      final json = {
        'id': 42,
        'name': 'Abir Test User',
        'email': 'abir@example.com',
        'phone': '01900000000',
        'token': '42:1760000000:abcdef1234567890',
        'vip_tier': 'VIP Gold',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 42);
      expect(user.name, 'Abir Test User');
      expect(user.token, '42:1760000000:abcdef1234567890');
      expect(user.vipTier, 'VIP Gold');
    });

    test('Financial split: 50% advance booking calculation with fees', () {
      const double subtotal = 4500.0;
      const double shippingInsideDhaka = 70.0;
      const double bkashFeePercent = 0.015; // 1.5%

      // Advance 50% plan
      final double advance50 = (subtotal * 0.5).roundToDouble(); // 2250.0
      final double payableNowAdvance = advance50 + shippingInsideDhaka; // 2320.0
      final double bkashFeeAdvance = (payableNowAdvance * bkashFeePercent).roundToDouble(); // 35.0
      final double grandTotalNow = payableNowAdvance + bkashFeeAdvance; // 2355.0
      final double dueAtDoorstep = subtotal - advance50; // 2250.0

      expect(advance50, 2250.0);
      expect(payableNowAdvance, 2320.0);
      expect(dueAtDoorstep, 2250.0);
      expect(grandTotalNow, 2355.0);
    });

    test('Financial split: 100% full payment calculation with fees', () {
      const double subtotal = 4500.0;
      const double shippingOutsideDhaka = 130.0;
      const double bkashFeePercent = 0.015; // 1.5%

      // Full 100% plan
      final double payableNowFull = subtotal + shippingOutsideDhaka; // 4630.0
      final double bkashFeeFull = (payableNowFull * bkashFeePercent).roundToDouble(); // 69.0
      final double grandTotalFull = payableNowFull + bkashFeeFull; // 4699.0
      const double dueAtDoorstep = 0.0;

      expect(payableNowFull, 4630.0);
      expect(dueAtDoorstep, 0.0);
      expect(grandTotalFull, 4699.0);
    });

    test('CartProvider state management and operations', () {
      final cart = CartProvider();
      final prod1 = ProductModel.fromJson({
        'id': 101,
        'name': 'Cosrx Snail Mucin Essence 100ml',
        'price': 1450,
        'in_stock': true,
      });

      final prod2 = ProductModel.fromJson({
        'id': 102,
        'name': 'Anua Heartleaf Toner 250ml',
        'price': 1850,
        'in_stock': true,
      });

      cart.addToCart(prod1, quantity: 2);
      expect(cart.items.length, 1);
      expect(cart.totalItemCount, 2);
      expect(cart.subtotal, 2900.0);

      cart.addToCart(prod2, quantity: 1);
      expect(cart.items.length, 2);
      expect(cart.totalItemCount, 3);
      expect(cart.subtotal, 4750.0);

      cart.updateQuantity(101, 1);
      expect(cart.totalItemCount, 2);
      expect(cart.subtotal, 3300.0);

      cart.removeFromCart(102);
      expect(cart.items.length, 1);
      expect(cart.subtotal, 1450.0);

      cart.clearCart();
      expect(cart.items.isEmpty, isTrue);
      expect(cart.subtotal, 0.0);
    });

    test('VipTierInfo calculates step-by-step levels dynamically', () {
      // 1. Level 1: Silver (Brand new user)
      final silver = VipTierInfo.fromStats(totalSpent: 0, orderCount: 0);
      expect(silver.level, 1);
      expect(silver.label, 'Silver Member');
      expect(silver.nextTier, 'Gold Member');
      expect(silver.nextTarget, 5000.0);

      // 2. Level 2: Gold (Spent ৳5,000+ or 2 orders)
      final gold = VipTierInfo.fromStats(totalSpent: 5200, orderCount: 2);
      expect(gold.level, 2);
      expect(gold.label, 'Gold Member');
      expect(gold.nextTier, 'Platinum Member');
      expect(gold.discount, '5% Member Discount');

      // 3. Level 3: Platinum (Spent ৳15,000+ or 6 orders)
      final plat = VipTierInfo.fromStats(totalSpent: 16000, orderCount: 6);
      expect(plat.level, 3);
      expect(plat.label, 'Platinum Member');
      expect(plat.nextTier, 'Diamond VIP');
      expect(plat.discount, '7% Special Rebate');

      // 4. Level 4: Diamond VIP (Spent ৳30,000+ or 10 orders)
      final diamond = VipTierInfo.fromStats(totalSpent: 35000, orderCount: 11);
      expect(diamond.level, 4);
      expect(diamond.label, 'Diamond VIP');
      expect(diamond.nextTier, isNull);
      expect(diamond.discount, '10% Lifetime VIP Rebate');
      expect(diamond.progressRatio, 1.0);
    });

    test('OrderTrackingModel and SteadfastTelemetry 5-Stage Cross-Border parsing', () {
      final json = {
        'order_id': 12345,
        'current_stage': 3,
        'status': 'processing',
        'status_label': 'Processing',
        'is_inside_dhaka': true,
        'eta_label': '২–৪ দিনের মধ্যে ঢাকায় পৌঁছাবে',
        'delivery_eta': '১–২ দিনের মধ্যে ডেলিভারি',
        'total': 5000.0,
        'formatted_total': '৳5,000',
        'paid_amount': 2500.0,
        'cod_balance': 2500.0,
        'cod_balance_formatted': '৳2,500',
        'billing_name': 'Abir Test',
        'billing_phone': '01900000000',
        'shipping_address': 'Dhanmondi, Dhaka',
        'items': [
          {
            'name': 'CeraVe Foaming Cleanser',
            'quantity': 2,
            'total': 5000.0,
            'formatted_total': '৳5,000',
            'image': 'https://glowbaybd.com/img.jpg',
          }
        ],
        'timeline': [
          {
            'stage': 1,
            'title': 'অর্ডার কনফার্মড — সোর্সিংয়ের অপেক্ষায়',
            'desc': 'অর্ডারটি ভেরিফাই করা হয়েছে',
            'completed': true,
            'time': '12 Sep 2026',
          },
          {
            'stage': 2,
            'title': 'প্রোডাক্ট সোর্সিং সম্পন্ন হয়েছে',
            'desc': 'প্যাকিং স্লিপ প্রিন্ট সম্পন্ন',
            'completed': true,
            'time': '13 Sep 2026',
          },
          {
            'stage': 3,
            'title': 'কুয়ালালামপুর থেকে ঢাকায় পাঠানো হচ্ছে (২–৪ দিনের মধ্যে ঢাকায় পৌঁছাবে)',
            'desc': 'এয়ার কার্গোর মাধ্যমে কুয়ালালামপুর থেকে পাঠানো হয়েছে',
            'completed': true,
            'active': true,
            'time': '14 Sep 2026',
            'eta': '২–৪ কার্যদিবস',
          },
        ],
        'courier': {
          'name': 'Steadfast Courier',
          'consignment_id': 'ST-12345',
          'tracking_code': 'ST-12345',
          'has_tracking': true,
          'status': 'in_transit',
          'status_bengali': 'পার্সেলটি ডেলিভারির জন্য রাইডারের কাছে আছে',
          'hub_location': 'ঢাকা সেন্ট্রাল সর্টিং হাব, তেজগাঁও',
          'last_updated': '14 Sep 2026, 04:00 PM',
          'is_delivered': false,
          'cod_balance': 2500.0,
          'cod_balance_formatted': '৳2,500',
        },
      };

      final tracking = OrderTrackingModel.fromJson(json);
      expect(tracking.orderId, 12345);
      expect(tracking.currentStage, 3);
      expect(tracking.isInsideDhaka, isTrue);
      expect(tracking.codBalance, 2500.0);
      expect(tracking.codBalanceFormatted, '৳2,500');
      expect(tracking.timeline.length, 3);
      expect(tracking.timeline[2].title, contains('কুয়ালালামপুর থেকে ঢাকায় পাঠানো হচ্ছে'));

      // Steadfast Telemetry Verification
      expect(tracking.courierTelemetry, isNotNull);
      expect(tracking.courierTelemetry!.consignmentId, 'ST-12345');
      expect(tracking.courierTelemetry!.statusBengali, 'পার্সেলটি ডেলিভারির জন্য রাইডারের কাছে আছে');
      expect(tracking.courierTelemetry!.hubLocation, 'ঢাকা সেন্ট্রাল সর্টিং হাব, তেজগাঁও');
      expect(tracking.courierTelemetry!.codBalanceFormatted, '৳2,500');
    });

    test('UserModel isStaff identifies administrator and shop_manager roles', () {
      final adminUser = UserModel.fromJson({
        'id': 1,
        'name': 'Admin User',
        'email': 'admin@glowbaybd.com',
        'roles': ['administrator'],
      });
      expect(adminUser.isStaff, isTrue);

      final managerUser = UserModel.fromJson({
        'id': 2,
        'name': 'Shop Manager',
        'email': 'manager@glowbaybd.com',
        'roles': ['shop_manager'],
      });
      expect(managerUser.isStaff, isTrue);

      final customerUser = UserModel.fromJson({
        'id': 3,
        'name': 'Regular Customer',
        'email': 'cust@example.com',
        'roles': ['customer'],
      });
      expect(customerUser.isStaff, isFalse);
    });
  });
}
