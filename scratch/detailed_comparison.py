import re

with open('scratch/header-mobile.php', 'r', encoding='utf-8', errors='ignore') as f:
    web_header = f.read()

with open('scratch/mobile_home.php', 'r', encoding='utf-8', errors='ignore') as f:
    web_home = f.read()

with open('lib/presentation/screens/main_nav_screen.dart', 'r', encoding='utf-8', errors='ignore') as f:
    app_nav = f.read()

with open('lib/presentation/screens/home/home_screen.dart', 'r', encoding='utf-8', errors='ignore') as f:
    app_home = f.read()

print("Files loaded successfully.")

# Analysis of Web Header:
# 1. Left side: Menu button (hamburger -> opens openMobDrawer)
# 2. Logo: img 'glowbay-official-logo.png' + title 'GlowBayBD' (with BD highlighted)
# 3. Right side:
#    - Language switcher (gb_render_language_switcher('mobile'))
#    - Wishlist icon (heart) with badge count
#    - Cart icon (bag) with badge count
# 4. Search bar:
#    - Capsule with search icon, input field, Mic button, Camera button
# 5. VIP Slide-Out Navigation Drawer:
#    - Drawer with user avatar, VIP Glow Member, Sign in button, links (Track Order, Affiliate Hub, Address Book, Settings, About Us, Policies, Help Center, WhatsApp VIP Support)

# Analysis of App Header (main_nav_screen.dart):
# 1. Logo: assets/images/logo_badge.png (round) + 'GlowBay' + 'MALL' badge (BE123C gradient)
# 2. Right side:
#    - Notification bell (icon)
#    - Cart icon (bag) with badge count
#    (Notice: NO hamburger menu drawer button! NO wishlist icon! NO language switcher button on top bar!)
# 3. Search bar:
#    - Capsule with rotating animated hint text, camera icon, mic icon
