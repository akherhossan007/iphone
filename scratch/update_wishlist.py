with open('lib/presentation/screens/subpages/wishlist_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Add import
if "import '../../../logic/language_provider.dart';" not in code:
    code = "import '../../../logic/language_provider.dart';\n" + code

# 2. Add isEn in build
old_build_start = """    final wishlist = context.watch<WishlistProvider>();
    final cart = context.read<CartProvider>();
    final items = wishlist.items;"""
new_build_start = """    final wishlist = context.watch<WishlistProvider>();
    final cart = context.read<CartProvider>();
    final isEn = context.watch<LanguageProvider>().isEnglish;
    final items = wishlist.items;"""
code = code.replace(old_build_start, new_build_start)

# 3. AppBar title
code = code.replace("'পছন্দের তালিকা (${items.length})'", "isEn ? 'My Wishlist (${items.length})' : 'পছন্দের তালিকা (${items.length})'")

# 4. Home tooltip
code = code.replace("tooltip: 'হোম পেজ'", "tooltip: isEn ? 'Home' : 'হোম পেজ'")

# 5. Clear dialog
code = code.replace("title: const Text('তালিকা খালি করতে চান?')", "title: Text(isEn ? 'Clear Wishlist?' : 'তালিকা খালি করতে চান?')")
code = code.replace("content: const Text('পছন্দের তালিকা থেকে সব পণ্য মুছে ফেলতে চান?')", "content: Text(isEn ? 'Are you sure you want to remove all items from your wishlist?' : 'পছন্দের তালিকা থেকে সব পণ্য মুছে ফেলতে চান?')")
code = code.replace("child: const Text('না')", "child: Text(isEn ? 'No' : 'না')")
code = code.replace("child: const Text('হ্যাঁ, মুছে ফেলুন', style: TextStyle(color: Colors.red))", "child: Text(isEn ? 'Yes, Clear' : 'হ্যাঁ, মুছে ফেলুন', style: const TextStyle(color: Colors.red))")
code = code.replace("child: const Text(\n                'সব মুছুন',", "child: Text(\n                isEn ? 'Clear All' : 'সব মুছুন',")

# 6. Pass isEn to _buildEmptyState
code = code.replace("_buildEmptyState(context)", "_buildEmptyState(context, isEn)")
code = code.replace("Widget _buildEmptyState(BuildContext context) {", "Widget _buildEmptyState(BuildContext context, bool isEn) {")
code = code.replace("'পছন্দের তালিকা ফাঁকা!'", "isEn ? 'Your Wishlist is Empty!' : 'পছন্দের তালিকা ফাঁকা!'")
code = code.replace("""            const Text(
              'আপনার পছন্দের পণ্যগুলোর ❤️ আইকনে ট্যাপ করে এখানে সেভ করে রাখুন, যাতে পরবর্তীতে সহজেই কিনতে পারেন।',""",
"""            Text(
              isEn ? 'Tap the ❤️ icon on products to save them here for easy shopping later.' : 'আপনার পছন্দের পণ্যগুলোর ❤️ আইকনে ট্যাপ করে এখানে সেভ করে রাখুন, যাতে পরবর্তীতে সহজেই কিনতে পারেন।',""")
code = code.replace("label: const Text('শপিং শুরু করুন')", "label: Text(isEn ? 'Start Shopping' : 'শপিং শুরু করুন')")

# 7. Pass isEn to _buildWishlistItem
code = code.replace("_buildWishlistItem(context, product, wishlist, cart)", "_buildWishlistItem(context, product, wishlist, cart, isEn)")
code = code.replace("""  Widget _buildWishlistItem(
    BuildContext context,
    ProductModel product,
    WishlistProvider wishlist,
    CartProvider cart,
  ) {""", """  Widget _buildWishlistItem(
    BuildContext context,
    ProductModel product,
    WishlistProvider wishlist,
    CartProvider cart,
    bool isEn,
  ) {""")

code = code.replace("""                      const SnackBar(
                        content: Text('পছন্দের তালিকা থেকে সরানো হয়েছে'),
                        duration: Duration(seconds: 2),
                      ),""", """                      SnackBar(
                        content: Text(isEn ? 'Removed from wishlist' : 'পছন্দের তালিকা থেকে সরানো হয়েছে'),
                        duration: const Duration(seconds: 2),
                      ),""")

code = code.replace("content: Text('${product.name} কার্টে যোগ হয়েছে!'),", "content: Text(isEn ? '${product.name} added to cart!' : '${product.name} কার্টে যোগ হয়েছে!'),")
code = code.replace("child: const Text('কার্টে নিন', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),", "child: Text(isEn ? 'Add to Cart' : 'কার্টে নিন', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),")

with open('lib/presentation/screens/subpages/wishlist_screen.dart', 'w', encoding='utf-8', newline='') as f:
    f.write(code)

print("Wishlist updated successfully")
