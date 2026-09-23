import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/language_provider.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _faqCategories = [
    {
      'title': 'অর্ডার',
      'titleEn': 'Orders',
      'icon': Icons.shopping_bag_outlined,
      'items': [
        {
          'q': 'পণ্য কীভাবে অর্ডার করবো?',
          'qEn': 'How do I place an order?',
          'a': 'প্রোডাক্ট পেজ থেকে "অ্যাড টু কার্ট" করে কার্টে যান, তারপর চেকআউট সম্পন্ন করুন। চেকআউটে আপনার ডেলিভারি ঠিকানা ও পেমেন্ট পদ্ধতি বেছে নিন। অর্ডার কনফার্ম হলে আমরা আপনাকে ইমেইল ও SMS-এ নিশ্চিত করব।',
          'aEn': 'Add items to your cart from the product page, then proceed to checkout. Select your delivery address and payment method. You will receive an SMS and email once your order is confirmed.',
        },
        {
          'q': 'পণ্য কি মালয়েশিয়া থেকে আনা হয়?',
          'qEn': 'Are products directly imported from Malaysia?',
          'a': 'হ্যাঁ। GlowBayBD-এর পণ্য মালয়েশিয়ার অথোরাইজড রিটেইলার ও ব্র্যান্ড কাউন্টার থেকে সরাসরি সংগ্রহ করা হয় এবং বাংলাদেশে প্রি-অর্ডার সিস্টেমে পাঠানো হয়।',
          'aEn': 'Yes. All GlowBayBD products are directly sourced from authorized retailers and official brand counters in Malaysia and flown to Bangladesh.',
        },
        {
          'q': 'সব পণ্য কি অরিজিনাল?',
          'qEn': 'Are all products 100% authentic?',
          'a': 'অবশ্যই। GlowBayBD শুধু ১০০% অরিজিনাল ও অথেনটিক পণ্য সরবরাহ করে। কোনো রেপ্লিকা বা নকল পণ্য বিক্রি করা হয় না। অরিজিনাল না প্রমাণ করতে পারলে ১০০% মানিব্যাক রিফান্ড।',
          'aEn': 'Absolutely. GlowBayBD only delivers 100% authentic, brand-sealed products. No replicas or duplicates. Full 100% money-back guarantee.',
        },
        {
          'q': 'পণ্য কি রেডি স্টকে থাকে?',
          'qEn': 'Are products in ready stock?',
          'a': 'আমাদের বেশিরভাগ পণ্য প্রি-অর্ডার মডেলে থাকে — অর্থাৎ অর্ডারের পর সরাসরি কুয়ালালামপুর থেকে সোর্স করা হয়। এতে পণ্যের ফ্রেশনেস এবং দীর্ঘ মেয়াদ বজায় থাকে।',
          'aEn': 'Most items operate on our authentic pre-order model — sourced fresh directly from Kuala Lumpur after order confirmation to ensure maximum shelf life and product freshness.',
        },
      ],
    },
    {
      'title': 'পেমেন্ট',
      'titleEn': 'Payment',
      'icon': Icons.account_balance_wallet_outlined,
      'items': [
        {
          'q': 'কত টাকা অ্যাডভান্স দিতে হবে?',
          'qEn': 'How much advance payment is required?',
          'a': 'আন্তর্জাতিক প্রি-অর্ডার কনফার্মেশনের জন্য মোট অর্ডারের ৫০% অ্যাডভান্স (bKash / Nagad / Bank) দিতে হয়। বাকি ৫০% পেমেন্ট ডেলিভারির সময় ক্যাশ-অন-ডেলিভারি (COD) হিসেবে দেন।',
          'aEn': 'A 50% advance booking payment (bKash / Nagad / Bank transfer) is required to initiate international sourcing. The remaining 50% is paid via Cash on Delivery (COD).',
        },
        {
          'q': 'বাকি টাকা COD-তে দিতে পারবো?',
          'qEn': 'Can I pay the remaining balance via Cash on Delivery?',
          'a': 'হ্যাঁ, পার্সেলটি হাতে পাওয়ার সময় বাকি ৫০% মূল্য ক্যাশ অন ডেলিভারি (COD) হিসেবে ডেলিভারি রাইডারের কাছে দিতে পারবেন।',
          'aEn': 'Yes, you can pay the remaining 50% balance via Cash on Delivery (COD) to the courier rider upon parcel handover.',
        },
      ],
    },
    {
      'title': 'ডেলিভারি',
      'titleEn': 'Delivery',
      'icon': Icons.local_shipping_outlined,
      'items': [
        {
          'q': 'ডেলিভারি হতে কত দিন সময় লাগে?',
          'qEn': 'How long does delivery take?',
          'a': 'প্রি-অর্ডার কনফার্মেশন থেকে হাতে পৌঁছানো পর্যন্ত মোট ১০–২৫ দিন (মালয়েশিয়া সোর্সিং ও ডেলিভারি)। ঢাকায় পার্সেল পৌঁছানোর পর: ঢাকায় ২৪–৪৮ ঘণ্টা এবং ঢাকার বাইরে ৩–৫ দিনে বিশ্বস্ত কুরিয়ারে হোম ডেলিভারি হয়।',
          'aEn': 'Total 10–25 days from confirmation to doorstep delivery (Malaysia sourcing & air shipping). Once inside Bangladesh: 24–48 hours in Dhaka and 3–5 days outside Dhaka via express courier.',
        },
        {
          'q': 'অর্ডার কীভাবে ট্র্যাক করবো?',
          'qEn': 'How can I track my order?',
          'a': 'আমাদের Track Order পেজে গিয়ে আপনার অর্ডার আইডি অথবা মোবাইল নাম্বার দিয়ে সরাসরি পার্সেল ও কুরিয়ার লোকেশন ট্র্যাক করতে পারবেন।',
          'aEn': 'Visit our Track Order page and enter your Order ID or phone number to view live progress from Kuala Lumpur sourcing to doorstep dispatch.',
        },
        {
          'q': 'প্যাকেজ ড্যামেজড দেখলে কি করবো?',
          'qEn': 'What should I do if the parcel is damaged?',
          'a': 'ডেলিভারির সময় পার্সেল ড্যামেজড বা ভাঙা দেখলে সাথে সাথে ডেলিভারি ম্যানের সামনে ছবি/ভিডিও রাখুন এবং আমাদের WhatsApp (+601125044155)-এ জানান।',
          'aEn': 'If the parcel appears damaged upon delivery, immediately take photos or videos in front of the courier rider and contact our WhatsApp (+601125044155).',
        },
      ],
    },
    {
      'title': 'বাতিল নীতি',
      'titleEn': 'Cancellation',
      'icon': Icons.cancel_outlined,
      'items': [
        {
          'q': 'পণ্য সোর্স করার আগে বাতিল করলে?',
          'qEn': 'Cancellation before procurement?',
          'a': 'মালয়েশিয়া টিম প্রডাক্ট পারচেজ করার আগে অর্ডার বাতিল করলে ১০০% পূর্ণ রিফান্ড প্রযোজ্য — কোনো চার্জ কাটা হবে না।',
          'aEn': 'If cancelled before our Malaysia team purchases the items from official outlets, you receive a 100% full refund with zero fees.',
        },
        {
          'q': 'GlowBayBD সোর্স করার পর বাতিল করলে?',
          'qEn': 'Cancellation after procurement?',
          'a': 'সোর্সিং সম্পন্ন হওয়ার পর বাতিল করলে প্রশাসনিক ও সোর্সিং প্রসেসিং চার্জ বাবদ ১৫% ফি কর্তনযোগ্য।',
          'aEn': 'If cancelled after items have already been purchased and processed in Kuala Lumpur, a 15% restocking/sourcing handling fee applies.',
        },
        {
          'q': 'শিপমেন্ট ডিসপ্যাচ হওয়ার পর বাতিল করা যাবে?',
          'qEn': 'Can an order be cancelled after courier dispatch?',
          'a': 'কুরিয়ার ডিসপ্যাচ হওয়ার পর অর্ডার বাতিল সুবিধা নেই — তখন শুধুমাত্র রিটার্ন নীতি প্রযোজ্য।',
          'aEn': 'Orders cannot be cancelled once dispatched with the courier — standard return policy applies.',
        },
      ],
    },
    {
      'title': 'রিটার্ন ও রিফান্ড',
      'titleEn': 'Return & Refund',
      'icon': Icons.replay_outlined,
      'items': [
        {
          'q': 'খোলা বা ব্যবহৃত কসমেটিকস রিটার্ন নেওয়া হয়?',
          'qEn': 'Can opened or used skincare be returned?',
          'a': 'না — স্বাস্থ্যবিধি ও আন্তর্জাতিক হাইজিন নিয়মের কারণে খোলা বা ব্যবহৃত কসমেটিকস রিটার্ন/রিফান্ড হয় না।',
          'aEn': 'No — due to health, hygiene, and international cosmetic safety regulations, opened or tested skincare products cannot be returned.',
        },
        {
          'q': 'অক্ষত/সিল-ইনট্যাক্ট পণ্য রিটার্ন করলে?',
          'qEn': 'Can unopened intact-seal products be returned?',
          'a': 'পণ্য সম্পূর্ণ অক্ষত ও সিল ইনট্যাক্ট থাকলে রিটার্ন গ্রহণযোগ্য, তবে প্রসেসিং ও ওপেনিং চার্জ বাবদ ১৫% কাটা হবে এবং রিটার্ন শিপিং কাস্টমার বহন করবে।',
          'aEn': 'If the product seal is completely intact and undamaged, returns are eligible within 3 days. Customer covers return shipping.',
        },
        {
          'q': 'ভুল বা ড্যামেজড পণ্য এলে?',
          'qEn': 'What if the wrong or damaged item arrives?',
          'a': '১০০% পূর্ণ রিফান্ড প্রযোজ্য। এটি GlowBayBD-এর দায়িত্ব, তাই কোনো চার্জ কাটা হবে না এবং রিটার্ন শিপিং খরচ GlowBayBD বহন করবে।',
          'aEn': '100% full refund applies immediately. GlowBayBD covers all return shipping and handling costs.',
        },
        {
          'q': 'এক্সচেঞ্জ (বদল) সুবিধা আছে কি?',
          'qEn': 'Is product exchange available?',
          'a': 'না, বর্তমানে সরাসরি এক্সচেঞ্জ সুবিধা নেই। ভুল/ড্যামেজড পণ্যে রিফান্ড প্রসেস করা হয়; অন্য পণ্য নিতে চাইলে নতুন অর্ডার করতে হবে।',
          'aEn': 'We do not offer direct item swaps. Valid claims are refunded in full, and you can place a fresh order for your desired item.',
        },
        {
          'q': 'রিফান্ড পেতে কত দিন লাগে?',
          'qEn': 'How long does a refund take?',
          'a': 'রিটার্ন পার্সেল রিসিভ ও কোয়ালিটি চেকের পর ৩–৭ কার্যদিবসের মধ্যে আপনার বিকাশ/নগদ/ব্যাংক অ্যাকাউন্টে টাকা রিফান্ড হয়।',
          'aEn': 'After returning the parcel and passing quality inspection, refunds are processed to your bKash/Nagad/Bank within 3–7 business days.',
        },
      ],
    },
    {
      'title': 'অরিজিনালিটি',
      'titleEn': 'Authenticity',
      'icon': Icons.verified_outlined,
      'items': [
        {
          'q': 'কীভাবে বুঝবো পণ্য অরিজিনাল?',
          'qEn': 'How do I verify product authenticity?',
          'a': 'আমরা শুধুমাত্র মালয়েশিয়ার অফিশিয়াল ব্র্যান্ড স্টোর ও অথোরাইজড ফার্মেসি (Watson, Guardian, Sephora) থেকে সোর্স করি। পণ্যের ব্যাচ কোড দিয়ে CheckFresh-এ চেক করতে পারেন।',
          'aEn': 'We only source from official Malaysian brand stores and certified pharmacies (Watsons, Guardian, Sephora). You can verify batch numbers on CheckFresh.',
        },
        {
          'q': 'প্যাকেজিং আগের থেকে আলাদা মনে হলে?',
          'qEn': 'What if the packaging looks slightly different?',
          'a': 'ব্র্যান্ডগুলো নির্দিষ্ট সময় পরপর তাদের প্যাকেজিং ও ডিজাইন আপডেট করে। প্যাকেজিং আপডেট হলেই তা ভুয়া নয় — অফিশিয়াল ব্র্যান্ড ওয়েবসাইটের বর্তমান প্যাকেজিংয়ের সাথে মিলিয়ে দেখার অনুরোধ রইলো।',
          'aEn': 'Global brands frequently refresh packaging and formulas. Packaging variations usually indicate a newer manufacturer batch.',
        },
      ],
    },
    {
      'title': 'সাপোর্ট ঘণ্টা',
      'titleEn': 'Support Hours',
      'icon': Icons.support_agent_outlined,
      'items': [
        {
          'q': 'কাস্টমার সাপোর্ট সময়সূচী কত?',
          'qEn': 'What are your support operating hours?',
          'a': 'আমাদের হেল্পডেস্ক বাংলাদেশ সময় প্রতিদিন সকাল ৮:০০টা থেকে রাত ৮:০০টা পর্যন্ত সক্রিয় থাকে। WhatsApp: +601125044155.',
          'aEn': 'Our customer support desk is active daily from 8:00 AM to 8:00 PM BST. WhatsApp: +601125044155.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isEn = context.watch<LanguageProvider>().isEnglish;
    final currentCat = _faqCategories[_selectedCategoryIndex];
    final List items = currentCat['items'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          isEn ? 'FAQ — Frequently Asked Questions' : 'FAQ — সচরাচর জিজ্ঞাসা',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        actions: [
          IconButton(
            tooltip: isEn ? 'Home' : 'হোম পেজ',
            icon: const Icon(Icons.home_outlined, size: 22),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector Horizontal Strip
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemCount: _faqCategories.length,
              itemBuilder: (context, i) {
                final isSelected = _selectedCategoryIndex == i;
                final catTitle = isEn
                    ? (_faqCategories[i]['titleEn'] ?? _faqCategories[i]['title'])
                    : _faqCategories[i]['title'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      _faqCategories[i]['icon'],
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    label: Text(
                      catTitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategoryIndex = i);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // FAQ Accordion List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final item = items[idx];
                final question = isEn ? (item['qEn'] ?? item['q']) : item['q'];
                final answer = isEn ? (item['aEn'] ?? item['a']) : item['a'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accentPink.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.help_outline, color: AppColors.accentPink, size: 16),
                      ),
                      title: Text(
                        question,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: Text(
                            answer,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
