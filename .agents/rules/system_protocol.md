---
description: Mandatory Automatic Protocol - Always read D:\GEMINI.md and D:\AGENTS.md before tasks, create backups before modifying files, and update logs upon completion.
trigger: always_on
---

# 🛑 সর্বপ্রধান স্থায়ী নিয়ম (MANDATORY AGENT DIRECTIVE FROM OWNER)

> ## **"কাজ শুরু করার আগে D:\GEMINI.md এবং D:\AGENTS.md পড়ে নাও এবং কাজ শেষে সেখানেই আপডেট লগ যুক্ত করে সিঙ্ক করে দিও।"**
> *(READ D:\GEMINI.md and D:\AGENTS.md BEFORE STARTING ANY TASK, AND AUTOMATICALLY ADD UPDATE LOGS & SYNC THERE AFTER COMPLETING. NEVER WAIT FOR THE USER TO REMIND YOU.)*

Every AI agent and model working on this codebase MUST strictly follow these rules on EVERY turn without requiring user reminder:

## 1. PRE-EXECUTION (READ MEMORY FIRST)
- Before planning, writing code, executing commands, or responding to any task:
  - YOU MUST ALWAYS read `D:\GEMINI.md` and `D:\AGENTS.md` (and `PROJECT_MEMORY.md`) in full.
  - Understand recent sessions, active constraints, credentials, and file boundaries to avoid duplicate work, breaking decoupled systems, or creating regressions.

## 2. PRE-MODIFICATION (MANDATORY BACKUP)
- Before modifying ANY file (local Dart/Flutter or remote WordPress PHP/templates):
  - **Remote files (WordPress/cPanel)**: Create a timestamped backup before saving (e.g. `filename.php.bak_<timestamp>`).
  - **Local files (Flutter app)**: Ensure local backup in `.backups/` exists before making non-trivial modifications.
  - NEVER make destructive changes without a verified rollback path.

## 3. POST-EXECUTION (AUTOMATIC MEMORY UPDATE)
- Immediately upon completing ANY task:
  - Automatically update `D:\GEMINI.md`, `D:\AGENTS.md`, and `PROJECT_MEMORY.md` with:
    1. User request summary.
    2. Exact files changed (local and remote).
    3. How the change was implemented and the technical rationale.
    4. What changed and what impact it has on the application or website.
    5. Verification results (analysis, live HTTP tests, or APK build).
  - Also sync changes to remote `glowbay-docs/HANDOFF.md` and `glowbay-docs/AGENTS.md` via cPanel.

## 4. PERMANENT CORE CONSTRAINTS
- **Authentication**: ONLY Email (with 4-digit OTP for signup), Google, and Facebook (App ID `1053208033791589`). No WhatsApp login buttons on auth screens.
- **Copywriting / Languages**: All product pages and catalogs must use clean English. No hardcoded Bengali in product or catalog templates. User chat communication should be in respectful Bengali (বাংলা).
- **Release APK**: Whenever app code changes are finalized, build release APK (`flutter build apk --release`) and copy to `D:\Glowbay App\GlowBay-App-Release.apk`.
