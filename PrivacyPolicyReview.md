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

## Gaps to Fix Before Submission

### 1. Mobile App / iOS Not Mentioned
**Issue**: Policy only references "the Service" generically — reads as web-only.
**Fix**: Add a paragraph stating the policy applies to the iOS app as well as the website. Example: "This Privacy Policy applies to the mlbvaluebets.com website and the Value Bets iOS application."

### 2. On-Device Storage Not Documented
**Issue**: No mention of Keychain, UserDefaults, or local caching.
**Fix**: Add a section covering:
- **Keychain**: Auth session tokens stored securely via Supabase iOS SDK
- **UserDefaults**: Cached picks data for offline viewing (JSON, no PII)
- **@AppStorage**: User preference flags (e.g., onboarding completion)

### 3. Apple App Privacy Labels Not Referenced
**Issue**: Apple requires a privacy "nutrition label" in App Store Connect.
**Fix**: No policy text change needed — but we must declare correctly in App Store Connect:

| Data Type | Collected | Linked to User | Tracking |
|---|---|---|---|
| Email Address | Yes | Yes | No |
| User ID | Yes | Yes | No |
| Purchase History | Yes (subscription tier) | Yes | No |
| Product Interaction | Yes (picks viewed) | Yes | No |
| Crash Data | No | — | — |
| Advertising Data | No | — | — |

## Action Items

1. **Web team**: Update privacy policy text to mention iOS app and on-device storage (Keychain + UserDefaults)
2. **App Store Connect**: Fill in App Privacy section using the table above when creating the app listing
3. **No code changes needed** — the iOS app itself is compliant; only the policy text needs updating
