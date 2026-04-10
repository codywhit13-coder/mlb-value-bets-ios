# Privacy Policy Review — iOS App Store Compliance

Reviewed: 2026-04-10
Policy URL: https://mlbvaluebets.com/privacy
Policy last updated: March 29, 2026

---

## What's Covered (No Action Needed)

| Requirement | Status | Details |
|---|---|---|
| Data collected | ✅ | Email, hashed password, subscription status, Stripe customer ID, usage data (pages visited, picks viewed) |
| Supabase as processor | ✅ | Section 3 explicitly names Supabase with privacy policy link |
| Stripe as processor | ✅ | Section 3 names Stripe, states card data never touches our servers |
| Contact info | ✅ | support@mlbvaluebets.com in Section 6 and Section 10 |
| Data retention | ✅ | 30 days post-deletion, 7-year tax records (Section 4) |
| GDPR/CCPA rights | ✅ | Access, correction, deletion, export (Section 6) |
| Cookies | ✅ | Essential auth cookies only, no advertising/tracking cookies |
| No third-party tracking | ✅ | No analytics SDKs, no IDFA, no ATT required |

## Gaps — RESOLVED (April 10, 2026)

### 1. ✅ Mobile App / iOS Now Mentioned
**Fixed**: Added intro paragraph: "This Privacy Policy applies to the mlbvaluebets.com website and the Value Bets iOS application (collectively, 'the Service')."

### 2. ✅ On-Device Storage Now Documented
**Fixed**: Added Section 6 "On-Device Storage (iOS App)" covering Keychain (session tokens), Local cache (UserDefaults, no PII), and Preferences (onboarding, notifications). Notes that all on-device data is removed on sign-out.

### 3. Apple App Privacy Labels (App Store Connect)
**Status**: No policy text change needed — must declare correctly in App Store Connect when creating the listing:

| Data Type | Collected | Linked to User | Tracking |
|---|---|---|---|
| Email Address | Yes | Yes | No |
| User ID | Yes | Yes | No |
| Purchase History | Yes (subscription tier) | Yes | No |
| Product Interaction | Yes (picks viewed) | Yes | No |
| Crash Data | No | — | — |
| Advertising Data | No | — | — |

## Remaining Action Item

1. **App Store Connect**: Fill in App Privacy section using the table above when creating the app listing
