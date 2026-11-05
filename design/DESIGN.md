# SPORA — Design System (extracted from Figma)

Source: https://www.figma.com/design/Zbzi4s0Sbn5rKEe4ldCezV/Untitled
Extracted: 2026-10-20 · 198 screens exported to `screens/` (PNG @2x)

The product is a football talent-scouting app (FR-first, EN localization designed).
Roles: **Joueur** (player), **Agent**, **Club** — plus Admin & Superadmin back-office.

## Pages & screens

| Page | Screens | Contents |
|------|---------|----------|
| `00-cover` | 1 | Cover |
| `foundations` | 1 | Design tokens reference (see `tokens.md` / `tokens.dart`) |
| `components` | 2 | Component catalogue + complementary states/models |
| `01-entry` | 19 | Splash, welcome, role choice, signup, login (+error/loading), forgot/reset password, email verification, session expired, suspended account, protected connection |
| `02-onboarding` | 14 | Player (general info, tutor consent, highlights upload, profile ready), Agent (agency, search criteria), Club (identity, recruitment needs) |
| `03-home-and-discover` | 17 | Home (player/agent/club variants), Discover players/agents/clubs, global search, filters, loading/error/offline/empty states |
| `04-profiles` | 12 | Public player profile (Jordan), agent & club profiles, journey, highlights (locked), my list/notes, landscape video player, minor profile |
| `05-highlights` | 18 | Video feed (pause/liked/loading/offline), detail recruiter view, upload source/trim/progress/fail, moderation pending, free limit reached |
| `06-opportunities` | 16 | Opportunities list, detection detail (applied/closed/expired), apply, publish flow (type/details/criteria/preview/success), my opportunities, candidates, my applications |
| `07-messaging` | 14 | Message lists (all/unread/proposals/empty), conversation (+minor, send failure), notifications (empty/list), profile views (free/premium) |
| `08-premium` | 12 | Premium paywall, card payment, Mobile Money (number/waiting), 3-D Secure, success/failure, my subscription, cancel/expired |
| `09-account` | 18 | My profile (player/agent/club), settings, edit profile, notifications, privacy/blocked, security/devices, help/FAQ, report, delete account, verification (identity/role proof/statuses) |
| `10-responsive` | 10 | Android 360×800, small 320×640, tablet 768×1024 variants |
| `11-flows-static` | 1 | Static flow overview |
| `12-localisation` | 4 | English variants + long-text (+30%) stress tests |
| `12-accessibility` | 2 | 200% text + annotated profile |
| `90-administration` | 19 | Admin login/2FA, dashboard, video moderation, user management/suspension, verifications, reports, minor protection, opportunities, subscriptions, finances, audit log |
| `91-superadmin` | 6 | Global view, team & access, roles/permissions, config/limits, integrations, security/compliance |
| `98-handoff` | 4 | Architecture, coverage index, handoff |
| `99-archive` | 8 | Legacy dark-mode previews |

## Key UX mechanics

- **Role-based onboarding**: player (needs tutor consent if minor), agent (agency + search criteria), club (identity + recruitment needs).
- **Highlights**: vertical video feed with like/view tracking; upload → trim → moderation pipeline; free tier has view/upload limits.
- **Opportunities**: clubs publish opportunities (type/details/criteria); players apply; application states incl. already-applied/closed/expired.
- **Messaging**: conversations gated (first-message flow, minor protection), proposals tab, profile-view analytics (premium feature).
- **Premium**: subscription via card (3-D Secure) or Mobile Money; gates profile views, highlight limits.
- **Trust & safety**: email verification, identity/role verification for agents/clubs, admin moderation queue, audit log, minor protection screens, account suspension.

See `tokens.md` for the full design-token spec and `tokens.dart` for a ready-to-use Flutter mapping.
