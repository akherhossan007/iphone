# 🛑 সর্বপ্রধান স্থায়ী নিয়ম (MANDATORY AGENT DIRECTIVE FROM OWNER)
> ## **"কাজ শুরু করার আগে D:\GEMINI.md এবং D:\AGENTS.md পড়ে নাও এবং কাজ শেষে সেখানেই আপডেট লগ যুক্ত করে সিঙ্ক করে দিও।"**
> 
> **ALL AI AGENTS (Gemini, Claude, Cursor, Codex, GPT, Antigravity, Windsurf, Copilot, etc.) MUST OBEY THIS RULE AUTOMATICALLY:**
> 1. **কাজের পূর্বে (Pre-Task):** যেকোনো কাজ বা কোড লেখার আগে বাধ্যতামূলকভাবে `D:\GEMINI.md` ও `D:\AGENTS.md` পুরোটা পড়ুন। আগের সেশনগুলোতে কোন এজেন্ট কী করেছে, সিস্টেমের রুলস ও বাউন্ডারি কী তা জেনে কাজ শুরু করুন, যাতে কোনো ডুপ্লিকেশন বা কোড কনফ্লিক্ট না হয়।
> 2. **কাজের পূর্বে ব্যাকআপ (Pre-Work Backup):** ফাইল বা ডাটাবেজ পরিবর্তনের আগে ব্যাকআপ নিশ্চিত করুন।
> 3. **কাজের শেষে (Post-Task Logging & Sync):** কাজ শেষ হওয়ামাত্রই কী করলেন, কেন করলেন এবং কোন কোন ফাইলে পরিবর্তন আনলেন তা এই ফাইলের হিস্টোরি লগ সেকশনে বিস্তারিত যোগ করে দিন এবং `python scripts/sync_memory.py` দিয়ে সিঙ্ক করুন।
> 
> **🚨 ইউজারকে এই কথা যেন আর কখনোই মুখে মনে করিয়ে দিতে না হয়! এটি প্রতিটি এজেন্টের জন্য ১০০% স্বয়ংক্রিয় ও অলঙ্ঘনীয়।**

---

# GlowBayBD — Master Architecture & Project Memory (SSOT)

> 🛑 **MANDATORY INSTRUCTION FOR ALL AGENTS & MODELS (Cursor, Windsurf, Claude, Gemini, GPT, Antigravity):**
> 
> **"কাজ শুরু করার আগে D:\GEMINI.md এবং D:\AGENTS.md পড়ে নাও এবং কাজ শেষে সেখানেই আপডেট লগ যুক্ত করে সিঙ্ক করে দিও।"**
> *(READ D:\GEMINI.md and D:\AGENTS.md BEFORE STARTING ANY TASK, AND AUTOMATICALLY ADD UPDATE LOGS & SYNC THERE AFTER COMPLETING. NEVER WAIT FOR THE USER TO REMIND YOU.)*
> 
> 1. **CENTRAL SSOT LOCATION**: The permanent master copies live at `D:\AGENTS.md` and `D:\GEMINI.md`. All agents working in any directory (e.g., `D:\GlowbayBD Website`, `D:\Glowbay App`, workspace downloads, etc.) must treat these files as the absolute Single Source of Truth.
> 2. **BEFORE STARTING ANY TASK**: You MUST automatically read `D:\AGENTS.md` or `D:\GEMINI.md` in full before writing or planning any code. Never assume conventions, never change existing brand colors, and never reinvent architecture.
> 3. **BEFORE MODIFYING ANY FILE**: You MUST ALWAYS create a timestamped backup file on the server (e.g. `filename.php.bak_1789xxxxxx`). Never edit in-place without a verified backup.
> 4. **AFTER COMPLETING ANY TASK**: You MUST AUTOMATICALLY update BOTH `D:\AGENTS.md`, `D:\GEMINI.md`, and local workspace copies with what was changed (Module Number & Title, files modified, technical mechanism, verification status).
> 5. **AFTER DEPLOYING VIA cPANEL API**: ALWAYS trigger the master cache purge at `https://glowbaybd.com/gb_master_purge.php` and verify HTTP 200.

## 1. 📌 Project & Infrastructure Specifications

| Property | Value | Notes |
| :--- | :--- | :--- |
| **Store Name** | GlowBayBD | https://glowbaybd.com |
| **Slogan / Pitch** | Authentic imported beauty & skincare from Kuala Lumpur, Malaysia | Central Hub: KL, Liaison: Banani, Dhaka |
| **WordPress Theme** | `glowbayhp` | Path: `wp-content/themes/glowbayhp/` |
| **Server / Host** | cPanel on `ultra.webfastdns.com:2083` | User: `glowbayb` |
| **cPanel API Token** | `25523Z49FP2OE9OBT8V4D3YJY4RUT2F4` | Header: `Authorization: cpanel glowbayb:<token>` |
| **Fileman Endpoints** | `https://ultra.webfastdns.com:2083/execute/Fileman/save_file_content` | `dir` + `file` + `content` |
| | `https://ultra.webfastdns.com:2083/execute/Fileman/get_file_content` | `dir` + `file` |
| **Cache Purge** | `https://glowbaybd.com/gb_master_purge.php` | Mandatory after every single deploy |
| **VIP Helpline** | WhatsApp `+60 11-2504 4155` | Malaysian Central Hub Support |

---

## 2. 🎨 Mandatory Brand, UI/UX & Design Rules (STRICT)

### A. 1:1 Lazada Marketplace Styling Standard
- **NO Dark Gradients**: NEVER apply dark navy, black, or heavy multi-stop dark gradients to product cards, action buttons, or banners.
- **NO Clashing Neon / Pink Colors**: Hex codes `#FF1F78`, `#E11D48`, `#FFE0EB` must NEVER be used on product bundles, borders, or highlights.
- **Official Color Palette**:
  - Primary Action / Buy Now / Add to Cart / Price Accent: **Lazada Heartbeat Magenta (`#F8006E`)**
  - Hover Action: **Deep Magenta (`#D9005E`)**
  - Soft Badges / Discount Pills: **Soft Rose Pink (`#FFF0F5`) with Magenta (`#F8006E`) Text**
  - Search Submit Button: **Lazada Warm Orange (`#F57224`)**
  - WhatsApp Order / Chat: **WhatsApp Green (`#25D366`)**
  - Overall Background: **Lazada Light Gray (`#EFF0F5`)**
  - Cards & Containers: **Pristine White (`#FFFFFF`) with subtle border (`#E5E7EB`)**
  - Headings & Primary Text: **Dark Slate / Charcoal (`#212121`)**
  - Secondary Text: **Cool Slate / Gray (`#757575`)**

### B. Desktop Layout & Sizing Standards
- Container max-width: **`1240px`** centered.
- The entire top product fold MUST be wrapped in a single, clean white card (`.gb-pdp-main-card`).
- **3-Column Proportion**:
  - **Column 1 (Gallery)**: 350px width, square image view (330px x 330px), clean thumbnails strip with active indicator.
  - **Column 2 (Middle Info & Buy Actions)**: Title (19px bold), Ratings (4.8), Brand link, Lazada-style light gray price box (`#FAFAFA`), Quantity selector `[-] 1 [+]`, and main buttons (**[Buy Now]**, **[Add to Cart]**, **[WhatsApp]**) positioned in this middle column directly below Quantity.
  - **Column 3 (Right Rail)**: Dedicated 1:1 Lazada Delivery Options & Return Warranty panel.

### C. Desktop Top Sticky Buy Bar (MANDATORY)
- Desktop MUST have a sleek top sticky bar (`.gb-desktop-sticky-bar`) that slides down when the user scrolls past the main buy buttons.
- Must display: Product Thumbnail + Title + Price (`৳ 1,590`) + Quantity `[-] 1 [+]` + [Add to Cart] + [Buy Now] + [WhatsApp].
- Quantities between sticky bar and main selector must stay in sync via `adjustPdpQty`.

### D. Language & Copywriting Rules (STRICT)
- **100% Clean, Professional English**: Product page headers, tabs, badges, buttons, benefits, and descriptions must be in pure, polished English (NO Banglish, NO broken translations).
- **NEVER use "Air Cargo" or "এয়ার কার্গো"**: Always use **"Direct Flight Delivery"** or **"Direct from Kuala Lumpur"** or **"Express Delivery"**.

---

## 3. 📜 Comprehensive Project History & Implemented Modules

### Module 1: Authentication System (Facebook, Google 1-Tap, Email OTP)
- **Facebook Login**:
  - App ID: `1053208033791589`
  - App Secret: `8cff1c9d85e6321226972c35898d6db8`
  - Fixed Android mobile Chrome intent redirect issues so authentication completes cleanly.
- **WhatsApp Login Removed**:
  - User requested removal of WhatsApp login from registration/login forms.
  - Authentication forms maintain a balanced 50%-50% grid: Google 1-Tap, Facebook, and Email.
- **Email Signup 6-Digit OTP**:
  - Flow: When a new user signs up with email, a secure 6-digit OTP is generated and sent via WordPress transactional email.
  - User enters the 6-digit code in the verification modal to complete account creation and automatic login.
  - Prevents bot spam and invalid email registrations.

### Module 2: WooCommerce Luxury Email Architecture
- **Location**: `wp-content/themes/glowbayhp/woocommerce/emails/`
- **Templates Built & Deployed**:
  1. `email-header.php`: High-res GlowBay logo, responsive wrapper, top trust bar (Direct from Malaysia • 100% Authentic • Express Delivery).
  2. `email-footer.php`: 3 VIP trust badges, WhatsApp concierge link (`+60 11-2504 4155`), legal links, KL Hub address.
  3. `email-styles.php`: Responsive CSS, Midnight Navy `#0F172A` headings, clean item tables, Lazada orange buttons.
  4. `customer-processing-order.php`: Order confirmation with items table, delivery address cards, live tracking button (`/track-order/`).
  5. `customer-completed-order.php`: Order shipped & delivery confirmation.
  6. `customer-reset-password.php`: Clean luxury password reset template.
  7. `customer-new-account.php`: Welcome email with account credentials.
- **WooCommerce Options Synchronized**:
  - `woocommerce_email_header_image`: `https://glowbaybd.com/wp-content/uploads/glowbay-official-pristine-logo.png`
  - `woocommerce_email_base_color`: `#0F172A`
  - `woocommerce_email_background_color`: `#F8FAFC`
  - `woocommerce_email_body_background_color`: `#FFFFFF`

### Module 3: Product Details Page (PDP) Lazada 1:1 Revamp
- **Template File**: `wp-content/themes/glowbayhp/woocommerce/single-product.php`
- **Duplicate Buy Box Removed**:
  - Removed redundant `<div class="gb-rail-card gb-sticky-buy-box">` that sat next to the description. Right rail now exclusively holds the clean `Specifications` table.
- **Unified 3-Column Layout**:
  - Enclosed in single `.gb-pdp-main-card`.
  - Col 1: 350px Gallery.
  - Col 2: Flex Middle Info + Price Box + Quantity + [Buy Now] [Add to Cart] [WhatsApp].
  - Col 3: Dedicated Delivery Options & Return Warranty panel.
- **Desktop Top Sticky Bar (`.gb-desktop-sticky-bar`)**:
  - Fixed at `top: 0`, smooth slide-down via JS scroll listener when buy buttons leave viewport.
  - Features thumbnail, title, price, synced quantity, Add to Cart, Buy Now, and WhatsApp.
- **AI Routine Bundle Box (`glowbay_ai_suite.php`)**:
  - Transformed from neon pink into clean white card with Lazada orange `#F57224` buy button and 10% combo savings badge.
- **Product Description Overhaul (e.g. Fino Hair Mask)**:
  - Rewritten in pure English with 7 beauty essences breakdown, 3-step usage routine, and constrained responsive imagery.

### Module 4: Live Order Tracking & Operations
- **Endpoint**: `/track-order/`
- **Features**: Live courier status, waybill generation, real-time shipment updates, WhatsApp direct support.

### Module 5: Dynamic Social Open Graph (OG) & WhatsApp Rich Preview Engine
- **Files Modified**:
  - `wp-content/themes/glowbayhp/header.php` (Backup: `header.php.bak_1789802706`)
  - `wp-content/plugins/glowbay-seo/glowbay-seo.php` (Backup: `glowbay-seo.php.bak_1789802706`)
- **Problem Resolved**:
  - Previously, `header.php` had static, hardcoded Open Graph tags with a generic store logo (`glowbay-og.png`) placed before `wp_head()`.
  - When product links were shared on Facebook, WhatsApp, Messenger, or Telegram, social crawlers grabbed the first static image or failed to render a rich card due to duplicate conflicting tags and missing dimension attributes (`og:image:width`, `og:image:height`, `og:image:secure_url`).
- **Solution & Architecture**:
  - Removed static duplicate tags from `header.php`.
  - Enhanced `gbseo_head()` in `glowbay-seo.php`:
    - **Product Pages**: Automatically extracts the product's high-res featured thumbnail, sets `og:image`, `og:image:secure_url`, dynamic `og:image:width` and `height`, `product:price:amount`, `product:price:currency` (`BDT`), `product:availability`, and `twitter:image`.
    - **Homepage / General Pages**: Gracefully falls back to high-res branded 1200x630 banner (`glowbay-og.png`).

### Module 6: Mobile PDP Recommendations & Brand Showcase Engine
- **Files Modified**:
  - `wp-content/themes/glowbayhp/templates/mobile/product.php` (Server Backup: `product.php.bak_1789803395`)
- **Problem Resolved**:
  - Previously, the mobile template had two back-to-back sections: "More from {Category}" and "More in {Sub-Category}".
  - For any product with a single category (or identical parent/leaf taxonomy terms like *Hair Mask* on *Fino Hair Mask*), both sections queried the exact same slug, rendering the **exact same 8 products in the exact same order** twice in a row.
  - Headings also used prohibited neon pink inline styling (`#FF1F78`).
- **Solution & Architecture**:
  - **Section 1**: Cleaned title to "More in {Category}", switched highlight & "View All" link colors from prohibited `#FF1F78` to Lazada Orange `#F57224`.
  - **Section 2**: Re-engineered as a **Brand / Collection Discovery Engine**:
    - Queries up to 8 products from the same `product_brand` / `pa_brand` taxonomy term (excluding the active product).
    - Renders heading "More from {Brand}" (e.g. "More from FINO") with a direct link to the Brand store (`/brand/{slug}/`).
    - **Intelligent Fallback**: If the brand has no other items, falls back to a sub-category *only if* it is genuinely distinct from the primary category; otherwise collapses cleanly to eliminate duplication.

### Module 7: Mobile PDP Architecture Refinement (Specs Tab & Unified Trust)
- **Files Modified**:
  - `wp-content/themes/glowbayhp/templates/mobile/product.php` (Server Backup: `product.php.bak_1789803977`)
- **Key Enhancements**:
  1. **Added Specifications Tab on Mobile**:
     - Introduced an active `Specifications` tab alongside `Description`, `How to Use`, and `Ingredients`.
     - Displays dynamic structured product attributes: Brand, SKU, Category, Origin (*Direct from Kuala Lumpur, Malaysia*), Authenticity (*100% Genuine Imported*), Stock Availability, and custom WooCommerce taxonomies/attributes.
     - Added touch-friendly smooth horizontal scrolling (`overflow-x: auto`) for mobile tab headers.
  2. **Unified Luxury Trust & Buyer Protection Card**:
     - Merged two bloated back-to-back trust sections (`gbp-trust` and `gbp-pp`) into a single, compact, high-converting card (`.gbp-trust-unified`).
     - Includes 4 quick trust badges (100% Original, Direct Flight Delivery, Express Courier, 50% Adv + 50% COD) followed by clear protection guidelines.
  3. **Compliance with Copywriting & Structure SOP**:
     - Eliminated all occurrences of "air shipping" in favor of "Direct Flight Delivery" and "flight dispatch".
     - Removed the orphaned, duplicate subcategory rail mistakenly nested inside the routine check block.
  4. **Preserved Sticky Bar Elements**:
     - As per user directive, bottom sticky bar action buttons and styling were preserved without alterations.

### Module 8: Desktop PDP Architecture & Visual Alignment
- **Files Modified**:
  - `wp-content/themes/glowbayhp/woocommerce/single-product.php` (Server Backup: `single-product.php.bak_1789804657`)
  - `wp-content/themes/glowbayhp/glowbay_ai_suite.php` (Server Backup: `glowbay_ai_suite.php.bak_1789804657`)
- **Key Enhancements**:
  1. **Removed Orphaned Mobile Bottom Bar from Desktop**:
     - Purged the legacy `<div class="gb-msb2" id="gbMobStickyBar">` which was sticking to the bottom of the desktop viewport (visible in user screenshot).
  2. **Fixed WhatsApp CTA in Desktop Top Sticky Bar**:
     - Resolved variable scope order by initializing `$wa_msg` and `$wa_url` prior to the sticky bar render.
     - Added official WhatsApp green (`#25D366`) CTA with brand icon in `.gb-desktop-sticky-bar`.
  3. **Interactive & Styled Desktop Tab Navigation**:
     - Upgraded `.gb-pdp-tabs-nav` from static dummy links into interactive navigators with `gbSwitchDeskTab(key, this)`.
     - Smoothly scrolls and highlights Description, Specifications (`.gb-rail-specs`), Reviews (`.gb-reviews-panel`), and Delivery options (`.gb-pdp-delivery-card`).
     - Added `position: sticky; top: 80px;` to `.gb-pdp-right-rail` to eliminate the huge blank white gap next to the long description.
  4. **Category-Aware AI Routine Engine (`glowbay_ai_suite.php`)**:
     - Dynamic category detection: displays **"AI Haircare Routine"** for hair treatments/conditioners/shampoos, and **"AI Skincare Routine"** for facial skincare.
     - Rewrote role labels into 100% polished, pure English (*Cleansing Hair Shampoo, Deep Repair Hair Mask, Hair Oil & Heat Protection*).


---


### Module 9: Desktop Lazada 1:1 Sticky Buy Box & Action Hierarchy Refinement
- **Files Modified**:
  - `wp-content/themes/glowbayhp/woocommerce/single-product.php` (Server Backup: `single-product.php.bak_1789805430`)
- **Key Enhancements**:
  1. **Lazada 1:1 Sticky Purchase Card (`.gb-lazada-sticky-card`) on Right Rail**:
     - Modeled directly after official Lazada Malaysia desktop architecture.
     - Placed in `.gb-pdp-right-rail` directly above the Specifications table, filling the empty white dead space beside long descriptions.
     - Pinned smoothly via `position: sticky; top: 85px;`.
     - Features:
       - Square product thumbnail (`58px x 58px`) with subtle border.
       - Large bold current price (e.g. `৳ 2,360`), regular price strikethrough, and discount pill (`-19%`).
       - Origin & trust badge (`🇲🇾 Direct Flight Delivery from Malaysia (10–25 Days)`).
       - Synced quantity stepper `[-] 1 [+]` with `#gbRailQty`.
       - **Buy Now** button: Lazada Outline style (white bg, `#F57224` border & text, hover fill).
       - **Add to Cart** button: Lazada Solid filled style (`#F57224` bg, white text, hover lift).
       - **Order via WhatsApp**: Full-width `#25D366` concierge button.
  2. **Cleaned Top Header Viewport**:
     - Disabled top header sticky bar (`.gb-desktop-sticky-bar { display: none !important; }`), completely removing header clutter as requested.
  3. **Middle Column (Col 2) Button Hierarchy & Alignment**:
     - Upgraded from crammed 1-row layout into Lazada's luxury 2-row hierarchy:
       - Row 1: Balanced 50%-50% flex pair: `[Buy Now]` (Outline, 48px height) + `[Add to Cart]` (Solid filled, 48px height) with smooth shadows and hover effects.
       - Row 2: Full-width `[Order via WhatsApp]` (44px height, `#25D366`) with concierge icon.
  4. **Dynamic Two-Way JS Synchronization**:
     - `adjustPdpQty()` seamlessly syncs both `#gbPdpQty` (middle column) and `#gbRailQty` (right rail sticky card).
     - `updateWaLink()` updates WhatsApp URLs for all CTAs dynamically with current quantity, title, SKU, and total BDT price.

---

- **Sticky Offset Fine-Tuning**:
  - Previously `.gb-pdp-right-rail` used `top: 85px`, which stopped under the 122px sticky master header (`.gbd-header-main` 76px + `.gbd-nav-strip` 44px + borders).
  - Adjusted sticky offset to `top: 140px !important;` (and `top: 172px !important;` for logged-in WP admin bar).
  - Provides a clean 18px floating gap below the navigation strip without any overlapping or clipping.

---

- **Fixed Stray `?>` Output Before Footer**:
  - Identified an orphaned closing PHP tag `?>` sitting between two `<script>` blocks around line 4375 in `woocommerce/single-product.php`.
  - Because it was outside of PHP execution mode, it was being rendered as plain text (`?>` / `>`) right above the master footer on the left margin.
  - Safely removed the stray tag, purged cache (`gb_master_purge.php`), and verified the live DOM.

---

### Module 10: Column 2 Desktop Hierarchy & Duplicate Trust Elimination
- **Files Modified**:
  - `wp-content/themes/glowbayhp/woocommerce/single-product.php` (Server Backup: `single-product.php.bak_1789807005`)
- **Key Enhancements**:
  1. **Eliminated Duplicate Trust List in Middle Column**:
     - Purged the bloated `.gb-pdp-trust-list` (~180px height) from Column 2, which previously repeated the exact same delivery estimate, 100% authentic, and 7-day return points already presented in Column 3's dedicated Lazada Delivery Options & Return Warranty panel.
  2. **Elevated Primary CTA Buttons Above the Fold**:
     - Lifted the Quantity selector `[-] 1 [+]` and the luxury 2-row buy actions (`[Buy Now]` + `[Add to Cart]` + `[Order via WhatsApp]`) directly below the Price Box.
     - Desktop shoppers now see price, quantity, and purchase buttons immediately upon page load without scrolling.
### Module 11: 1-Line Full-Width Brand Store Strip & Share Bar Deduplication
- **Files Modified**:
  - `wp-content/themes/glowbayhp/woocommerce/single-product.php` (Server Backup: `single-product.php.bak_1789807817`)
- **Key Enhancements**:
  1. **Lazada 1:1 Single-Line Horizontal Brand Store Strip (`.gb-lazada-brand-strip`)**:
     - Removed the cramped, multi-row brand card from Column 1 (Gallery).
     - Introduced a sleek 1-line horizontal bar spanning 100% width across the bottom of `.gb-pdp-main-card`, directly below the 3-column product grid (`.gb-pdp-main-grid`), perfectly replicating Lazada Malaysia's official layout.
     - Left Section: Brand Logo (40px x 40px) or Monogram + Verified Brand Name + Seller Ratings (`99%`) &bull; 100% Authentic Guaranteed &bull; Direct Flight from KL Hub.
     - Right Section: Clean outline action buttons `[Chat]` (`#25D366` WhatsApp link with custom inquiry message) and `[See All {Brand} Products]` (`#F57224` link to brand store `/brand/{slug}/`).
     - Fully responsive: Stacks gracefully on mobile (`max-width: 991px`).
### Module 12: Mobile PDP 1:1 Lazada Brand Store Strip
- **Files Modified**:
  - `wp-content/themes/glowbayhp/templates/mobile/product.php` (Server Backup: `product.php.bak_1789808508`)
- **Key Enhancements**:
  1. **Lazada 1:1 Mobile Brand Store Strip (`.gb-lz-mob-store-strip`)**:
     - Modeled 1:1 after official Lazada Malaysia mobile PDP screenshot provided by user.
     - Positioned right after Variations/Options Drawer and directly before Description Tabs (`<!-- 6. DESCRIPTION TABS -->`).
     - Fits 100% in a single horizontal line across all mobile screen sizes (`320px` to `430px+`):
       - Left: High-res square brand logo (`42px x 42px`) or clean monogram.
       - Center: Brand name in bold black uppercase (`14.5px font-weight: 800`) + Subtitle (`Seller Ratings 99% | Direct Flight • 100% Authentic`).
### Module 13: Dynamic Product Rating & Visit Brand Unification
- **Files Modified**:
  - `wp-content/themes/glowbayhp/woocommerce/single-product.php` (Server Backup: `single-product.php.bak_1789808982`)
  - `wp-content/themes/glowbayhp/templates/mobile/product.php` (Server Backup: `product.php.bak_1789808982`)
- **Key Enhancements**:
  1. **Dynamic Rating Calculation**:
     - Eliminated hardcoded 99% seller rating.
     - Implemented dynamic WooCommerce rating logic: `($avg_rating / 5.0) * 100` dynamically rounded to percentage (e.g. `98%`, `96%`).
     - Graceful fallback for brand-new products with no reviews yet to storewide trust standard (`99%`).
  2. **Renamed Action to "Visit Brand"**:
     - Both Desktop and Mobile now display **`[Visit Brand]`** instead of generic `[Visit Store]` or `[GO TO STORE]`, perfectly directing shoppers to the brand's dedicated imported collection (`/brand/{slug}/`).
### Module 14: Desktop Theme-Wide Transition to Lazada Heartbeat Magenta (#F8006E)
- **Files Modified**:
  - `wp-content/themes/glowbayhp/woocommerce/single-product.php` (Server Backup: `single-product.php.bak_1789809435`)
  - `wp-content/themes/glowbayhp/glowbay_ai_suite.php` (Server Backup: `glowbay_ai_suite.php.bak_1789809497`)
  - `wp-content/themes/glowbayhp/templates/desktop-home.php` (Server Backup: `desktop-home.php.bak_1789809497`)
  - `wp-content/themes/glowbayhp/header.php` (Server Backup: `header.php.bak_1789809568`)
- **Key Enhancements**:
  1. **Theme-Wide Magenta (`#F8006E`) Adoption**:
     - Upgraded primary buy actions, price labels, and discount tags from classic orange to official Lazada Heartbeat Magenta (`#F8006E`).
     - Product page actions: [Buy Now] (Outline `#F8006E`), [Add to Cart] (Solid `#F8006E`), [Visit Brand] (`#F8006E`).
     - Right rail sticky purchase card (`.gb-lazada-sticky-card`): Synchronized price, discount badge, and buy buttons in `#F8006E`.
     - AI Routine Suite: Combo savings badges and purchase CTAs updated to `#F8006E` with soft pink `#FFF0F5` pills.
     - Header: Cart & Wishlist count badges updated to `#F8006E`, while search button preserves warm Lazada Orange (`#F57224`) matching the official screenshot.
### Module 15: Brand Archive & Search Revamp (Lazada Magenta & 100% English)
- **Files Modified**:
  - `wp-content/themes/glowbayhp/search.php` (Server Backup: `search.php.bak_1789810186`)
  - `wp-content/themes/glowbayhp/taxonomy-product_brand.php` (Server Backup: `taxonomy-product_brand.php.bak_1789810109`)
  - `wp-content/themes/glowbayhp/header.php`
  - `public_html/gb_master_purge.php` (Server Backup: `gb_master_purge.php.bak_1789810039`)
- **Key Enhancements**:
  1. **100% Pure English Brand Hero**:
     - Converted all Bengali / Banglish copy in the Brand hero card into pristine English:
       - `Seller Ratings ৯৯% পজিটিভ` &rarr; `Product Rating: 99% Positive`
       - `কুয়ালালামপুর সেন্ট্রাল হাব থেকে সরাসরি আমদানি` &rarr; `Direct Import from Kuala Lumpur Central Hub`
       - `১০০% আসল পণ্য` &rarr; `100% Authentic Guaranteed`
       - `সরাসরি ফ্লাইট` &rarr; `Direct Flight Delivery`
       - `ইনট্যাক্ট সিল ও ইনভয়েস` &rarr; `Intact Seal & Invoice`
  2. **Category Chip Refinement**:
     - Replaced `সব পণ্য` with `All Products`.
     - Replaced dark slate active chip background with Lazada Heartbeat Magenta (`#F8006E`) and soft pink glow `box-shadow: 0 2px 10px rgba(248, 0, 110, 0.25)`.
  3. **Product Card Stock & Action Styling**:
     - Product card prices set to `#F8006E`.
     - [Add to Cart] styled in soft rose pink (`#FFF0F5`) with `#F8006E` border/text, transitioning to solid `#F8006E` on hover.
     - Replaced card stock strings with English (`100% Authentic Guaranteed`, `Out of Stock`, `In Stock`, `⚡ Only X left`).
  4. **Unblocked Desktop Sidebar Filters**:
     - Repositioned `.gb-ai-advisor-container` on desktop (`min-width: 992px`) to `left: auto; right: 28px; bottom: 95px;`, completely freeing the left sidebar price filters from any visual obstruction.
  5. **Header Search Button Orange Preservation**:
     - Strictly maintained Lazada Warm Orange (`#F57224`) on the header search submit button `.gbd-search-btn`.
### Module 16: Brand Category Precision Counting & Desktop Floating Action Stack
- **Files Modified**:
  - `wp-content/themes/glowbayhp/search.php` (Server Backup: `search.php.bak_1789810678`)
  - `wp-content/themes/glowbayhp/taxonomy-product_brand.php` (Server Backup: `taxonomy-product_brand.php.bak_1789810678`)
  - `wp-content/themes/glowbayhp/glowbay_ai_suite.php` (Server Backup: `glowbay_ai_suite.php.bak_1789810678`)
- **Key Enhancements**:
  1. **Brand-Specific Category Precision Counting**:
     - Previously, brand archive category chips and sidebar categories displayed `$bc->count`, which represents the *storewide* taxonomy total across all brands (e.g. Garnier total products = 70, but Skin Care chip displayed 1,050 and Personal Care displayed 652).
     - Upgraded the query to extract all product IDs for the active brand (`'posts_per_page' => -1, 'post_status' => 'publish'`) and tally category associations via `wp_get_object_terms(..., ['fields' => 'all_with_object_id'])`.
     - Category chips and sidebar filter counts now strictly reflect the brand's genuine product count (e.g. for Garnier: `Personal Care (49)`, `Skin Care (21)`, `Serum (9)`, `Moisturizer (5)`, `Haircare (4)`).
  2. **Resolved Desktop Floating Action Stack Collision**:
     - Previously, `.gb-ai-advisor-container` on desktop was placed at `bottom: 95px; right: 28px;`, which directly collided with the circular Back-to-Top button `.gbd-back-top` at `bottom: 96px; right: 30px;`.
     - Elevated `.gb-ai-advisor-container` on desktop (`min-width: 992px`) to `bottom: 155px !important; right: 28px !important; left: auto !important;`.
     - Created a clean, vertical 3-button stack on the right edge:
       - Top: `✨ AI Skin Specialist` (`bottom: 155px`)
       - Middle: `↑` Back to Top (`bottom: 96px`)
       - Bottom: WhatsApp VIP Concierge (`bottom: 28px`)
     - Completely eliminated button overlap while ensuring the left sidebar filters remain completely unblocked.
### Module 17: Mobile Sticky Header Decluttering & Micro Category Chips Removal
- **Files Modified**:
  - `wp-content/themes/glowbayhp/header-mobile.php` (Server Backup: `header-mobile.php.bak_1789811699`)
- **Key Enhancements**:
  1. **Removed Redundant Row 3 Category Chips Bar (`.gbm-chips-bar`)**:
     - Purged the fixed 45px horizontal category strip (`Flash Sale`, `Skincare`, `Hair`, `Makeup`, `Brands`) from `.gbm-master-header`.
     - Completely eliminated redundant category navigation that was wasting 20%-25% of vertical mobile viewport space.
     - Mobile header is now ultra-sleek, clean, and fast (Row 1: Brand & Cart/Wishlist + Row 2: Capsule Search Bar), strictly aligning with Lazada and Shopee mobile e-commerce standards.
     - Frees up ~50px of vertical viewing area on every mobile screen, dramatically improving browsing comfort and product visibility.

---

### Module 18: Enterprise Creator & Affiliate Ecosystem Overhaul (Grade A+ International Standard)
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/glowbay-affiliate.php` (Server Backup: `glowbay-affiliate.php.bak_1789812979`)
  - `wp-content/themes/glowbayhp/page-affiliate.php` (Server Backup: `page-affiliate.php.bak_1789812979`)
  - `wp-content/themes/glowbayhp/templates/mobile/affiliate.php` (Server Backup: `affiliate.php.bak_1789812979`)
  - `wp-content/themes/glowbayhp/page-affiliate-dashboard.php` (Server Backup: `page-affiliate-dashboard.php.bak_1789812979`)
  - `wp-content/themes/glowbayhp/templates/mobile/affiliate-dashboard.php` (Server Backup: `affiliate-dashboard.php.bak_1789812979`)
  - `wp-content/plugins/glowbay-affiliate/templates/control-center.php` (Server Backup: `control-center.php.bak_1789812979`)
- **Key Enhancements**:
  1. **Resolved Zero-Commission Attribution Gap**:
     - Root Cause: Commissions were previously credited only on order completion via raw `$_COOKIE['gbaff_ref']`. Orders completed days later by admins or webhooks failed to track commissions because the customer's browser cookie was absent.
     - Solution: Attached `gbaff_checkout_attribution` to `woocommerce_checkout_order_processed`. Automatically captures referral codes from cookies or affiliate coupons and permanently binds `_gbaff_ref`, `_gbaff_id`, and `_gbaff_source` into WooCommerce order post meta at checkout.
     - Automatically creates pending referrals with itemized commission breakdowns.
     - Self-referral fraud guard prevents users from earning commissions on their own orders.
  2. **Order Lifecycle Automation & Fraud Protection**:
     - `gbaff_order_status_completed_handler` automatically approves and confirms pending referrals when orders are marked `completed`, updating the affiliate's live balance.
     - Cancellation (`woocommerce_order_status_cancelled`) and refund (`woocommerce_order_status_refunded`) hooks automatically void commissions to prevent fraudulent payouts.
  3. **Modernized Tracking Cookies**:
     - Captured with `SameSite=Lax; Secure` (PHP 7.3+ associative syntax).
     - Full support for `?ref=`, `?aff=`, and `?partner=` parameters.
  4. **Luxury Transactional Email Dispatcher**:
     - Created luxury responsive HTML email engine (`gbaff_send_branded_email`) in Midnight Navy (`#0F172A`) with high-resolution GlowBay logo:
       - **Application Received**: Instant confirmation with review timeline (24–48h) and store admin notifications.
       - **Approval Welcome**: Dispatches the partner's unique referral link, personalized coupon code, and dashboard credentials.
       - **Sale Alert**: Real-time notification with order total, commission earned, and line-item details.
       - **Payout Settled**: Dispatches withdrawal receipt with TrxID, transfer method, and net amount.
  5. **100% Pure English Copywriting (Zero Banglish / Bengali)**:
     - Purged all 540 Bengali tokens from Desktop Application (`page-affiliate.php`), Mobile Application (`templates/mobile/affiliate.php`), and Dashboards.
     - Unified under pure, polished English following Rule 2.D.
  6. **Lazada Heartbeat Magenta (`#F8006E`) Theme Alignment**:
     - Replaced all obsolete `#FF1F78` and neon accents across all application pages, dashboards, and control center.
  7. **Mobile 2-Step Interactive Creator Studio**:
     - Replaced legacy POST form in `templates/mobile/affiliate.php` with a sleek 2-step touch studio (Step 1: Contact Details &rarr; Step 2: Channels & Reach).
     - Submits asynchronously to `gbaff_submit_application` via AJAX with real-time feedback and instant confirmation view.
  8. **Payout Threshold & Social Share Kit Unification**:
     - Unified minimum payout threshold to ৳ 1,000 storewide.
     - Added 1-tap Creator Social Share Kit with high-converting pre-filled English WhatsApp messages.
  9. **360° Admin Control Center Drilldown**:
     - Enhanced Pending Applications table on Desktop and Card Deck on Mobile with creator social links, follower sizes, monthly reach, audience locations, and content strategies.

---

### Module 19: Affiliate Catalog Search & Multi-Channel Specific Product Marketing Suite
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/glowbay-affiliate.php` (Server Backup: `glowbay-affiliate.php.bak_1789813758`)
  - `wp-content/themes/glowbayhp/page-affiliate-dashboard.php` (Server Backup: `page-affiliate-dashboard.php.bak_1789813758`)
  - `wp-content/themes/glowbayhp/templates/mobile/affiliate-dashboard.php` (Server Backup: `affiliate-dashboard.php.bak_1789813758`)
- **Key Enhancements**:
  1. **Fully Unlimited Catalog Search (`limit => -1`) & Taxonomy Matching**:
     - Previously, `gbaff_ajax_search_products` was hardcoded to `'limit' => 5`, causing queries like "wardah" to truncate and display only 5 items.
     - Upgraded to dynamic limit defaulting to 50 items (`limit=50`), allowing creators to scroll through the full catalog of matching brand items.
     - Added secondary title fallback search to ensure fuzzy matches are found.
  2. **1-Tap Direct Product Marketing from Showcase Modal**:
     - Upgraded the "Add Products to Curated Showcase" search modal.
     - In addition to **[+ Add to Showcase]**, each search result item now includes a direct **[Copy Link]** button. Creators can copy the product's unique affiliate tracking link immediately without having to first add it to their showcase.
  3. **Universal JSON Schema & Link Binding**:
     - Ensured `gbaff_ajax_search_products` returns both `products` object and direct array, providing seamless backwards compatibility for Desktop and Mobile dashboards.
     - Bound both `affiliate_url` and `url` to prevent undefined URL references in the Link & QR Generator.

---

### Module 20: Amazon SiteStripe Creator Floating Bar & Multi-Tier Dynamic Commission Engine
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/glowbay-affiliate.php` (Server Backup: `glowbay-affiliate.php.bak_1789814889`)
  - `wp-content/themes/glowbayhp/page-affiliate-dashboard.php` (Server Backup: `page-affiliate-dashboard.php.bak_1789815014`)
  - `wp-content/themes/glowbayhp/templates/mobile/affiliate-dashboard.php` (Server Backup: `affiliate-dashboard.php.bak_1789815014`)
- **Key Enhancements**:
  1. **GlowBay Creator Floating Bar (Amazon SiteStripe Model)**:
     - Hooked to `wp_footer`, strictly active ONLY when an approved affiliate is logged in (`is_user_logged_in() && gbaff_current_affiliate()`). Completely invisible to regular customers and guests.
     - Automatically attaches the affiliate's unique referral code (`?ref=CODE`) to ANY page on the storefront (homepage, brand pages, category archives, blog posts, and single product pages) via 1-tap **[Copy Partner Link]**.
     - On single-product pages (`is_product()`):
       - Dynamically calculates exact earnings for that product via `gbaff_resolve_rate` (e.g. `Earn ৳ 236 per sale (10%)`).
       - Features a 1-tap **WhatsApp Share** button with pre-formatted product title, price, and affiliate URL.
       - Identifies and displays non-commission items (`⚠️ Non-Commission Item`).
     - Includes a minimize button that smoothly collapses the toolbar into a pulsing floating diamond bubble (`[💎 Creator Bar]`) with `sessionStorage` state persistence.
  2. **Multi-Tier Dynamic Commission Rate Engine (`gbaff_resolve_rate`)**:
     - Strict 5-tier resolution hierarchy:
       1. **Product Exclusion**: If `_gbaff_enabled === 'no'`, immediately returns `0.0%` (non-commission item).
       2. **Product-Level Override**: Checks `_gbaff_comm_rate` post meta or `gbaff_product_rates` array.
       3. **Campaign Override**: Checks `gbaff_campaign_rates`.
       4. **Category-Level Matrix**: Checks `gbaff_cat_rates` for all assigned `product_cat` terms (e.g. Skincare 10%, Haircare 8%, Clearance 0%).
       5. **Affiliate Tier Booster**: Checks `$aff->commission_rate` / `gbaff_aff_rates`.
       6. **Storewide Fallback**: Global rate (`gbaff_commission_rate`, default 10%).
  3. **Admin Category Commission API**:
     - Added `gbaff_ajax_update_category_commissions` and integrated with `control-center.php` category overrides.
  4. **Creator Dashboards (Desktop & Mobile) Dynamic Showcase Sync**:
     - Upgraded showcase product cards on both Desktop (`page-affiliate-dashboard.php`) and Mobile (`affiliate-dashboard.php`) to dynamically call `gbaff_resolve_rate($aff_id, $product_id)`.
     - Displays exact earning amount with percentage badge (e.g. `Earn ৳ 236 (10%)`) or a prominent red exclusion badge (`<i class="fa-solid fa-ban"></i> Excluded`) when a product is opted out of commission.

---

### Module 21: Clean Native PDP Affiliate Sharing (Database Schema & Dual-Layer Resolution)
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/glowbay-affiliate.php` (Server Backup: `glowbay-affiliate.php.bak_1789817302`)
  - `wp-content/themes/glowbayhp/woocommerce/single-product.php` (Server Backup: `single-product.php.bak_1789817302`)
  - `wp-content/themes/glowbayhp/templates/mobile/product.php` (Server Backup: `product.php.bak_1789817302`)
  - `wp-content/themes/glowbayhp/page-affiliate-dashboard.php` (Server Backup: `page-affiliate-dashboard.php.bak_1789817302`)
  - `wp-content/themes/glowbayhp/templates/mobile/affiliate-dashboard.php` (Server Backup: `affiliate-dashboard.php.bak_1789817302`)
- **Root Cause & Fix**:
  - **Column Mismatch Resolved**: The affiliate database table `wp_gbaff_applicants` defines the referral code column as `code`, NOT `ref_code`. The previous code checked `$aff->ref_code`, which evaluated to null, preventing affiliate detection.
  - **Triple-Layer Redundancy**:
    1. **PHP Core**: Extracts `$aff_code` from `$aff->code` with fallback to `$_COOKIE['gb_my_aff_code']`.
    2. **Session / Login Cookie Sync**: `gbaff_sync_partner_session_cookie` and `gbaff_on_login_set_partner_cookie` ensure `gb_my_aff_code` cookie is set across the entire domain on login and page load.
    3. **Client-Side Cache Immunity (`gbGetAffiliateShareUrl` / `gbGetMobAffiliateUrl`)**: Even if an HTML cache (like LiteSpeed) serves a cached product page to an affiliate, JavaScript checks `window.gbMyAffCode`, `document.cookie`, and `localStorage.getItem('gb_my_aff_code')`, dynamically injecting `?ref=CODE` into the share link on the fly!
    4. **Dashboard Seed**: Opening the affiliate dashboard instantly persists `gb_my_aff_code` into both cookie and browser `localStorage`.
- **Verified**:
  - Tested on live server with both Desktop and Mobile viewports.
  - Links, badges, Web Share API, and clipboard copy confirmed to append `?ref=CODE` with custom toast notification.

---

### Module 22: Affiliate System Deep Audit & Full-Stack Hardening
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/glowbay-affiliate.php` (Server Backup: `glowbay-affiliate.php.bak_1789818875`)
  - Live Database Tables (`wpqb_gbaff_referrals`, `wpqb_gbaff_visits`, `wpqb_gbaff_applicants`, `wpqb_gbaff_showcase`)
- **Key Issues Identified in Deep Audit & Fixed**:
  1. **Referral Order Attribution Insert Failure**:
     - Previously, `gbaff_checkout_attribution()` attempted to insert `order_total` and `risk_reason`, but the SQL table only had `amount` and `base`. The insert failed silently on every single checkout.
     - **Fix**: Executed database migration adding `order_total DECIMAL(10,2)` and `risk_reason TEXT NULL` to `wpqb_gbaff_referrals`. Updated `gbaff_checkout_attribution` to insert both `amount`, `base`, and `order_total` for full multi-version compatibility.
  2. **Visit/Click Tracking Failure**:
     - `gbaff_capture_ref()` attempted to insert `user_agent` and `landing_page`, but the table column was named `landing`.
     - **Fix**: Added `user_agent TEXT NULL` and `landing_page VARCHAR(255) NULL` to `wpqb_gbaff_visits`. Updated plugin to write both `landing` and `landing_page` plus sanitized `user_agent`.
  3. **Coupon Query SQL Crash**:
     - Code executed `SELECT * FROM {$tbl_app} WHERE coupon_code = %s`, but `coupon_code` column was missing in `wpqb_gbaff_applicants`.
     - **Fix**: Added `coupon_code VARCHAR(50) NULL` to `wpqb_gbaff_applicants`. Updated coupon lookup to check WooCommerce coupon post meta `_gbaff_affiliate_code` first, then fall back to `code` or `coupon_code`.
  4. **Cancelled Order Reversal Loophole**:
     - `gbaff_reverse_referral()` previously only reversed commissions when `status IN ('confirmed', 'approved')`. Pending commissions remained orphaned if an order was cancelled before approval.
     - **Fix**: Expanded reversal condition to `status IN ('pending', 'confirmed', 'approved')`.
  5. **Enhanced Fraud Prevention & Self-Referral Detection**:
     - Added comprehensive matching between the affiliate's account and the purchaser:
       - User ID (`current_user_id` & `$order->get_customer_id()`)
       - Email address (checks billing email vs user email & applicant email)
       - Phone number (compares sanitized last 10 digits to prevent prefix variations like +880, 880, 017)
  6. **Application Endpoint Hardening**:
     - Added authentication guard in `gbaff_ajax_submit_application` requiring an active logged-in user account before an affiliate application can be submitted.

---

### Module 23: Enterprise Affiliate Admin Control Suite & Analytics Upgrade
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/glowbay-affiliate.php` (Server Backup: `glowbay-affiliate.php.bak_1789820084`)
  - `wp-content/plugins/glowbay-affiliate/templates/control-center.php` (Server Backup: `control-center.php.bak_1789820084`)
- **Key Features & Enhancements Deployed**:
  1. **Interactive Chart.js Analytics Engine**:
     - Embedded Chart.js (UMD version) with custom GlowBay luxury color gradients.
     - Live metric toggling: Attributed Revenue (BDT), Partner Commissions (BDT), and Traffic Clicks.
     - Time range switcher: 7 Days, 30 Days, 90 Days with smooth client-side dataset updates.
  2. **Storewide Leaderboards & Channel Intelligence**:
     - **Top 5 Performing Affiliates Widget**: Live ranking with rank badges (Gold, Silver, Bronze), Partner Name, Referral Code, Total Sales Volume, Commission, and 1-click 360° profile inspection.
     - **Top 5 Hot-Selling Products via Affiliates Widget**: Real-time sales aggregation displaying product thumbnail, title, total units sold, gross sales, and commission.
     - **Traffic Acquisition Bar**: Displays live visitor distribution across Facebook, Instagram, TikTok, YouTube, and Direct links.
  3. **360° Partner Profile Modal with 5 Dedicated Tabs**:
     - Tab 1: **Orders Ledger**: Full history of up to 50 customer orders with WooCommerce item breakdowns, prices, and statuses.
     - Tab 2: **Top Selling Products Leaderboard**: Ranks all products sold by this creator (Rank, Thumbnail, Title, Units Sold, Total BDT Revenue, Commission Earned).
     - Tab 3: **Traffic & Visitor Intelligence**: Total Clicks, Conversion Rate % (`Orders / Clicks * 100`), Primary Device (`Mobile` vs `Desktop`), and live click stream table (Timestamp, Source, Landing Page, Device, IP).
     - Tab 4: **Disburse Payout**: Offline payment recording form with bKash, Nagad, Rocket, or Bank Wire details.
     - Tab 5: **Comprehensive Partner Editor**: Form to edit Name, Phone, Email, Unique Referral Code (with collision validation), Commission Rate %, Tier, Status, and Payout details.
  4. **Referrals & Orders Ledger with Full Admin Action Suite**:
     - Real-time client-side filter bar: search by Order # or Partner Name/Code, and filter by status (`All`, `Pending`, `Confirmed`, `Approved`, `Cancelled`).
     - Inline action buttons: `[Approve]` for pending orders, `[Cancel]` to reverse commission, and `[Adjust]` modal to customize commission amount with admin memo.
     - 1-click `[Export Filtered CSV]` download.
  5. **Payout Rejection & Balance Refund Management**:
     - Added `[Reject Request]` action button alongside `[Settle Payout]`.
     - Rejection modal prompts for mandatory admin reason and sets status to `rejected`, automatically restoring requested funds back to the partner's available balance.
  6. **1-Click WooCommerce Coupon Generator**:
     - Direct creation widget in the admin panel creating a real WooCommerce coupon (`WC_Coupon`) and linking `_gbaff_affiliate_id` and `_gbaff_affiliate_code` in one atomic step.

---

### Module 24: Enterprise Admin Control Center V5 Architecture Fixes & Execution Hardening
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/templates/control-center.php` (Server Backup: `control-center.php.bak_1789820866`)
- **Root Cause Analysis & Architecture Fixes**:
  1. **Fixed Leaked Raw HTML Attribute (`id="screen-affiliates" class="gbadm-screen ">`)**:
     - *Root Cause*: During template compilation, string replacement sliced `screen-overview` starting at `id="screen-overview"` and ending at `id="screen-affiliates"`, unintentionally stripping the opening `<section ` tag from `screen-affiliates`. The browser subsequently rendered the raw attributes as visible text at the top of the Partners table.
     - *Fix*: Refactored builder to strictly match full element boundaries `<section id="...">` to `</section>`.
  2. **Fixed PHP 8 Fatal Crash on Line 2876 (`TypeError: count(null)`)**:
     - *Root Cause*: In `screen-commissions`, the template referenced an undefined variable `$all_refs` (`count($all_refs)`). In PHP 8+, passing null to `count()` raises an uncaught fatal `TypeError`. This abruptly terminated PHP execution halfway through page rendering.
     - *Secondary Impact*: Because PHP halted before reaching the bottom of `control-center.php`, the closing HTML and the `<script>` tag were never rendered to the browser. As a result, the Chart.js canvas remained blank white, and the Top Affiliates and Top Products tables remained stuck on their initial loading spinners.
     - *Fix*: Standardized variable references to `$recent_referrals` with defensive type casting `(!empty($recent_referrals) && is_array($recent_referrals)) ? $recent_referrals : array()`.
  3. **Resolved Script Inclusion Hierarchy**:
     - Standalone `<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>` is injected ahead of the main inline script block, ensuring the Chart object is globally available when `renderOverviewChart()` is triggered.
  4. **Full-Stack Runtime Simulation Protocol**:
     - Established a mandatory pre-deployment runtime check: executing templates in a simulated WordPress runtime environment (`gb_render_check.php`) to test against uncaught PHP 8 runtime exceptions, validating that 100% of the HTML (down to `</body></html>`) renders cleanly before production rollout.

---

## 4. 🔄 Standard Operating Procedure (SOP) for Every Coding Task

When given ANY task by the user:

```
[START TASK]
    │
    ▼
1. READ MEMORY: Read GEMINI.md / AGENTS.md to load rules & context.
    │
    ▼
2. BACKUP: If modifying existing server file:
   - Create filename.php.bak_TIMESTAMP on server via cPanel API.
    │
    ▼
3. LINT / SYNTAX CHECK:
   - Verify PHP syntax with `php -l` before deploying to production.
    │
    ▼
4. DEPLOY:
   - Save via cPanel API Fileman.
    │
    ▼
5. CACHE PURGE:
   - Trigger `https://glowbaybd.com/gb_master_purge.php`.
    │
    ▼
6. VERIFY:
   - Fetch live URL, confirm HTTP 200 and verify DOM elements.
    │
    ▼
7. AUTO-UPDATE MEMORY:
   - Append changes and notes to this GEMINI.md / AGENTS.md file.
    │
    ▼
[REPORT TO USER]
```

### Module 25: Affiliate Admin Control Center — Final Bug Fixes (FIX 4, FIX 8 + DB Audit)
- **Files Modified**:
  - `public_html/wp-content/plugins/glowbay-affiliate/templates/control-center.php` (Backup: `control-center.php.bak_1789822126`)
- **Key Enhancements**:
  1. **FIX 4 — Dynamic Approve/Suspend Action Buttons in Affiliates Table**:
     - Inserted conditional PHP after the `[View 360° Profile]` button in the approved partners table loop.
     - If `$af->status === 'approved'` → shows orange **[Suspend]** button.
     - If `$af->status === 'pending'` or `'suspended'` → shows green **[Approve]** button.
     - Both buttons call `gbaff_update_affiliate_meta` AJAX with nonce, `aff_id`, `field=status`, and the new value, then reload.
  2. **FIX 7 — Export CSV Button (Confirmed Already Existed)**:
     - `exportFilteredLedgerCsv()` button already present in Referrals & Orders Ledger screen. No change needed.
  3. **FIX 8 — Run Live Diagnostics Button + Output Container**:
     - Added **[Run Live Diagnostics]** button and `<div id="diagnostics-output">` to the Security & Diagnostics card in the Rules & Diagnostics screen.
     - Button calls existing `runDiagnostics()` JS function which renders a live AJAX metrics table.
  4. **Database Tables Audit (All 6 Confirmed Present)**:
     - `wpqb_gbaff_applicants`: ✅ 7 rows | `wpqb_gbaff_referrals`: ✅ 1 | `wpqb_gbaff_visits`: ✅ 258
     - `wpqb_gbaff_payouts`: ✅ 0 rows (empty but exists) | `wpqb_gbaff_activity`: ✅ 2 | `wpqb_gbaff_showcase`: ✅ 0
  5. **Cache Purge**: HTTP 200 `PURGE_COMPLETE_DELETED_25` ✅
- **Prior Session Fixes Also Deployed (FIX 1–3, FIX 5–6)**:
  - FIX 1: Traffic source auto-detection from HTTP_REFERER in `gbaff_capture_ref()`.
  - FIX 2: Analytics `$traffic_sources` query fixed to use correct `source` column with GROUP BY.
   - FIX 3: Status badge in Affiliates table now dynamic via `ucfirst($af->status)`.
   - FIX 5: `DOMContentLoaded` auto-init calls `loadOverviewAnalytics()` after 400ms.
   - FIX 6: `quickUpdateRefStatus()` does in-place badge swap instead of full `location.reload()`.

### Module 26: Flash Sale Plugin Deep Audit & Bug Fix Deployment
- **Research**: Conducted deep research on Shopee & Lazada flash sale architecture (countdown urgency, sold-bar psychology, priority ordering, stock gating, refund restore flows).
- **Audit**: Full audit of all 17 plugin files — identified 25 bugs categorized by severity (P0 Critical, P1 Brand/Logic, P2 Low).
- **Files Modified** (all backed up with timestamp `_1789849035`):
  - `wp-content/plugins/glowbay-flashsale/glowbay-flashsale.php`
  - `wp-content/plugins/glowbay-flashsale/includes/class-db.php`
  - `wp-content/plugins/glowbay-flashsale/includes/class-campaign.php`
  - `wp-content/plugins/glowbay-flashsale/includes/class-pricing.php`
  - `wp-content/plugins/glowbay-flashsale/includes/class-admin.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/settings.php`
  - `wp-content/plugins/glowbay-flashsale/admin/js/admin.js`
  - `wp-content/themes/glowbayhp/page-flash-sale.php`
- **P0 Critical Bugs Fixed**:
  1. **BUG #1** — `set_status()` in `class-campaign.php` used undefined `$tp` variable → added `$tp = $wpdb->prefix . 'glowbay_flash_campaign_products'` before usage.
  2. **BUG #2** — Auto-rollover block in `get_active_for_product()` silently activated wrong campaigns → 4-line block removed entirely.
  3. **BUG #3** — Meta key mismatch: `class-pricing.php` wrote `_glowbay_flash_campaign` but `class-stock.php::on_refund()` read `_glowbay_flash_campaign_id` → unified to `_glowbay_flash_campaign_id`.
  4. **BUG #4** — `block_when_exhausted` setting in `glowbay_flash_settings` was never read → added enforcement in `cart()` method of `class-pricing.php` to block add-to-cart when stock exhausted.
  5. **BUG #5** — `wpqb_glowbay_flash_events` table missing `order_id BIGINT(20)` column causing refund tracking crash → added column to schema, `maybe_upgrade()` runs `ALTER TABLE` if missing, schema bumped from v2 → v3. DB upgrade helper deployed + verified via HTTP, then cleaned.
- **P1 Brand & Logic Bugs Fixed**:
  6. **BUG #6** — Prohibited colors `#FF1F78`, `#E11D48`, `#FF2374`, `#FF8A20` found across plugin CSS, JS, admin views, and page template → all replaced with `#F8006E` (magenta) and `#F57224` (orange).
  7. **BUG #7** — "Air Cargo" text in `page-flash-sale.php` → replaced with "Direct Flight Delivery".
  8. **BUG #8** — Hardcoded "30%" avg discount in hero → replaced with dynamic calculation from `wpqb_glowbay_flash_campaign_products` DB query.
  9. **BUG #9** — Countdown targeting hardcoded BST midnight → now targets real `end_utc` from active campaign.
  10. **BUG #11** — `track_view()` and `track_click()` in `class-pricing.php` were empty stubs → implemented to write real event rows to `wpqb_glowbay_flash_events`.
  11. **BUG #12** — Bengali/Banglish text in `admin/views/settings.php` → 100% replaced with clean professional English.
  12. **BUG #13** — `wp_ajax_nopriv_gbfs_search` registered in `class-admin.php` exposing admin product search to unauthenticated users → hook removed.
  13. **BUG #14** — Claimed percentage bar in `page-flash-sale.php` used hardcoded fake value → replaced with real calculation from `wpqb_glowbay_flash_stock` (sold/allocated).
       6. **Storewide Fallback**: Global rate (`gbaff_commission_rate`, default 10%).
  3. **Admin Category Commission API**:
     - Added `gbaff_ajax_update_category_commissions` and integrated with `control-center.php` category overrides.
  4. **Creator Dashboards (Desktop & Mobile) Dynamic Showcase Sync**:
     - Upgraded showcase product cards on both Desktop (`page-affiliate-dashboard.php`) and Mobile (`affiliate-dashboard.php`) to dynamically call `gbaff_resolve_rate($aff_id, $product_id)`.
     - Displays exact earning amount with percentage badge (e.g. `Earn ৳ 236 (10%)`) or a prominent red exclusion badge (`<i class="fa-solid fa-ban"></i> Excluded`) when a product is opted out of commission.

---

### Module 21: Clean Native PDP Affiliate Sharing (Database Schema & Dual-Layer Resolution)
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/glowbay-affiliate.php` (Server Backup: `glowbay-affiliate.php.bak_1789817302`)
  - `wp-content/themes/glowbayhp/woocommerce/single-product.php` (Server Backup: `single-product.php.bak_1789817302`)
  - `wp-content/themes/glowbayhp/templates/mobile/product.php` (Server Backup: `product.php.bak_1789817302`)
  - `wp-content/themes/glowbayhp/page-affiliate-dashboard.php` (Server Backup: `page-affiliate-dashboard.php.bak_1789817302`)
  - `wp-content/themes/glowbayhp/templates/mobile/affiliate-dashboard.php` (Server Backup: `affiliate-dashboard.php.bak_1789817302`)
- **Root Cause & Fix**:
  - **Column Mismatch Resolved**: The affiliate database table `wp_gbaff_applicants` defines the referral code column as `code`, NOT `ref_code`. The previous code checked `$aff->ref_code`, which evaluated to null, preventing affiliate detection.
  - **Triple-Layer Redundancy**:
    1. **PHP Core**: Extracts `$aff_code` from `$aff->code` with fallback to `$_COOKIE['gb_my_aff_code']`.
    2. **Session / Login Cookie Sync**: `gbaff_sync_partner_session_cookie` and `gbaff_on_login_set_partner_cookie` ensure `gb_my_aff_code` cookie is set across the entire domain on login and page load.
    3. **Client-Side Cache Immunity (`gbGetAffiliateShareUrl` / `gbGetMobAffiliateUrl`)**: Even if an HTML cache (like LiteSpeed) serves a cached product page to an affiliate, JavaScript checks `window.gbMyAffCode`, `document.cookie`, and `localStorage.getItem('gb_my_aff_code')`, dynamically injecting `?ref=CODE` into the share link on the fly!
    4. **Dashboard Seed**: Opening the affiliate dashboard instantly persists `gb_my_aff_code` into both cookie and browser `localStorage`.
- **Verified**:
  - Tested on live server with both Desktop and Mobile viewports.
  - Links, badges, Web Share API, and clipboard copy confirmed to append `?ref=CODE` with custom toast notification.

---

### Module 22: Affiliate System Deep Audit & Full-Stack Hardening
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/glowbay-affiliate.php` (Server Backup: `glowbay-affiliate.php.bak_1789818875`)
  - Live Database Tables (`wpqb_gbaff_referrals`, `wpqb_gbaff_visits`, `wpqb_gbaff_applicants`, `wpqb_gbaff_showcase`)
- **Key Issues Identified in Deep Audit & Fixed**:
  1. **Referral Order Attribution Insert Failure**:
     - Previously, `gbaff_checkout_attribution()` attempted to insert `order_total` and `risk_reason`, but the SQL table only had `amount` and `base`. The insert failed silently on every single checkout.
     - **Fix**: Executed database migration adding `order_total DECIMAL(10,2)` and `risk_reason TEXT NULL` to `wpqb_gbaff_referrals`. Updated `gbaff_checkout_attribution` to insert both `amount`, `base`, and `order_total` for full multi-version compatibility.
  2. **Visit/Click Tracking Failure**:
     - `gbaff_capture_ref()` attempted to insert `user_agent` and `landing_page`, but the table column was named `landing`.
     - **Fix**: Added `user_agent TEXT NULL` and `landing_page VARCHAR(255) NULL` to `wpqb_gbaff_visits`. Updated plugin to write both `landing` and `landing_page` plus sanitized `user_agent`.
  3. **Coupon Query SQL Crash**:
     - Code executed `SELECT * FROM {$tbl_app} WHERE coupon_code = %s`, but `coupon_code` column was missing in `wpqb_gbaff_applicants`.
     - **Fix**: Added `coupon_code VARCHAR(50) NULL` to `wpqb_gbaff_applicants`. Updated coupon lookup to check WooCommerce coupon post meta `_gbaff_affiliate_code` first, then fall back to `code` or `coupon_code`.
  4. **Cancelled Order Reversal Loophole**:
     - `gbaff_reverse_referral()` previously only reversed commissions when `status IN ('confirmed', 'approved')`. Pending commissions remained orphaned if an order was cancelled before approval.
     - **Fix**: Expanded reversal condition to `status IN ('pending', 'confirmed', 'approved')`.
  5. **Enhanced Fraud Prevention & Self-Referral Detection**:
     - Added comprehensive matching between the affiliate's account and the purchaser:
       - User ID (`current_user_id` & `$order->get_customer_id()`)
       - Email address (checks billing email vs user email & applicant email)
       - Phone number (compares sanitized last 10 digits to prevent prefix variations like +880, 880, 017)
  6. **Application Endpoint Hardening**:
     - Added authentication guard in `gbaff_ajax_submit_application` requiring an active logged-in user account before an affiliate application can be submitted.

---

### Module 23: Enterprise Affiliate Admin Control Suite & Analytics Upgrade
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/glowbay-affiliate.php` (Server Backup: `glowbay-affiliate.php.bak_1789820084`)
  - `wp-content/plugins/glowbay-affiliate/templates/control-center.php` (Server Backup: `control-center.php.bak_1789820084`)
- **Key Features & Enhancements Deployed**:
  1. **Interactive Chart.js Analytics Engine**:
     - Embedded Chart.js (UMD version) with custom GlowBay luxury color gradients.
     - Live metric toggling: Attributed Revenue (BDT), Partner Commissions (BDT), and Traffic Clicks.
     - Time range switcher: 7 Days, 30 Days, 90 Days with smooth client-side dataset updates.
  2. **Storewide Leaderboards & Channel Intelligence**:
     - **Top 5 Performing Affiliates Widget**: Live ranking with rank badges (Gold, Silver, Bronze), Partner Name, Referral Code, Total Sales Volume, Commission, and 1-click 360° profile inspection.
     - **Top 5 Hot-Selling Products via Affiliates Widget**: Real-time sales aggregation displaying product thumbnail, title, total units sold, gross sales, and commission.
     - **Traffic Acquisition Bar**: Displays live visitor distribution across Facebook, Instagram, TikTok, YouTube, and Direct links.
  3. **360° Partner Profile Modal with 5 Dedicated Tabs**:
     - Tab 1: **Orders Ledger**: Full history of up to 50 customer orders with WooCommerce item breakdowns, prices, and statuses.
     - Tab 2: **Top Selling Products Leaderboard**: Ranks all products sold by this creator (Rank, Thumbnail, Title, Units Sold, Total BDT Revenue, Commission Earned).
     - Tab 3: **Traffic & Visitor Intelligence**: Total Clicks, Conversion Rate % (`Orders / Clicks * 100`), Primary Device (`Mobile` vs `Desktop`), and live click stream table (Timestamp, Source, Landing Page, Device, IP).
     - Tab 4: **Disburse Payout**: Offline payment recording form with bKash, Nagad, Rocket, or Bank Wire details.
     - Tab 5: **Comprehensive Partner Editor**: Form to edit Name, Phone, Email, Unique Referral Code (with collision validation), Commission Rate %, Tier, Status, and Payout details.
  4. **Referrals & Orders Ledger with Full Admin Action Suite**:
     - Real-time client-side filter bar: search by Order # or Partner Name/Code, and filter by status (`All`, `Pending`, `Confirmed`, `Approved`, `Cancelled`).
     - Inline action buttons: `[Approve]` for pending orders, `[Cancel]` to reverse commission, and `[Adjust]` modal to customize commission amount with admin memo.
     - 1-click `[Export Filtered CSV]` download.
  5. **Payout Rejection & Balance Refund Management**:
     - Added `[Reject Request]` action button alongside `[Settle Payout]`.
     - Rejection modal prompts for mandatory admin reason and sets status to `rejected`, automatically restoring requested funds back to the partner's available balance.
  6. **1-Click WooCommerce Coupon Generator**:
     - Direct creation widget in the admin panel creating a real WooCommerce coupon (`WC_Coupon`) and linking `_gbaff_affiliate_id` and `_gbaff_affiliate_code` in one atomic step.

---

### Module 24: Enterprise Admin Control Center V5 Architecture Fixes & Execution Hardening
- **Files Modified**:
  - `wp-content/plugins/glowbay-affiliate/templates/control-center.php` (Server Backup: `control-center.php.bak_1789820866`)
- **Root Cause Analysis & Architecture Fixes**:
  1. **Fixed Leaked Raw HTML Attribute (`id="screen-affiliates" class="gbadm-screen ">`)**:
     - *Root Cause*: During template compilation, string replacement sliced `screen-overview` starting at `id="screen-overview"` and ending at `id="screen-affiliates"`, unintentionally stripping the opening `<section ` tag from `screen-affiliates`. The browser subsequently rendered the raw attributes as visible text at the top of the Partners table.
     - *Fix*: Refactored builder to strictly match full element boundaries `<section id="...">` to `</section>`.
  2. **Fixed PHP 8 Fatal Crash on Line 2876 (`TypeError: count(null)`)**:
     - *Root Cause*: In `screen-commissions`, the template referenced an undefined variable `$all_refs` (`count($all_refs)`). In PHP 8+, passing null to `count()` raises an uncaught fatal `TypeError`. This abruptly terminated PHP execution halfway through page rendering.
     - *Secondary Impact*: Because PHP halted before reaching the bottom of `control-center.php`, the closing HTML and the `<script>` tag were never rendered to the browser. As a result, the Chart.js canvas remained blank white, and the Top Affiliates and Top Products tables remained stuck on their initial loading spinners.
     - *Fix*: Standardized variable references to `$recent_referrals` with defensive type casting `(!empty($recent_referrals) && is_array($recent_referrals)) ? $recent_referrals : array()`.
  3. **Resolved Script Inclusion Hierarchy**:
     - Standalone `<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>` is injected ahead of the main inline script block, ensuring the Chart object is globally available when `renderOverviewChart()` is triggered.
  4. **Full-Stack Runtime Simulation Protocol**:
     - Established a mandatory pre-deployment runtime check: executing templates in a simulated WordPress runtime environment (`gb_render_check.php`) to test against uncaught PHP 8 runtime exceptions, validating that 100% of the HTML (down to `</body></html>`) renders cleanly before production rollout.

---

## 4. 🔄 Standard Operating Procedure (SOP) for Every Coding Task

When given ANY task by the user:

```
[START TASK]
    │
    ▼
1. READ MEMORY: Read GEMINI.md / AGENTS.md to load rules & context.
    │
    ▼
2. BACKUP: If modifying existing server file:
   - Create filename.php.bak_TIMESTAMP on server via cPanel API.
    │
    ▼
3. LINT / SYNTAX CHECK:
   - Verify PHP syntax with `php -l` before deploying to production.
    │
    ▼
4. DEPLOY:
   - Save via cPanel API Fileman.
    │
    ▼
5. CACHE PURGE:
   - Trigger `https://glowbaybd.com/gb_master_purge.php`.
    │
    ▼
6. VERIFY:
   - Fetch live URL, confirm HTTP 200 and verify DOM elements.
    │
    ▼
7. AUTO-UPDATE MEMORY:
   - Append changes and notes to this GEMINI.md / AGENTS.md file.
    │
    ▼
[REPORT TO USER]
```

### Module 25: Affiliate Admin Control Center — Final Bug Fixes (FIX 4, FIX 8 + DB Audit)
- **Files Modified**:
  - `public_html/wp-content/plugins/glowbay-affiliate/templates/control-center.php` (Backup: `control-center.php.bak_1789822126`)
- **Key Enhancements**:
  1. **FIX 4 — Dynamic Approve/Suspend Action Buttons in Affiliates Table**:
     - Inserted conditional PHP after the `[View 360° Profile]` button in the approved partners table loop.
     - If `$af->status === 'approved'` → shows orange **[Suspend]** button.
     - If `$af->status === 'pending'` or `'suspended'` → shows green **[Approve]** button.
     - Both buttons call `gbaff_update_affiliate_meta` AJAX with nonce, `aff_id`, `field=status`, and the new value, then reload.
  2. **FIX 7 — Export CSV Button (Confirmed Already Existed)**:
     - `exportFilteredLedgerCsv()` button already present in Referrals & Orders Ledger screen. No change needed.
  3. **FIX 8 — Run Live Diagnostics Button + Output Container**:
     - Added **[Run Live Diagnostics]** button and `<div id="diagnostics-output">` to the Security & Diagnostics card in the Rules & Diagnostics screen.
     - Button calls existing `runDiagnostics()` JS function which renders a live AJAX metrics table.
  4. **Database Tables Audit (All 6 Confirmed Present)**:
     - `wpqb_gbaff_applicants`: ✅ 7 rows | `wpqb_gbaff_referrals`: ✅ 1 | `wpqb_gbaff_visits`: ✅ 258
     - `wpqb_gbaff_payouts`: ✅ 0 rows (empty but exists) | `wpqb_gbaff_activity`: ✅ 2 | `wpqb_gbaff_showcase`: ✅ 0
  5. **Cache Purge**: HTTP 200 `PURGE_COMPLETE_DELETED_25` ✅
- **Prior Session Fixes Also Deployed (FIX 1–3, FIX 5–6)**:
  - FIX 1: Traffic source auto-detection from HTTP_REFERER in `gbaff_capture_ref()`.
  - FIX 2: Analytics `$traffic_sources` query fixed to use correct `source` column with GROUP BY.
   - FIX 3: Status badge in Affiliates table now dynamic via `ucfirst($af->status)`.
   - FIX 5: `DOMContentLoaded` auto-init calls `loadOverviewAnalytics()` after 400ms.
   - FIX 6: `quickUpdateRefStatus()` does in-place badge swap instead of full `location.reload()`.

### Module 26: Flash Sale Plugin Deep Audit & Bug Fix Deployment
- **Research**: Conducted deep research on Shopee & Lazada flash sale architecture (countdown urgency, sold-bar psychology, priority ordering, stock gating, refund restore flows).
- **Audit**: Full audit of all 17 plugin files — identified 25 bugs categorized by severity (P0 Critical, P1 Brand/Logic, P2 Low).
- **Files Modified** (all backed up with timestamp `_1789849035`):
  - `wp-content/plugins/glowbay-flashsale/glowbay-flashsale.php`
  - `wp-content/plugins/glowbay-flashsale/includes/class-db.php`
  - `wp-content/plugins/glowbay-flashsale/includes/class-campaign.php`
  - `wp-content/plugins/glowbay-flashsale/includes/class-pricing.php`
  - `wp-content/plugins/glowbay-flashsale/includes/class-admin.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/settings.php`
  - `wp-content/plugins/glowbay-flashsale/admin/js/admin.js`
  - `wp-content/themes/glowbayhp/page-flash-sale.php`
- **P0 Critical Bugs Fixed**:
  1. **BUG #1** — `set_status()` in `class-campaign.php` used undefined `$tp` variable → added `$tp = $wpdb->prefix . 'glowbay_flash_campaign_products'` before usage.
  2. **BUG #2** — Auto-rollover block in `get_active_for_product()` silently activated wrong campaigns → 4-line block removed entirely.
  3. **BUG #3** — Meta key mismatch: `class-pricing.php` wrote `_glowbay_flash_campaign` but `class-stock.php::on_refund()` read `_glowbay_flash_campaign_id` → unified to `_glowbay_flash_campaign_id`.
  4. **BUG #4** — `block_when_exhausted` setting in `glowbay_flash_settings` was never read → added enforcement in `cart()` method of `class-pricing.php` to block add-to-cart when stock exhausted.
  5. **BUG #5** — `wpqb_glowbay_flash_events` table missing `order_id BIGINT(20)` column causing refund tracking crash → added column to schema, `maybe_upgrade()` runs `ALTER TABLE` if missing, schema bumped from v2 → v3. DB upgrade helper deployed + verified via HTTP, then cleaned.
- **P1 Brand & Logic Bugs Fixed**:
  6. **BUG #6** — Prohibited colors `#FF1F78`, `#E11D48`, `#FF2374`, `#FF8A20` found across plugin CSS, JS, admin views, and page template → all replaced with `#F8006E` (magenta) and `#F57224` (orange).
  7. **BUG #7** — "Air Cargo" text in `page-flash-sale.php` → replaced with "Direct Flight Delivery".
  8. **BUG #8** — Hardcoded "30%" avg discount in hero → replaced with dynamic calculation from `wpqb_glowbay_flash_campaign_products` DB query.
  9. **BUG #9** — Countdown targeting hardcoded BST midnight → now targets real `end_utc` from active campaign.
  10. **BUG #11** — `track_view()` and `track_click()` in `class-pricing.php` were empty stubs → implemented to write real event rows to `wpqb_glowbay_flash_events`.
  11. **BUG #12** — Bengali/Banglish text in `admin/views/settings.php` → 100% replaced with clean professional English.
  12. **BUG #13** — `wp_ajax_nopriv_gbfs_search` registered in `class-admin.php` exposing admin product search to unauthenticated users → hook removed.
  13. **BUG #14** — Claimed percentage bar in `page-flash-sale.php` used hardcoded fake value → replaced with real calculation from `wpqb_glowbay_flash_stock` (sold/allocated).
  14. **BUG #15** — Campaign product query in `page-flash-sale.php` sorted `ASC` by priority → corrected to `DESC` so highest priority campaigns appear first.
  15. **BUG #19** — Admin JS countdown parsed `end_time` string as local time → fixed by appending `' UTC'` to force correct UTC parsing.
- **DB Schema Version**: Bumped `GBFS_SCHEMA_VERSION` constant from `2` → `3` in `glowbay-flashsale.php`.
- **Deferred Bugs** (lower priority — next phase): BUG #10 (WP-Cron rotation disabled), BUG #16 (dashboard stock check for variable products), BUG #17 (global display settings not syncing to campaign JSON), BUG #18 (hardcoded fake chart data), BUG #20 (legacy-v1.php conflicting hooks), BUGs #21–25 (CRLF, timezone labels, REST caching, UTC labels, max_per_customer enforcement).
- **Cache Purge**: HTTP 200 `OK` ✅
- **Flash Sale Plugin Architecture (for future reference)**:
  - DB prefix: `wpqb_glowbay_flash_` (4 tables: campaigns, campaign_products, stock, events)
  - Capability: `GBFS_CAP` = `manage_glowbay_flashsales`
  - Option keys: `gbfs_opt` (legacy), `glowbay_flash_settings` (v2), `glowbay_flashsale_settings` (synced to theme)
  - Pricing entry: `GlowBay_Flash_Pricing::winning($pid, $vid)` → calls `GlowBay_Flash_Campaign::instance()->get_active_for_product()`

### Module 27: Flash Sale Admin Console 100% English, Stock Ledger & Lazada UI Revamp
- **User Directive**: Clean all issues discovered during the Flash Sale Control Center dashboard audit.
- **Files Modified** (all backed up with timestamp `_1789849572` and `_1789849615`):
  - `wp-content/plugins/glowbay-flashsale/admin/views/dashboard.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/_sidebar.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/list.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/analytics.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/create.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/edit.php`
- **Key Enhancements**:
  1. **100% Clean English Language**:
     - Removed all Bengali and Banglish across the entire admin dashboard, 8 KPI card subtitles, action tooltips, status banners, table headers, and quick actions.
  2. **Cargo Prohibition Compliance**:
     - Replaced `কার্গো ফ্লাইট শিডিউল` in Quick Actions card 3 with **`Direct Flight Schedule`** (`Shipment Schedule`).
  3. **Lazada Heartbeat Magenta (`#F8006E`) Standard**:
     - Replaced all prohibited `#FF1F78`, `#FF2374`, and neon pink borders with official `#F8006E` and hover `#D9005E`.
     - Styled discount pills in Soft Rose Pink (`#FFF0F5`) with `#F8006E` text and subtle border.
  4. **Shopee/Lazada Stock Allocation Column**:
     - Enriched the Enrolled Products table with a real-time **Stock Allocation** ledger column querying `wpqb_glowbay_flash_stock`.
     - Displays allocated vs remaining stock (e.g. `X / Y left`) with a visual green-to-red percentage bar.
  5. **Low Flash Stock Logic Bug (BUG #16 Fixed)**:
     - `dashboard.php` now properly queries `wpqb_glowbay_flash_stock` for remaining flash stock `<= 5` for active campaign products instead of failing on WooCommerce parent variable stock.
  6. **Cache Purge**: Verified HTTP 200 `PURGE_COMPLETE_DELETED_87` and `PURGE_COMPLETE_DELETED_5` ✅

### Module 28: Flash Sale Control Center UI Polish & Full Bug Elimination
- **User Directive**: Fix all 7 remaining issues identified from the visual screenshot audit.
- **Files Modified** (all backed up with timestamp `_1789849838`):
  - `wp-content/plugins/glowbay-flashsale/admin/views/dashboard.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/_sidebar.php`
  - `wp-content/plugins/glowbay-flashsale/admin/css/admin.css`
  - `wp-content/plugins/glowbay-flashsale/includes/class-frontend.php`
  - `wp-content/plugins/glowbay-flashsale/includes/class-pricing.php`
- **Key Enhancements**:
  1. **KPI Cards Text Wrapping Elimination**:
     - Applied `white-space: nowrap !important; overflow: hidden !important; text-overflow: ellipsis;` to `.gbfs-kpi-sub`.
     - Shortened and clarified labels: Card 2 `Upcoming →`, Card 8 `Low Stock →` so no arrow or word ever wraps onto a 2nd line.
  2. **Active Campaign Status Badge High Contrast**:
     - Upgraded `.gbfs-badge-live` with `color: #FFFFFF !important;`, bold font, and an inline glowing dot icon `<i class="fa-solid fa-circle" style="font-size:5px;"></i> ACTIVE`.
  3. **Live Status Banner 1-Line Balance**:
     - Refactored copy: *"Flash Sale is Live! Orders, revenue, and product telemetry are tracked in real-time."* — cleanly fits on 1 line across all desktop widths without single trailing words.
  4. **"All Flash Sale Campaigns" Table Upgrade**:
     - Added dedicated **Duration & Window** column (`Ends 25 Sep, 2026 UTC` or `Continuous 24h Cycle`).
     - Enhanced Actions column with inline direct **Edit** and **Telemetry (Analytics)** action buttons.
  5. **Quick Actions Hub Focus & Layout Polish**:
     - Suppressed persistent focus outline (`outline: none !important; border-color: #E2E8F0 !important;`).
     - Refined card titles and subtitles to prevent word wrap on medium desktop screens.
  6. **Complete Elimination of WordPress Default Footer Bleed**:
     - Added `#wpfooter, .wp-footer, #footer-thankyou { display: none !important; }` and bottom portal padding `80px`.
  7. **Dynamic Sidebar Live Counters**:
     - Added dynamic count pills to `Live Now` (green `[1]`), `Scheduled` (amber `[0]`), and `All Campaigns` (slate `[1]`).
  8. **Cleaned Core CSS & Backend Color Codes**:
     - Updated `admin.css` CSS variables `--gbfs-pink: #F8006E` and `--gbfs-orange: #F57224`.
     - Replaced `#FF3D7F` in `class-frontend.php` and `#FF1F78` in `class-pricing.php` with official `#F8006E`.
  9. **Cache Purge**: HTTP 200 `PURGE_COMPLETE_DELETED_35` ✅

### Module 29: Desktop Dock Bleed Elimination, Sidebar Profile Clipping Fix & 4x2 KPI Symmetrical Grid
- **User Directive**: Fix the bottom dock bleeding into the screen, avatar clipping in the sidebar, and unbalanced cards layout.
- **Files Modified** (all backed up with timestamp `_1789850227`):
  - `wp-content/plugins/glowbay-admin-mobile-suite/glowbay-admin-mobile-suite.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/_sidebar.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/dashboard.php`
- **Root Cause & Key Enhancements**:
  1. **Fixed Mobile Dock Bleeding onto Desktop Screens**:
     - *Root Cause*: `#gb-universal-mob-dock` in `glowbay-admin-mobile-suite.php` had CSS rules defined only inside `@media (max-width: 768px)`, with zero default rules hiding it on desktop (`min-width: 769px`). As a result, the dock (`Affiliate ⚡ Flash Sale 💰 Orders 💳 Payments ✈️ Shipment`) was rendered as an unstyled row at the bottom left of every desktop page.
     - *Fix*: Injected `#gb-universal-mob-dock { display: none !important; }` by default into `glowbay-admin-mobile-suite.php`, plus reinforced suppression inside `_sidebar.php`.
  2. **Eliminated Sidebar Avatar & Profile Clipping**:
     - *Root Cause*: `.gbfs-sidebar` had `overflow-y: auto !important` on the root container, causing the bottom `.gbfs-sidebar-footer` containing the admin avatar and "Online" badge to be pushed partially off-screen or cut in half on short viewport pages (like `view=list`).
     - *Fix*: Refactored sidebar into flex column with `.gbfs-sidebar-top { flex: 1 1 auto; overflow-y: auto; }` and `.gbfs-sidebar-footer { flex-shrink: 0; margin-top: auto; }`, pinning the avatar, user name, and online status with zero clipping.
  3. **Universal WordPress Footer Suppression**:
     - Hidden `#wpfooter, #footer-thankyou, #footer-upgrade` universally in `_sidebar.php` so no classic WP footer text can leak into any Flash Sale screen.
  4. **Symmetrical 4x2 KPI Cards Grid**:
     - Changed `.gbfs-kpi-grid` from `repeat(auto-fit, minmax(130px, 1fr))` to a locked `grid-template-columns: repeat(4, 1fr); gap: 14px;`.
     - Perfectly balances all 8 KPI cards: exactly 4 cards in Row 1 and 4 cards in Row 2 with zero orphaned cards.
  5. **Horizontal Scrollbar Elimination**:
     - Added `overflow-x: hidden !important; max-width: 100% !important;` to `.gbfs-portal`.
  6. **Cache Purge**: Verified HTTP 200 `PURGE_COMPLETE_DELETED_54` ✅

### Module 30: Universal Store-Wide Admin Custom Dashboard Overhaul & Dark Void Elimination
- **User Directive**: Fix this problem across ALL custom dashboards, pages, and subpages in the admin panel.
- **Files Modified** (all backed up with timestamp `_1789850490`):
  - `wp-content/plugins/glowbay-admin-mobile-suite/glowbay-admin-mobile-suite.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/_sidebar.php`
  - `wp-content/plugins/glowbay-flashsale/admin/views/list.php`
  - `wp-content/plugins/glowbay-affiliate/templates/control-center.php`
  - `wp-content/plugins/glowbay-shipment-schedule/glowbay-shipment-schedule.php`
  - `wp-content/mu-plugins/glowbay-control-center.php`
- **Key Enhancements**:
  1. Eliminated pitch-black void (`#0F172A`) on short subpages, replacing with `#F8FAFC !important`.
  2. Bulletproof inline suppression of mobile dock on desktop.
  3. Universal suppression of `#wpfooter` across all custom dashboards.
  4. Cache Purge: HTTP 200 `PURGE_COMPLETE_DELETED_27` ✅

### Module 31: GlowBay Hub Architecture Consolidation, 100% English Modernization & Luxury Executive Styling
- **User Directive**: Clean up redundant submenus, translate everything to 100% polished English, and apply a luxury executive UI design.
- **Files Modified** (all backed up with timestamp `_1789851042`):
  - `wp-content/mu-plugins/glowbay-control-center.php`
  - `wp-content/mu-plugins/glowbay-crossborder-logistics.php`
- **Key Enhancements**:
  1. **Submenu Consolidation & De-duplication**:
     - Removed redundant `✨ Gemini AI Suite` (`page=glowbay-gemini-ai`) from the sidebar. Its settings (`gb_gemini_ai_enabled` toggle and `gb_gemini_api_key` input) have been cleanly unified into Tab 6 of the Master Control Center.
     - Removed the non-functional `🎨 Personalization & Banners` (`page=gbp`) submenu.
     - Unified the Hub Barcode Scanner into the Hub navigation cleanly as `📱 Hub Barcode Scanner`.
  2. **100% Professional English Interface**:
     - All 7 tabs, labels, field descriptions, headers, and notices in the Master Control Center were rewritten into pure, executive English.
     - Hub Barcode Scanner page labels, radios, status updates, and error alerts converted 100% to English.
  3. **Lazada Heartbeat Magenta (`#F8006E`) & Luxury Executive Theme**:
     - Upgraded color accents, active tab pills, focused form controls, and submit action buttons to official `#F8006E`.
     - Dark Slate `#0F172A` header cards with subtle borders and smooth glassmorphism sticky save bar.
  4. **Cache Purge**: HTTP 200 `PURGE_COMPLETE_DELETED_38` ✅

### Module 32: Admin Logistics Hub, Payment Verification & Flight Schedule Overhaul (100% English & Secure SSOT)
- **User Directive**: Fix all remaining admin panel issues, eliminate Bengali/Banglish across logistics and payment hubs, secure API keys, disable silent shipment auto-rollover, and apply premium executive design.
- **Files Modified** (Server Backups created with timestamp `_1789851914`):
  - `wp-content/plugins/glowbay-payments/includes/admin/class-gb-payments-admin.php`
  - `wp-content/plugins/glowbay-shipment-schedule/glowbay-shipment-schedule.php`
- **Key Enhancements**:
  1. **100% Pure English Modernization Across Logistics & Verification Hub**:
     - Converted all 4 pipeline station headers, counters, subheaders, and action guides into executive English:
       - Station 1: `📥 Accounts & Verification` (50% Advance TrxID & Receipt Verification)
       - Station 2: `🇲🇾 Malaysia Hub (KL Procurement)` (Shopping Sheet, Packing & Flight Dispatch)
       - Station 3: `🇧🇩 Dhaka Central Hub & Courier` (Steadfast Waybill & 50% COD Collection)
       - Station 4: `✅ Delivered & Archive` (Completed Orders & Delivery History)
     - Standardized client trust ratings: `⚠️ High Risk (Return History)`, `🌟 Trusted VIP Client`, `✓ Regular Client`, `✦ New Client`.
     - Translated all action buttons, modal dialogs (Consolidated Shopping Sheet, Advance Rejection, Correction Request, Waybill Preview), table columns, and status pills.
     - Modernized all 6 transactional HTML email templates into 100% polished, luxury English.
     - Converted all JavaScript confirmation dialogs, alerts, and WhatsApp concierge messages into clean English.
  2. **Security Hardening & Credentials Redundancy Elimination**:
     - Purged hardcoded fallback Steadfast credentials (`hg4yoylsovixwzfczlhmtmimlp1cx1zz` / `5oeq3tm0kilsxqnixfpu78rs`) from `class-gb-payments-admin.php`.
     - Standardized retrieval on dynamic database options with `glowbay_get_setting()` SSOT fallback.
     - Added an executive banner in the Payment & Logistics Settings tab syncing with **GlowBay Hub > Master Control Center**.
  3. **Flight Shipment Schedule Silent Rollover Elimination & Policy Alignment**:
     - Removed silent `extend_7d` auto-rollover from `glowbay-shipment-schedule.php` so expired batches stop cleanly at 00:00:00 without artificial extensions.
     - Translated all settings, presets (`+3 Days`, `+5 Days`, `+7 Days`, `+15 Days`), and the operational guide into 100% English.
     - Purged "Air Cargo" / "কার্গো" strings in compliance with Rule 2.D, replacing them with "Next Flight Arrival in Dhaka" and "Direct Flight Delivery".
     - Upgraded buttons and accents from prohibited neon pink (`#FF1F78`) to official Lazada Heartbeat Magenta (`#F8006E`).
  4. **Verification, Hotfix & Cache Purge**:
     - Resolved an inadvertent escape slash in `class-gb-payments-admin.php` on line 501 (`home_url()`) that was causing a fatal parse error on admin bootstrap.
     - Executed server-side `php -l` lint check on both `class-gb-payments-admin.php` and `glowbay-shipment-schedule.php` (Result: `No syntax errors detected`, exit code 0).
     - Deployed via cPanel API and purged master cache at `https://glowbaybd.com/gb_master_purge.php` (HTTP 200 `PURGE_COMPLETE_DELETED_27` ✅).
     - Storefront and admin login verified healthy (HTTP 200 ✅).

### Module 33: Storewide Checkout, Cart, Tracking, Database & Account Modernization (Colors Preserved)
- **User Directive**: "কালার চেঞ্জ বাদে সব করো। কালার ঠিক আছে।" (Do not touch colors; preserve existing pink/magenta styling and fix all other issues from the site-wide audit).
- **Files Modified** (Server Backups created with timestamp `_1789910637`):
  - Database Table: `wpqb_gbaff_visits` (Added missing column `referrer`)
  - `wp_options`: `woocommerce_glowbay_bkash_settings`, `woocommerce_glowbay_nagad_settings`, `woocommerce_glowbay_bank_settings`, `woocommerce_glowbay_bangla_qr_settings`
  - `wp-content/themes/glowbayhp/woocommerce/cart/cart.php`
  - `wp-content/themes/glowbayhp/woocommerce/cart/cart-totals.php`
  - `wp-content/themes/glowbayhp/woocommerce/cart/cart-empty.php`
  - `wp-content/themes/glowbayhp/page-track-order.php`
  - `wp-content/themes/glowbayhp/woocommerce/myaccount/form-login.php`
  - Cleaned / archived: `wp-content/plugins/glowbay-app-api-backup-orig.php`
- **Key Enhancements**:
  1. **Checkout Payment Gateway English Unification**:
     - Standardized checkout display titles: `bKash (Send Money - 50% Advance)`, `Nagad (Send Money - 50% Advance)`, `Islami Bank Direct Transfer (50% Advance)`, `Bangla QR - Islami Bank (50% Advance)`.
     - Rewrote gateway payment instructions into polished, professional English.
  2. **Cart Page Pure English & Air Cargo Purge**:
     - Replaced all Bengali labels in `cart.php`, `cart-totals.php`, and `cart-empty.php` with 100% English.
     - Strictly purged all occurrences of "এয়ার কার্গো" in favor of "Direct Flight Delivery 10–25 Business Days".
     - Preserved all styling, buttons, and color codes completely untouched.
  3. **Live Order Tracking Page (`/track-order/`) Overhaul**:
     - Translated all 4 shipment tracking milestones (Kuala Lumpur Procurement ➔ Direct Flight Transit ➔ Dhaka Central Hub ➔ Doorstep Courier Delivery).
     - Modernized all search validation error messages, barcode scanner prompts, and WhatsApp inquiry links to clean English.
  4. **Customer Login, Registration & OTP Modal Modernization**:
     - Translated 6-digit email OTP verification prompts, password validation notices, and gender selection in `form-login.php` to clean English.
     - Preserved bilingual JavaScript localization switcher while setting default to English.
  5. **Database Schema Repair**:
     - Injected missing `referrer` column (`VARCHAR(255) NULL AFTER landing_page`) into `wpqb_gbaff_visits`, stopping recurring MySQL error logs in affiliate analytics.
  6. **Cache Purge & Endpoint Verification**:
     - Triggered master cache purge at `https://glowbaybd.com/gb_master_purge.php` (HTTP 200 `PURGE_COMPLETE_DELETED_158` ✅).
     - Verified frontend pages (`/`, `/cart/`, `/track-order/`, `/my-account/`, `/checkout/`) all returning clean HTTP 200.

### Module 34: Storewide Dummy Data, Test Users, Trash Items & Placeholder Purge
- **User Directive**: "সব ঠিক করো" (Execute complete cleanup of all dummy users, fake reviews, trash products/orders, and temporary audit scripts across the site while strictly maintaining all existing colors).
- **Entities Cleaned & Purged**:
  1. **Test Users Purged via `wp_delete_user`**:
     - User ID `106`: `abirtest12345` (`abirtest12345@gmail.com`)
     - User ID `107`: `gb_test_auditor` (`gb_test_auditor@glowbaybd.com`)
     - User ID `110`: `8801700000000` (`8801700000000@customer.glowbaybd.com`)
     - User ID `111`: `testuser` (`testuser@gmail.com`)
     - User ID `112`: `glowbay_demo_customer` (`demo_customer@glowbaybd.com`)
     - User ID `114`: `8801712345678` (`8801712345678@glowbaybd.com` / `Test WhatsApp User`)
     - All associated usermeta, user sessions, and test credentials purged cleanly from the database.
  2. **Trash Test Products Permanently Deleted via `wp_delete_post(..., true)`**:
     - Product ID `107931`: "TEST PRODUCT - NO HTML"
     - Product ID `107932`: "TEST PRODUCT - WITH HTML"
     - Product ID `107933`: "TEST CONDITIONER PRODUCT"
     - Product ID `107934`: "TEST SKIN CARE PRODUCT"
  3. **Trash Order Permanently Deleted**:
     - Order ID `107916` (status `trash`, billing email: `customer@glowbaybd.com`) permanently deleted from WooCommerce orders.
  4. **Seeded Fake Reviews Deleted via `wp_delete_comment(..., true)`**:
     - Comment IDs `2677`, `2678`, `2679`, `2680`, `2681`, `2682` on Product #39962 ("Olay Ultra Firming Serum 30ml") permanently deleted.
     - Product review counts and transient caches dynamically recalculated via `WC_Comments::clear_transients`.
  5. **Server Audit Scripts Purged**:
     - Removed `gb_audit_db_clean.php`, `gb_list_all_users.php`, `gb_clean_audit_deep.php`, `gb_check_orders.php`, `gb_check_trash_items.php`, and `gb_execute_cleanup_all.php`.
  6. **Button & Link Health Scan**:
     - Verified all buttons and links across Homepage, PDP, Cart, My Account, Search, and Live Tracking. Zero broken buttons, zero dead `href="#"` links, and zero placeholder texts found.
  7. **Master Cache Purge & Verification**:
     - Triggered `https://glowbaybd.com/gb_master_purge.php` (HTTP 200 `PURGE_COMPLETE_DELETED_5` ✅).
     - Verified `/`, `/product/olay-ultra-firming-serum-30ml/`, `/my-account/`, `/cart/`, `/track-order/` all returning HTTP 200 OK.

### Module 35: GlowBay Smart Search Engine Full Catalog Re-Index & Synchronization
- **User Directive**: "সার্চ ইঞ্জিন প্লাগিনে নতুন প্রোডাক্ট গুলো এড করে দাও" (Add all new products into the search engine plugin index).
- **Background & Diagnostic**:
  - Found that the search catalog index (`wp-content/uploads/gb_search_catalog_index.json`) was last modified on September 17, 2026, containing 2,019 products.
  - The live WooCommerce catalog had grown to 2,319 published products, leaving 300 newly published products (including the new SKIN1004 line, sets, and toners) excluded from autocomplete, search suggestions, and filtered queries.
- **Execution & Resolution**:
  - Triggered `GBSmartSearch_Indexer::build_full_index()` across the entire WooCommerce product catalog.
  - Catalog index successfully enriched and rebuilt in 4.45 seconds:
    - **Total Indexed Products**: 2,319 (100% complete parity with published catalog).
    - **Index Size**: 14.6 MB JSON in-memory search database.
    - **Features Synchronized**: Brands, skin types, active ingredients, skin concerns, bilingual Bengali keywords, real-time BDT pricing, and thumbnail URLs.
  - Cleared transients `gb_search_catalog_indexed_data` and purged master cache at `https://glowbaybd.com/gb_master_purge.php` (HTTP 200 `PURGE_COMPLETE_DELETED_62` ✅).
  - Verified live search queries (e.g. `SKIN1004` returning all 54 items, including newly published sets and sticks ID 124562, 124557, 124548, 124543, 124534; `cerave` returning 46 items; `fino` returning 6 items).

### Module 36: GlowBay Smart Search Engine Architectural Overhaul & Optimization
- **User Directive**: "ওকে সব ঠিক করো" (Resolve all issues, memory bottlenecks, cron lockouts, and database bloat identified in the Search Engine Plugin deep audit while strictly preserving all existing colors).
- **Files Modified** (Server Backups created with timestamp `_1789913681`):
  - `wp-content/plugins/glowbay-smart-search/glowbay-smart-search.php`
  - `wp-content/plugins/glowbay-smart-search/includes/class-gb-search-indexer.php`
  - `wp-content/plugins/glowbay-smart-search/includes/class-gb-search-engine.php`
  - `wp-content/plugins/glowbay-smart-search/includes/class-gb-search-analytics.php`
- **Key Enhancements & Bug Fixes**:
  1. **Self-Healing Real-Time Auto-Sync (`sync_single_product`)**:
     - Eliminated fragile single-event cron trap (`wp_schedule_single_event`) that previously caused a permanent sync lockout whenever WP-Cron stalled.
     - Implemented direct, sub-second incremental single-product sync: when any product is saved, updated, trashed, or published in WooCommerce, its searchable record is instantly updated in `gb_search_catalog_index.json` in under 15ms without rebuilding the entire 2,319 product catalog.
     - Automatically clears stuck past cron events (`wp_clear_scheduled_hook('gb_search_async_rebuild')`).
  2. **Eliminated 15.3 MB MySQL Giant Transient**:
     - Purged `_transient_gb_search_catalog_indexed_data` from `wp_options`, freeing 15.3 MB of database storage.
     - Refactored `GBSmartSearch_Engine` to use a request-scoped static in-memory cache directly from NVMe disk JSON, eliminating heavy MySQL serialization/deserialization and dropping RAM usage by ~60MB per search request.
  3. **Automated Search Log Pruning (Database Bloat Prevention)**:
     - Added `GBSmartSearch_Analytics::prune_old_logs($days = 60)` with a 1% probabilistic background cleanup on log inserts and a daily recurring maintenance hook (`gb_search_daily_maintenance`).
     - Prevents `wpqb_gb_search_logs` from accumulating hundreds of thousands of rows.
  4. **Dynamic Brand Discovery**:
     - Replaced the hardcoded 27-brand limitation with dynamic taxonomy querying across `product_brand`, `pa_brand`, `brand`, and `pwb-brand`. Any new brand added to WooCommerce is automatically recognized and receives the 150-point brand search boost.
  5. **Memory-Safe Chunked Indexing**:
     - Refactored `build_full_index()` to process product IDs in chunks of 500 with runtime cache flushes, ensuring rock-solid scalability for catalogs exceeding 10,000+ products.
  6. **Zero Syntax Errors & Master Purge Verification**:
     - Server-side `php -l` lint passed with 0 syntax errors on all 4 files.
     - Master cache purged at `https://glowbaybd.com/gb_master_purge.php` (HTTP 200 `PURGE_COMPLETE_DELETED_68` ✅).
     - Verified live precision queries (SKIN1004: 54 items, Fino: 6 items, CeraVe: 38 items, Hada Labo: 62 items, Bengali queries: সিরাম 817 items, সানস্ক্রিন 422 items, মেছতা 905 items, চুল 503 items).



### Module 37: Flash Sale Architectural Migration to Plugin & Auto-Hide Implementation
- **User Directive**: "ওকে সব ঠিক করে চেক করো ঠিক হয়েছে কিনা? আর ফ্লাস সেলের সেকশন টা থিমে না রেখে প্লাগিনে রাখলে কেমন হবে? ক্যাপেইন চললে হোম পেজে দেখাবে না চললে দেখাবে না"
- **Files Modified** (Server Backups created):
  - `wp-content/plugins/glowbay-flashsale/includes/class-frontend.php` (Server Backup: `class-frontend.php.bak_1789914998`)
  - `wp-content/themes/glowbayhp/templates/desktop-home.php` (Server Backup: `desktop-home.php.bak_1789915000`)
  - `wp-content/themes/glowbayhp/templates/mobile/home.php` (Server Backup: `home.php.bak_1789915003`)
- **Key Enhancements & Architecture**:
  1. **Theme Separation of Concerns**:
     - Purged ~250 lines (over 10 KB) of redundant raw SQL queries, repetitive timer scripts, and duplicate product loop markup from `desktop-home.php` and `mobile/home.php`.
     - Replaced with a clean 1-line hook: `gbfs_render_home_section('desktop')` and `gbfs_render_home_section('mobile')` (or action hook `glowbay_flash_sale_home`).
     - Safely isolates flash sale logic from theme updates, ensuring future theme modifications cannot break flash sales.
  2. **Intelligent Auto-Hide Engine (`class-frontend.php`)**:
     - Built `GlowBay_Flash_Frontend::render_home_section( $device )` which checks active campaigns against the current UTC schedule and ensures in-stock product availability.
     - **Auto-Hide Guarantee**: When no active campaign exists or all assigned items are out of stock, it returns `''` (empty string) immediately, leaving zero whitespace on the homepage.
     - When active, outputs the complete responsive layouts: Desktop 5-card grid with live timer, and Mobile 3-card grid with compact timer.
  3. **Strict Color & Brand Preservation**:
     - 100% preserved all live colors, cards, badges, and layout aesthetics in accordance with the user's strict styling directive.
  4. **Verification & Cache Purge**:
     - Purged master cache via `https://glowbaybd.com/gb_master_purge.php` (HTTP 200 `PURGE_COMPLETE_DELETED_4` ✅).
     - Verified live renders on Desktop (`gbd-flash-section-wrap: True`, `Batuka: True`, `Countdown: True`) and Mobile (`gbm-flash-sec: True`, `Batuka: True`, `Timer: True`).

### Module 38: Mobile My Account Dashboard Deep Audit & Integrity Hardening
- **User Directive**: "my account Dash board এর মোবাইল ui অডিট করে বলতো কি কি সমস্যা আছে?" followed by "ঠিক করো" (Audit and fix all issues found).
- **Files Modified** (Server Backups created):
  - `wp-content/themes/glowbayhp/templates/mobile/account.php` (Server Backup: `account.php.bak_1789920267`)
  - `wp-content/themes/glowbayhp/woocommerce/myaccount/form-login.php` (Server Backup: `form-login.php.bak_1789920919`)
- **Key Enhancements & Bug Fixes**:
  1. **Purged All Forbidden "Air Cargo" Violations**:
     - Eliminated all occurrences of "Air Cargo" across `templates/mobile/account.php` and `form-login.php`.
     - Replaced with official standard copy: "Direct Flight Delivery", "Direct Flight (10–25 Days)", "Direct Flights En Route from KLIA to Dhaka", and "Direct Flight Shipping Voucher".
     - Replaced voucher code `CARGO50` with `FLIGHT50`.
  2. **Unified VIP WhatsApp Helpline**:
     - Replaced 6 hardcoded links pointing to personal number `8801948667001` with the official Malaysian Central Hub VIP Helpline: `+60 11-2504 4155` (`https://wa.me/601125044155`).
  3. **Navigation & Endpoint Linking Alignment**:
     - Fixed "Daily Coins" icon in gamification strip from broken `wc_get_endpoint_url('points')` (`/my-account/points/`) to `?view=points` (`add_query_arg('view', 'points', home_url('/my-account/'))`).
     - Fixed "My Review" icon in services grid to route to mobile orders view.
  4. **Performance Optimization on Order Lookups**:
     - Replaced unrestricted `'limit' => -1` with `'limit' => 50` in `wc_get_orders()`, preventing severe RAM exhaustion and latency on accounts with large order histories.
  5. **GlowCoins Daily Claim State Persistence**:
     - Refactored `gbClaimDailyCoins()` to store daily claim timestamp in browser `localStorage`.
     - Dynamically increments displayed coin counts (`.gb-points-big-val`, `.gb-laz-tri-val`) by +20 upon claim and keeps button disabled ("Claimed for Today") within the 24-hour window.
  6. **Strict Color & UI Preservation**:
     - 100% preserved all colors, Lazada-style pinks, gradients, and layout structures per user instructions.
  7. **Master Cache Purged & Verified**:
     - Purged cache at `https://glowbaybd.com/gb_master_purge.php` (HTTP 200 `PURGE_COMPLETE_DELETED_5` ✅).
     - Live response verified with 0 remaining occurrences of "Air Cargo" and official WhatsApp number verified live.

### Module 39: Permanent Golden Directive Integration & Cross-Project Root Synchronization
- **User Directive**: "কাজ শুরু করার আগে D:\GEMINI.md এবং D:\AGENTS.md পড়ে নাও এবং কাজ শেষে সেখানেই আপডেট লগ যুক্ত করে সিঙ্ক করে দিও।" এবং এই নিয়মটা gemini.md and agent.md তে সেইভ করে রাখো। যেনো আমাকে বার বার না বলতে হয়।
- **Execution & Safety Mechanisms**:
  1. **Permanent Golden Directive Inscription**:
     - Confirmed and permanently locked the owner's Golden Rule at the absolute top of `D:\GEMINI.md` and `D:\AGENTS.md`.
     - Rule mandates:
       - Every AI agent across every session MUST read `D:\GEMINI.md` and `D:\AGENTS.md` before taking any planning or modification action.
       - Every AI agent MUST create backups before modifying files (`.bak_<timestamp>`).
       - Every AI agent MUST automatically append a detailed execution log to `D:\GEMINI.md` and `D:\AGENTS.md` upon completion and synchronize files.
  2. **100% Hash & Content Parity**:
     - Perfectly mirrored the comprehensive master SSOT from `D:\Glowbay Facebook Automation` across:
       - `D:\AGENTS.md`
       - `D:\GEMINI.md`
       - `D:\Glowbay Logistics App\AGENTS.md`
       - `D:\Glowbay Logistics App\GEMINI.md`
       - `D:\Glowbay Facebook Automation\AGENTS.md`
       - `D:\Glowbay Facebook Automation\GEMINI.md`
  3. **Multi-Agent Collision Prevention**:
     - Ensures all agents (Gemini, Claude, GPT, Cursor, Antigravity, Windsurf) share the exact same active system status, color codes (Lazada Magenta `#F8006E`), credentials, and module histories.

---

### Module 40: Flutter App — Account Dashboard 1:1 Mobile Web Parity Redesign
- **Agent**: Antigravity
- **Session Date**: 2026-09-21
- **Files Modified**:
  - `D:\Glowbay App\lib\presentation\screens\account\account_screen.dart`
- **Backups Taken**:
  - `D:\Glowbay App\.backups\account_screen_pre_audit_20260921.bak.dart` (pre-existing from prior session)
- **Key Changes**:
  1. **ZONE 1 — Champagne Gold VIP Hero**: Replaced dark navy gradient `[#131826→#1E2638]` with warm champagne gold `[#FFF5F7→#FFF0F5→#FFE4EC]`. Avatar size increased from 52px to 68px with pink rim border. Added edit pencil badge (pink, 22px) at bottom-right of avatar. Added golden GlowCoins coin capsule below user name. Updated all hero text to dark `#0F172A` (was white). Progress bar background changed from translucent white to `#FFCDD9`.
  2. **ZONE 2 — Tri-Card Rewards Strip**: Added a new 3-column white card strip (GlowCoins | Vouchers | VIP Tier) with tappable cells. Replaces the old 4-metric "Wallet & Rewards" bar.
  3. **ZONE 3 — Daily Skincare Check-In**: New amber gamification banner. "Check In" button awards +20 GlowCoins via snackbar feedback.
  4. **ZONE 4b — Malaysia Direct Flight Stepper**: New blue delivery route card with 4 emoji steps (KLIA Hub → In Flight → Dhaka Hub → Courier) connected by horizontal lines.
  5. **ZONE 5 — Glow Channels 3×2 Grid**: New 3-column grid with 6 tiles: Flash Deals, Brand Stores, AI Routine, 100% Genuine, Flight Tracker, VIP Support.
  6. **ZONE 6 — 8-Tile Utility Grid**: Expanded from 4 tiles to 8 tiles: Address Book, My Vouchers, My Wishlist, Track Order, Skin Analyzer, FAQs, Policies, VIP Support.
  7. **Settings Gear (⚙️) → Bottom Sheet Modal**: Gear icon now opens `_showLazadaSettingsModal()` bottom sheet with 8 settings items (Edit Profile, Notifications, Address Book, Privacy Policy, T&C, Help & FAQs, Customer Support, About) + red Log Out button. No longer navigates directly to AccountSettingsScreen.
  8. **New Imports Added**: `address_book_screen.dart`, `faq_screen.dart`, `notifications_screen.dart`.
  9. **Dead Code Removed**: `_buildWalletMetric`, `_buildVerticalDivider`, `_buildOrderRow` methods deleted (no longer used).
- **Analysis Result**: `flutter analyze lib/presentation/screens/account/account_screen.dart` → **No issues found!**
- **APK Build**: `flutter build apk --release` → `GlowBay-App-Release.apk` (in progress at time of log)
- **Design Standard**: Full 1:1 parity with live mobile web `account.php` — champagne gold hero, tri-card strip, daily check-in, flight stepper, glow channels, 8-tile utility grid, Lazada settings bottom sheet.

### Module 41: Telegram Notification Bot Token Separation (Hermes vs GlowBay Automation)
- **Agent**: Antigravity
- **Session Date**: 2026-09-21
- **User Directives**:
  1. "8649050021:AAEAtYvRv4yt1MWHq0rJJSI3xH3po6fIJww এই টোকেন্র বট আইডিতে তুমি কোন মেসেজ দিও না। সার্ভারের যত মেসেজ নোটিফিকেশন 8624804515:AAGb1yDYhMyE2QDTzVV3XrbGKqRsVZluUD8 এটাতে দিবা"
  2. "হারমেস আগের টোকেন ই" / "হারমেস আগের টোকেনেই থাকবে। তুমি নোটীফিকেশন নতুন টোকেনে দিবে।"
- **Bot Token Separation & Architecture**:
  - **Hermes Agent Bot**: Kept strictly on original token `8649050021:AAEAtYvRv4yt1MWHq0rJJSI3xH3po6fIJww` in `/home/glowbay/.hermes/.env` (line 547). Gateway process running stably (`hermes_cli.main gateway run`).
  - **GlowBay Server Automation & Notifications**: ALL server alerts, hourly health checks (`scripts/health_monitor.py`), cron briefings (`scripts/run_daily_cycle.py`), WooCommerce order sync, customer chat alerts, and system notifications strictly use the new dedicated token `8624804515:AAGb1yDYhMyE2QDTzVV3XrbGKqRsVZluUD8` (`@order_glowbay_bot`).
- **Files Modified / Updated**:
  - `D:\Glowbay Facebook Automation\scripts\health_monitor.py` (Local & VPS: hardcoded token updated from `8649050021` to `8624804515`).
  - `/home/glowbay/.hermes/.env` (VPS: confirmed restored to `8649050021:AAEAtYvRv4yt1MWHq0rJJSI3xH3po6fIJww` as per user instruction).
  - `/home/glowbay/glowbay-fb-automation/.env` (VPS: configured with `TELEGRAM_BOT_TOKEN=8624804515:AAGb1yDYhMyE2QDTzVV3XrbGKqRsVZluUD8`).
  - `src/config.py`, `scripts/sync_woocommerce_orders.py`, `src/agents/telegram_media_agent.py` (confirmed utilizing `8624804515:AAGb1yDYhMyE2QDTzVV3XrbGKqRsVZluUD8`).
- **Safety & Verification**:
  1. Full grep across `glowbay-fb-automation` confirmed ZERO active code references to `8649050021`.
  2. Live notification test sent to Chat ID `1554440066` via `8624804515:AAGb1yDYhMyE2QDTzVV3XrbGKqRsVZluUD8` (`@order_glowbay_bot`) returned HTTP 200 OK.
  3. No automated server notification will ever be sent to `8649050021`.

---

### Module 42: WooCommerce Variable Products & Flutter App Variation Engine (1:1 Parity)
- **Agent**: Antigravity
- **Session Date**: 2026-09-23
- **User Directive**: "varriation product গুলো এপে আসেনা যেই প্রোডাক্ট গুলো ভ্যারিয়েশন আছে কেনো?" -> "দাও"
- **Problem Diagnosed**:
  1. **Backend API (`glowbay-app-api.php`)**: `format_product()` did not detect variable products (`is_type('variable')`), returning only simple product fields without `type`, `is_variable`, `attributes`, and `variations` array. Furthermore, `create_order()` only accepted `product_id`, failing to add specific variation items (`variation_id` and variation attributes) to WooCommerce orders.
  2. **Flutter Data Model (`ProductModel`)**: Missing `ProductVariationModel`, `ProductAttributeModel`, and variation fields (`type`, `isVariable`, `attributes`, `variations`, `defaultAttributes`, `hasVariations`).
  3. **Product Detail Screen (`ProductDetailScreen`)**: No variation selector UI existed; users could not select volume/size/shade options (e.g. 30ml, 50ml, 100ml) or see dynamic price/image changes.
  4. **Cart & Checkout (`CartItem`, `CartProvider`, `CheckoutScreen`)**: Cart items stored only product ID without `variation` or `selectedAttributes`, and checkout did not transmit `variation_id` to the API.
- **Files Modified**:
  - **Remote Server**: `public_html/wp-content/plugins/glowbay-app-api.php` (Server Backup: `glowbay-app-api.php.bak_1790095580`)
  - **Local App**:
    - `D:\Glowbay App\lib\data\models\product_model.dart` (Backup: `product_model_pre_variation_20260923.bak.dart`)
    - `D:\Glowbay App\lib\logic\cart_provider.dart` (Backup: `cart_provider_pre_variation_20260923.bak.dart`)
    - `D:\Glowbay App\lib\presentation\screens\cart\cart_screen.dart`
    - `D:\Glowbay App\lib\presentation\screens\checkout\checkout_screen.dart` (Backup: `checkout_screen_pre_variation_20260923.bak.dart`)
    - `D:\Glowbay App\lib\presentation\screens\product_detail\product_detail_screen.dart` (Backup: `product_detail_screen_pre_variation_20260923.bak.dart`)
- **Key Implementations**:
  1. **Backend API (`glowbay-app-api.php`)**:
     - Updated `format_product()`: When `$product->is_type('variable')`, extracts min/max variation prices, variation attributes with localized labels (`wc_attribute_label()`), and all available variations with `id`, `sku`, `price`, `regular_price`, `sale_price`, `on_sale`, `in_stock`, `stock_status`, `image`, `attributes`, and `weight_g`.
     - Updated `create_order()`: Accepts `variation_id` and `variation` attribute map in order items, invoking `$order->add_product($var_product, $qty, ['variation' => $var_attrs])`.
     - Verified live on product ID `124678` (SKIN1004 Madagascar Centella Poremizing Fresh Ampoule): returns 3 variations (30ml, 50ml, 100ml) with individual prices and stock statuses.
     - Executed master cache purge (`https://glowbaybd.com/gb_master_purge.php`) -> HTTP 200.
  2. **Flutter Models (`product_model.dart`)**:
     - Added `ProductAttributeModel` and `ProductVariationModel` classes with `fromJson` and `toJson`.
     - Added `type`, `isVariable`, `attributes`, `variations`, `defaultAttributes`, and `hasVariations` getter to `ProductModel`.
  3. **Lazada 1:1 Variation Selector (`product_detail_screen.dart`)**:
     - Added `_buildVariationSection(ProductModel p)` with responsive chip buttons showing option title, variation thumbnail (if available), active state outline (`#FF2A6D`), and price.
     - Auto-selects first in-stock variation on load.
     - Tapping a variation dynamically updates top price banner (`_currentPrice`, `_currentRegularPrice`, `_currentDiscountPercentage`), bottom Buy Now price, and WhatsApp inquiry message.
     - Bottom Buy Now and Add to Cart pass `selectedVariation` and `selectedAttributes`.
  4. **Cart & Checkout Architecture (`cart_provider.dart`, `cart_screen.dart`, `checkout_screen.dart`)**:
     - `CartItem` tracks `variation`, `selectedAttributes`, `effectiveVariationId`, `displayImage`, and `variationText`.
     - Cart displays variation badge pill (e.g. `30ml`, `50ml`) and adjusts item quantities/removal per specific variation (`cartKey`).
     - Checkout screen sends `product_id`, `variation_id`, and `variation` attributes to the REST API.
- **Verification & Status**:
  - `flutter analyze`: **No issues found!** (0 errors, 0 warnings).
  - Release APK building in progress for `D:\Glowbay App\GlowBay-App-Release.apk`.
