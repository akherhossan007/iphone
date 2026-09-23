/**
 * GlowBayBD Smart Bilingual Client Engine (v1.0.0)
 * Real-time DOM translation, state persistence, and language switcher controller.
 */

(function() {
    'use strict';

    // 1. Comprehensive Bilingual Dictionary
    const gbDict = {
        'bn': {
            // Header Top Bar
            'topbar_origin': '🇲🇾 মালয়েশিয়া ডাইরেক্ট ফ্লাইট ডেলিভারি',
            'topbar_auth': '১০০% আসল প্রোডাক্টের নিশ্চয়তা',
            'topbar_seal': 'সিল ইনট্যাক্ট ও কোয়ালিটি পরীক্ষিত',
            'topbar_track': 'অর্ডার ট্র্যাক করুন',
            'topbar_help': 'হেল্প সেন্টার',
            'topbar_returns': 'রিটার্ন পলিসি',
            'topbar_login': 'লগইন / রেজিস্টার',
            'topbar_account': 'আমার অ্যাকাউন্ট',

            // Navigation Menu
            'nav_categories': 'ক্যাটাগরি সমূহ',
            'nav_home': 'হোম',
            'nav_brands': 'ব্র্যান্ডস',
            'nav_bestsellers': 'সেরা বিক্রিত',
            'nav_newarrivals': 'নতুন কালেকশন',
            'nav_offers': 'অফার ও ডিসকাউন্ট',
            'nav_skinfinder': 'স্কিন প্রবলেম ফাইন্ডার',
            'nav_journal': 'বিউটি জার্নাল / ব্লগ',

            // Header Search & Actions
            'search_placeholder': 'ব্র্যান্ড, প্রোডাক্ট বা ক্যাটাগরি সার্চ করুন...',
            'action_wishlist': 'উইশলিস্ট',
            'action_compare': 'তুলনা',
            'action_cart': 'ব্যাগ',
            'action_login': 'লগইন',

            // Mobile Header & Bottom Nav
            'mob_home': 'হোম',
            'mob_shop': 'শপ',
            'mob_cart': 'ব্যাগ',
            'mob_account': 'প্রোফাইল',
            'mob_ai': 'AI স্কিন স্পেশালিস্ট',
            'mob_search_placeholder': 'স্কিনকেয়ার, মেকআপ বা ব্র্যান্ড খুঁজুন...',
            'mob_air_badge': '🇲🇾 এয়ার ডেলিভারি',
            'mob_original_badge': '⚡ ১০০% আসল',

            // Auth: Login / Register Page Elements
            'auth_welcome_tag': '✦ GLOWBAY-তে স্বাগতম',
            'auth_welcome_title': 'প্রতিদিন নিজেকে সাজান<br><span class="gb-text-gradient">নিজের মতো করে</span>',
            'auth_welcome_sub': 'স্পেশাল মেম্বার অফার, লাইভ এয়ার কার্গো ট্র্যাকিং এবং দ্রুত চেকআউটের জন্য GlowBay-তে যুক্ত হোন।',
            'auth_perk1_title': 'এক্সক্লুসিভ মেম্বার অফার',
            'auth_perk1_desc': 'বিশেষ সদস্য ছাড় ও ফ্ল্যাশ সেল এক্সেস',
            'auth_perk2_title': 'দ্রুত ও সহজ চেকআউট',
            'auth_perk2_desc': 'সেভ করা ঠিকানা ও ১-ক্লিক অর্ডার সম্পন্ন',
            'auth_perk3_title': 'লাইভ ফ্লাইট ও হাব ট্র্যাকিং',
            'auth_perk3_desc': 'মালয়েশিয়া থেকে আপনার দরজা পর্যন্ত সরাসরি আপডেট',

            'auth_login_title': 'GlowBay-তে স্বাগতম! 👋',
            'auth_login_sub': 'আপনার অর্ডার ও প্রোফাইল দেখতে লগইন করুন',
            'auth_reg_title': 'অ্যাকাউন্ট তৈরি করুন ✨',
            'auth_reg_sub': 'সহজে অর্ডার ও ট্র্যাকিংয়ের জন্য GlowBayBD-তে যুক্ত হোন',
            'auth_tab_login': 'লগইন',
            'auth_tab_reg': 'রেজিস্টার',
            'auth_lbl_user': 'ফোন নম্বর অথবা ইমেইল',
            'auth_lbl_pw': 'পাসওয়ার্ড',
            'auth_lbl_remember': 'মনে রাখুন',
            'auth_lbl_forgot': 'পাসওয়ার্ড ভুলে গেছেন?',
            'auth_btn_login': 'লগইন করুন',
            'auth_or_social': 'অথবা সোশ্যাল মিডিয়া দিয়ে সহজে লগইন করুন',
            'auth_lbl_reg_first': 'নামের প্রথম অংশ *',
            'auth_lbl_reg_last': 'নামের শেষ অংশ *',
            'auth_lbl_reg_phone': 'ফোন নম্বর (০১XXXXXXXXX) *',
            'auth_lbl_reg_email': 'ইমেইল এড্রেস *',
            'auth_lbl_reg_gender': 'লিঙ্গ',
            'auth_lbl_reg_pw': 'পাসওয়ার্ড *',
            'auth_lbl_reg_conf_pw': 'পাসওয়ার্ড নিশ্চিত করুন *',
            'auth_btn_reg': 'অ্যাকাউন্ট তৈরি করুন'
        },
        'en': {
            // Header Top Bar
            'topbar_origin': '🇲🇾 Malaysia Direct Flight Delivery',
            'topbar_auth': '100% Authentic Guaranteed',
            'topbar_seal': 'Seal Intact & Quality Checked',
            'topbar_track': 'Track My Order',
            'topbar_help': 'Help Center',
            'topbar_returns': 'Returns Policy',
            'topbar_login': 'Login / Register',
            'topbar_account': 'My Account',

            // Navigation Menu
            'nav_categories': 'Shop by Categories',
            'nav_home': 'Home',
            'nav_brands': 'Brands (A–Z)',
            'nav_bestsellers': 'Best Sellers',
            'nav_newarrivals': 'New Arrivals',
            'nav_offers': 'Offers',
            'nav_skinfinder': 'Skin Concern Finder',
            'nav_journal': 'Beauty Journal',

            // Header Search & Actions
            'search_placeholder': 'Search for brands, products, categories...',
            'action_wishlist': 'Wishlist',
            'action_compare': 'Compare',
            'action_cart': 'Cart',
            'action_login': 'Login',

            // Mobile Header & Bottom Nav
            'mob_home': 'Home',
            'mob_shop': 'Shop',
            'mob_cart': 'Cart',
            'mob_account': 'Account',
            'mob_ai': 'AI Specialist',
            'mob_search_placeholder': 'Search for skincare, makeup, brands...',
            'mob_air_badge': '🇲🇾 Air Delivery',
            'mob_original_badge': '⚡ 100% Original',

            // Auth: Login / Register Page Elements
            'auth_welcome_tag': '✦ WELCOME TO GLOWBAY',
            'auth_welcome_title': 'Glow Your Way,<br><span class="gb-text-gradient">Every Day</span>',
            'auth_welcome_sub': 'Sign in to access exclusive member offers, live air cargo order tracking, and faster checkout.',
            'auth_perk1_title': 'Exclusive Member Offers',
            'auth_perk1_desc': 'Special member discounts & flash sale access',
            'auth_perk2_title': 'Faster & Easier Checkout',
            'auth_perk2_desc': 'Saved addresses, 1-click order fulfillment',
            'auth_perk3_title': 'Live Flight & Hub Tracking',
            'auth_perk3_desc': 'Real-time updates from Malaysia to your doorstep',

            'auth_login_title': 'Welcome to GlowBay! 👋',
            'auth_login_sub': 'Sign in to access your orders & profile',
            'auth_reg_title': 'Create Your Account ✨',
            'auth_reg_sub': 'Join GlowBayBD for faster checkout & tracking',
            'auth_tab_login': 'Login',
            'auth_tab_reg': 'Register',
            'auth_lbl_user': 'Phone Number or Email',
            'auth_lbl_pw': 'Password',
            'auth_lbl_remember': 'Remember me',
            'auth_lbl_forgot': 'Forgot Password?',
            'auth_btn_login': 'Login',
            'auth_or_social': 'Or continue with social account',
            'auth_lbl_reg_first': 'First Name *',
            'auth_lbl_reg_last': 'Last Name *',
            'auth_lbl_reg_phone': 'Phone Number (01XXXXXXXXX) *',
            'auth_lbl_reg_email': 'Email Address *',
            'auth_lbl_reg_gender': 'Gender',
            'auth_lbl_reg_pw': 'Password *',
            'auth_lbl_reg_conf_pw': 'Confirm Password *',
            'auth_btn_reg': 'Create Account'
        }
    };

    // 2. Get Current Language from Cookie / LocalStorage / Server
    function getCurrentLanguage() {
        try {
            const cookieMatch = document.cookie.match(/(?:^|; )gb_site_lang=([^;]*)/);
            if (cookieMatch && (cookieMatch[1] === 'bn' || cookieMatch[1] === 'en')) {
                return cookieMatch[1];
            }
            const local = localStorage.getItem('gb_site_lang');
            if (local === 'bn' || local === 'en') return local;
        } catch(e) {}

        if (window.gbLangConfig && window.gbLangConfig.currentLang) {
            return window.gbLangConfig.currentLang;
        }
        return 'bn';
    }

    // 3. Switch Language Globally
    window.gbSwitchLanguage = function(lang) {
        if (!gbDict[lang]) lang = 'bn';

        // 1. Save to Cookie
        document.cookie = `gb_site_lang=${lang}; path=/; max-age=${365*86400}; SameSite=Lax`;

        // 2. Save to localStorage
        try {
            localStorage.setItem('gb_site_lang', lang);
            localStorage.setItem('gb_auth_lang', lang);
        } catch(e) {}

        // 3. Notify backend via background beacon/ajax
        if (window.gbLangConfig && window.gbLangConfig.ajaxUrl) {
            try {
                const fd = new FormData();
                fd.append('action', 'gb_set_language');
                fd.append('lang', lang);
                navigator.sendBeacon ? navigator.sendBeacon(window.gbLangConfig.ajaxUrl, fd) : fetch(window.gbLangConfig.ajaxUrl, { method: 'POST', body: fd });
            } catch(e) {}
        }

        // 4. Update all switcher buttons in the DOM
        updateSwitcherWidgets(lang);

        // 5. Apply real-time text translations
        gbApplyTranslations(lang);

        // 6. Close any open dropdowns
        document.querySelectorAll('.gb-lang-dropdown-wrap.open').forEach(el => el.classList.remove('open'));

        // 7. Fire custom event for any listeners (AI Consultant, Cart, etc.)
        window.dispatchEvent(new CustomEvent('gbLanguageChanged', { detail: { lang: lang } }));
    };

    // 4. Dropdown Toggle Helper
    window.gbToggleLangDropdown = function(e, btn) {
        e.stopPropagation();
        const wrap = btn.closest('.gb-lang-dropdown-wrap');
        if (!wrap) return;

        const wasOpen = wrap.classList.contains('open');
        document.querySelectorAll('.gb-lang-dropdown-wrap.open').forEach(el => el.classList.remove('open'));

        if (!wasOpen) {
            wrap.classList.add('open');
        }
    };

    // Close dropdowns when clicking outside
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.gb-lang-dropdown-wrap')) {
            document.querySelectorAll('.gb-lang-dropdown-wrap.open').forEach(el => el.classList.remove('open'));
        }
    });

    // 5. Update Switcher Widgets in DOM
    function updateSwitcherWidgets(lang) {
        const is_bn = (lang === 'bn');

        // Update Desktop Pills
        document.querySelectorAll('.gb-cur-lang-text').forEach(el => {
            el.innerHTML = is_bn ? '🇧🇩 বাংলা' : '🇬🇧 English';
        });

        // Update Desktop Menu Items
        document.querySelectorAll('.gb-lang-menu-item').forEach(item => {
            const isItemBn = item.textContent.includes('বাংলা');
            if ((isItemBn && is_bn) || (!isItemBn && !is_bn)) {
                item.classList.add('selected');
                if (!item.querySelector('.gb-check')) {
                    const check = document.createElement('i');
                    check.className = 'fa-solid fa-check gb-check';
                    item.appendChild(check);
                }
            } else {
                item.classList.remove('selected');
                const check = item.querySelector('.gb-check');
                if (check) check.remove();
            }
        });

        // Update Mobile Buttons
        document.querySelectorAll('.gb-lang-toggle-bar .gb-lang-btn').forEach(btn => {
            const isBtnBn = btn.getAttribute('aria-label') === 'বাংলা' || btn.textContent.includes('বাংলা');
            if ((isBtnBn && is_bn) || (!isBtnBn && !is_bn)) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });

        // Update Mobile Segmented Pill
        document.querySelectorAll('.gb-lang-mobile-pill').forEach(pill => {
            if (is_bn) {
                pill.classList.add('lang-is-bn');
                pill.classList.remove('lang-is-en');
                const bnText = pill.querySelector('.gb-pill-bn');
                const enText = pill.querySelector('.gb-pill-en');
                if (bnText) bnText.classList.add('active');
                if (enText) enText.classList.remove('active');
            } else {
                pill.classList.add('lang-is-en');
                pill.classList.remove('lang-is-bn');
                const bnText = pill.querySelector('.gb-pill-bn');
                const enText = pill.querySelector('.gb-pill-en');
                if (bnText) bnText.classList.remove('active');
                if (enText) enText.classList.add('active');
            }
        });

        // Sync old login page curLangLabel if present
        const oldAuthLabel = document.getElementById('curLangLabel');
        if (oldAuthLabel) {
            oldAuthLabel.innerHTML = is_bn ? '🇧🇩 বাংলা' : '🇬🇧 English';
        }
    }

    // 6. Apply Text Translations to DOM
    function gbApplyTranslations(lang) {
        const d = gbDict[lang];
        if (!d) return;

        // Helper
        const setText = (selector, text) => {
            document.querySelectorAll(selector).forEach(el => {
                if (el) el.innerText = text;
            });
        };
        const setHtml = (selector, html) => {
            document.querySelectorAll(selector).forEach(el => {
                if (el) el.innerHTML = html;
            });
        };
        const setAttr = (selector, attr, val) => {
            document.querySelectorAll(selector).forEach(el => {
                if (el) el.setAttribute(attr, val);
            });
        };

        // Header Top Bar
        setText('a[href*="/track-order/"]', d.topbar_track);
        setText('a[href*="/faq/"]', d.topbar_help);
        setText('a[href*="/faq/#returns"]', d.topbar_returns);

        // Header Main Nav
        setText('.gbd-nav-item:has(i.fa-house) span, .gbd-menu-link[href="/"], .gbd-menu-link[href*="glowbaybd.com/"]', d.nav_home);
        setText('a[href*="/brands/"]', d.nav_brands);
        setText('a[href*="/shop/?filter=best-sellers"]', d.nav_bestsellers);
        setText('a[href*="/shop/?filter=new-arrivals"]', d.nav_newarrivals);
        setText('a[href*="/offers/"]', d.nav_offers);
        setText('a[href*="/skin-concern-finder/"]', d.nav_skinfinder);
        setText('a[href*="/blog/"]', d.nav_journal);

        // Search Input Placeholder
        setAttr('#gbdSearchInput, .gbd-search-input, input[name="s"]', 'placeholder', d.search_placeholder);
        setAttr('.gbm-search-input, #gbmSearchInput', 'placeholder', d.mob_search_placeholder);

        // Header Action Badges
        setText('.gbd-action-badge[href*="/wishlist/"] .gbd-action-label', d.action_wishlist);
        setText('.gbd-action-badge[href*="/compare/"] .gbd-action-label', d.action_compare);
        setText('.gbd-action-badge[href*="/cart/"] .gbd-action-label', d.action_cart);

        // Auth / Login Page Elements
        setText('#gbAuthWelcomeTag', d.auth_welcome_tag);
        setHtml('#gbAuthWelcomeTitle', d.auth_welcome_title);
        setText('#gbAuthWelcomeSub', d.auth_welcome_sub);
        setText('#gbPerk1Title', d.auth_perk1_title);
        setText('#gbPerk1Desc', d.auth_perk1_desc);
        setText('#gbPerk2Title', d.auth_perk2_title);
        setText('#gbPerk2Desc', d.auth_perk2_desc);
        setText('#gbPerk3Title', d.auth_perk3_title);
        setText('#gbPerk3Desc', d.auth_perk3_desc);

        // Login / Register Card
        const isRegTab = document.getElementById('tabRegister') && document.getElementById('tabRegister').classList.contains('active');
        setText('#gbAuthTitle', isRegTab ? d.auth_reg_title : d.auth_login_title);
        setText('#gbAuthSubtitle', isRegTab ? d.auth_reg_sub : d.auth_login_sub);
        setText('#txtTabLogin', d.auth_tab_login);
        setText('#txtTabRegister', d.auth_tab_reg);
        setText('#lblLoginUser', d.auth_lbl_user);
        setText('#lblLoginPw', d.auth_lbl_pw);
        setText('#lblRememberMe', d.auth_lbl_remember);
        setText('#lblForgot', d.auth_lbl_forgot);
        setText('#txtBtnLogin', d.auth_btn_login);
        setText('#lblOrContinue', d.auth_or_social);

        // Register Fields
        setText('#lblRegFirst', d.auth_lbl_reg_first);
        setText('#lblRegLast', d.auth_lbl_reg_last);
        setText('#lblRegPhone', d.auth_lbl_reg_phone);
        setText('#lblRegEmail', d.auth_lbl_reg_email);
        setText('#lblRegGender', d.auth_lbl_reg_gender);
        setText('#lblRegPw', d.auth_lbl_reg_pw);
        setText('#lblRegConfPw', d.auth_lbl_reg_conf_pw);
        setText('#txtBtnReg', d.auth_btn_reg);

        // Mobile Badges
        setText('.gbm-badge-origin', d.mob_air_badge);
        setText('.gbm-promo-tag', d.mob_original_badge);
    }

    // 7. Backward compatibility for any inline switchSiteLang calls
    window.switchSiteLang = function(lang) {
        window.gbSwitchLanguage(lang);
    };

    window.gbToggleMobileLang = function() {
        const cur = getCurrentLanguage();
        const next = (cur === 'bn') ? 'en' : 'bn';
        window.gbSwitchLanguage(next);
    };

    // 8. Auto-apply on Page Load
    document.addEventListener('DOMContentLoaded', function() {
        const lang = getCurrentLanguage();
        updateSwitcherWidgets(lang);
        gbApplyTranslations(lang);
    });

})();
