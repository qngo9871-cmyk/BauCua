# Bầu Cua Tôm Cá — Vietnamese Dice Game

**2026-09-04 — Competitor check: this category has no paid IAP at all; leaving price
as-is and watching.** Pulled live App Store listings for direct Vietnam competitors
("Bầu Cua Tôm Cá 2026", "Bau Cua Heo Vang", others). **None of them have any in-app
purchases** — they're pure free/ad-supported, unlike the Sâm Lốc/Tiến Lên card-game
category where paid unlocks (29,000–59,000đ) are normal (see
`~/Projects/SamLoc/CLAUDE.md`). So the 45,000 VND fix below is priced fairly *within a
category where paying anything at all is the outlier*, not the norm — price alone may
not fix conversion here. Decision (user, 2026-09-04): leave the price as-is, just watch
the data for now rather than touch pricing further. If conversion stays at zero after a
few weeks, the real lever is likely a monetization-model change (ad-supported instead of
paid unlock), not another price cut — bigger product decision, not yet scoped.

**2026-09-04 — Vietnam IAP price cut to 45,000 VND (manual override).** Apple's
automatic territory pricing had `baucua.pro` at 99,000 VND for Vietnam (~$3.90
USD-equivalent, actually *above* the $2.99 US price) — discovered while investigating
Sam Loc's 0-purchase problem (see `~/Projects/SamLoc/CLAUDE.md`). Since this is a
Vietnam-market game, added a manual VNM price override (US price stays $2.99, only
Vietnam changes). No app review needed — pricing is metadata, applies instantly. Worth
watching VN conversion over the next few weeks.

**2026-08-30 (later same day) — v1.0.5 (build 7), language-switch bug fix, merged into
the pending v1.0.4 submission and resubmitted.** Portfolio-wide sweep found the language
Picker bound directly to `$loc.language`, bypassing `setLanguage(_:)`, so the string
bundle never updated on switch (see memory `feedback_localization_picker_direct_binding_bug`
for the full root cause, shared across 16 apps). v1.0.4 was already `WAITING_FOR_REVIEW`
for an unrelated description-text fix (build 6) — canceled that reviewSubmission (not
deleted, per `asc-resubmit-after-rejection`), bumped the freed version's `versionString`
1.0.4→1.0.5, attached the new build (7, includes both fixes), merged `whatsNew` to cover
both changes, appended a review-notes addendum, and resubmitted. **Verified:
WAITING_FOR_REVIEW as v1.0.5.**

**2026-08-30 — v1.0.4 (build 6), description-text fix, SUBMITTED, WAITING_FOR_REVIEW.**
A portfolio-wide listing/review audit found the live description (from before the
2026-08-22 trial-lock fix) still said the game was "always free-to-play" and described
Pro as "OPTIONAL, COSMETIC ONLY" — both now stale against the actual shipped behavior
(the whole game locks after a 7-day trial; Pro's one-time unlock restores play access
*plus* the cosmetic extras). Rewrote just those two sections in both `en-US` and `vi`
(everything else, including the "NO STAKES, NO WAGERING, EVER" section, is unchanged and
still accurate) — no code changes. Archived/exported/uploaded with the full explicit
`-authenticationKeyPath`/`-authenticationKeyID`/`-authenticationKeyIssuerID` flags (no
Xcode account on this machine, so `-allowProvisioningUpdates` needs them every time, not
just "the first time" as some other apps' docs wrongly assumed). App `6796833635`,
version `1.0.4` (id `cf2facfd-bc2d-4831-9255-7e50458e86ee`), build `6`
(`10edc7b9-bba4-45b2-9244-12c515de2d51`) attached, reviewSubmission
`7a687cc1-bc0d-47e5-895c-175247fbb4ec` submitted. IAP (`com.quyenngo.baucua.pro`) is
already `APPROVED` from a prior cycle, so no web-UI tick-in was needed this time.

Native SwiftUI iOS app for Bầu Cua Tôm Cá, the traditional Vietnamese dice game (Bầu/Cua/
Tôm/Cá/Gà/Nai — gourd/crab/shrimp/fish/rooster/deer). Bundle `com.quyenngo.baucua`. One
app in a 5-app Vietnamese-games lineup; built following the house pattern established by
the sibling card game `~/Projects/SamLoc` (bundle `com.quyenngo.samloc`, already shipped).

**2026-08-24 (later same day) — vision QA found the v1.0.2 submission's own paywall
screenshot is stale and shows the pre-fix bug.** `screenshots/final/{en,vi}/05-upgrade.png`
was last captured before today's DEBUG isPro fix (the code below was already correct,
the screenshot on disk — and thus already pushed to ASC with this submission — wasn't)
and showed "You own Bầu Cua Pro ✓" instead of a real buy button, a fresh install would
never see that screen. Recaptured both locales after adding a `simctl erase` step to
`capture_shots.py` (trial-day count wasn't deterministic) and an 8s post-install settle
wait (a freshly-erased simulator can surface a first-boot system notification that would
otherwise land in frame). Verified both locales now show the real "Unlock Bầu Cua Pro"
button. **Pulled, fixed, and resubmitted per standing user policy** (found post-submit
bug → cancel → fix → resubmit, applies to all apps): canceled the v1.0.2
reviewSubmission (`b4f18dd3-...`, `CANCELING`→`COMPLETE`), bumped to **v1.0.3
(build 5)** in `project.yml`, archived/exported/uploaded (Delivery UUID
`707e973f-6729-4b18-bfba-cfe5e2466ce9`, processed `VALID`), attached to the same
appStoreVersion record (versionString PATCHed 1.0.2→1.0.3), pushed the corrected
screenshots via `asc_push_baucua_screenshots.py`, updated `whatsNew` (both locales),
created a new reviewSubmission `24a42123-3b06-4bc1-85f9-ac57407b72df` and submitted.
**Verified: WAITING_FOR_REVIEW as v1.0.3.**

**2026-08-24 — v1.0.2 (build 4), DEBUG bug + Swift 6 concurrency fix, SUBMITTED.** Found by
the new portfolio-wide `~/asc-tools/compliance_gate.py`: `PurchaseManager.
updateEntitlementStatus()`'s DEBUG branch had a bare `isPro = true`, the same double-gating
bug already fixed in SamLoc/Fanorona/Dara/Surakarta — fixed with the same capture-mode-
exempted pattern (`isPro = BC_CAPTURE != nil && BC_CAPTURE != "home" && BC_CAPTURE !=
"upgrade"`). Also found and fixed a real (if currently harmless) Swift 6 concurrency
warning: `GameModel.pointsPerMatch` is `@MainActor`-isolated but read from the non-isolated
`GuessResult.pointsEarned` — marked `nonisolated static let` since it's an immutable
constant, safe to access from any context. Verified clean build (0 warnings) and visually
re-confirmed the home screen shows the real trial/free-tier state (not a DEBUG-forced fake
unlock). No gameplay/scoring/purchase logic changed. **SUBMITTED, WAITING_FOR_REVIEW** —
app `6796833635`, version `1.0.2` (id `af403157-f5a1-40dd-bd75-5862f57d691a`), build
`4`/`04f12e59-a5a7-4f83-9457-5f72cd0c7873` attached, reviewSubmission
`b4f18dd3-c7d2-47f5-a769-7d15c0182eae`.

**Status: 🟢 v1.0.1 (build 3), 7-day trial-then-lock gate, SUBMITTED, WAITING_FOR_REVIEW (2026-08-22).**
App id `6796833635`, version `1.0.1` (id `13029ddc-f413-4961-969a-9ebacab11fe6`),
build 3 (id `51a5bef7-b6f8-4169-b8bb-b027784e96b8`, processed `VALID`) attached,
reviewSubmission `95670d6c-59a7-49f5-ba2f-d1cd7b35a238` submitted at
2026-08-22T05:32:15Z. Gotcha hit during submit: `new_version.py` only patches
the `en-US` locale's `whatsNew` — the `vi` localization needed its own manual
`whatsNew` PATCH before `reviewSubmissionItems` would accept the version
(409 `ENTITY_ERROR.ATTRIBUTE.REQUIRED`), same pattern as ChineseChess
v1.0.5/v1.0.6's zh-Hant gotcha — any future non-English-only submission via
that script needs the same manual follow-up per extra locale. Also hit two
transient 500 `UNEXPECTED_ERROR` responses from Apple's API on both the
`reviewSubmissionItems` POST and the final `submitted:true` PATCH — both
resolved on retry with a short backoff, not a real blocker.
`Core/PurchaseManager.swift` now has a `trialActive`/`trialDaysRemaining` clock
(`firstLaunchDate` in UserDefaults, 7-day `trialDuration`) exactly matching the
portfolio-wide pattern from [[feedback_no_permanent_free_tier_trials_only]] —
this app was previously **permanently free** (the `Play` button had zero lock
check) and was found as a gap in the 2026-08-18 rollout (it's a dice-prediction
game, not board/card, so it wasn't on the original 19-app scan list). `HomeView`'s
`Play` button now opens `UpgradeView` instead of starting a game once the trial
expires and the user isn't Pro; a "Free trial — N day(s) left" banner shows
during the trial, and a "Trial ended — unlock to keep playing →" link replaces
the normal upgrade link once it lapses. `UpgradeView`'s subtitle switches to a
trial-ended message too. Added `home.trialdays`/`home.upgrade.trialended`/
`upgrade.subtitle.trialended` to both `en` and `vi` `Localizable.strings`.
Verified all three UI states live in Simulator (trial-active banner + unlocked
Play, trial-expired locked Play with 🔒 + upgrade prompt, `UpgradeView`
trial-ended copy) via temporary `BC_FORCE_LOCKED`/`BC_FORCE_TRIAL_EXPIRED` env
hooks that were reverted before commit — not shipped. **Compliance note:** this
gate controls access to playing at all, not scoring/odds, so it does not
reintroduce the wagering mechanic the 2026-08-05 redesign removed (see the
compliance comment block in `PurchaseManager.swift`). Sales data as of
2026-08-22 showed 36 downloads since 2026-08-01 (29 from VN) with **zero** IAP
conversions, which is what prompted this fix.

**2026-08-22 — bumped MARKETING_VERSION 1.0.0→1.0.1 / CURRENT_PROJECT_VERSION
2→3, archived and exported successfully** (`xcodegen generate` + the archive/
export commands below) — `build/export/BauCua.ipa` is ready locally. **Upload
to App Store Connect itself was blocked by the Claude Code auto-mode
permission classifier** (uploading a real build is treated as a consequential
external action) — asked the user for explicit go-ahead before running
`xcrun altool --upload-app`. Once uploaded and the build shows `VALID`, the
IAP's stale "unlimited free refills" copy (see "Not done yet" below) is now
unlocked and can finally be pushed via `asc_push_baucua.py`, then create the
new appStoreVersion via `new_version.py`, attach the build, and submit — this
is a routine update on an already-`READY_FOR_SALE` app with an already-
`APPROVED` IAP (confirmed via `asc_iap_inspect.py`), so no web-UI IAP tick-in
should be needed this time (same pattern as Fanorona's 2026-08-20 v1.0.2
update).

**Previous status: REDESIGNED & RESUBMITTED, WAITING_FOR_REVIEW (2026-08-05).** App id
`6796833635`, version `1.0.0` (id `8b0e943a-241f-4b66-8b7e-c3e8d81b4537`), build 2
(`d11eceae-49c9-4124-b763-0c48358a0b50`) attached, new reviewSubmission
`f631ffef-c17e-4e19-808b-4cd09f82b800` submitted. Release type: automatic
(`AFTER_APPROVAL`).

**History:** the original v1.0.0 submission (reviewSubmission
`a6a5a951-cc67-436d-a2d5-9226ef4e812e`, build 1) was rejected 2026-08-04 under Guideline
2.3.6 (Accurate Metadata): it had a real stake/wager/payout loop (bet chips → lose or win a
multiple of the stake) and its age rating correctly declared `gamblingSimulated:
"FREQUENT_OR_INTENSE"` — but Apple requires an **Organization** developer account for any
app with that descriptor, and this account is Individual. Rather than enroll as an
Organization, the game was **redesigned to remove the wagering mechanic entirely** (see
"Redesign (2026-08-05)" below) — it's now a no-stakes prediction/scoring game with zero
gambling-adjacent mechanics. `gamblingSimulated` was set to `NONE` and verified live via
the API before resubmitting. The old reviewSubmission was canceled (`PATCH
{"canceled": true}` → `CANCELING` → `COMPLETE`) to free the version and IAP per
[[asc-resubmit-after-rejection]], app-level metadata/description/IAP-copy/screenshots were
pushed with the new no-stakes language, build 2 was archived/exported/uploaded and attached
once `processingState: VALID`, and the version was resubmitted. One residual: the Pro IAP's
own name/description text is still the old "unlimited free refills" copy and couldn't be
pushed — its `inAppPurchaseVersion` is locked ("inflight") until this review cycle
resolves; see the "Not done yet" section for the follow-up.

## Deploy / resubmit pattern

No Xcode account/Distribution cert on this machine — pass the ASC API key explicitly to
xcodebuild (see [[feedback_asc_release_and_signing]]):
```
xcodegen generate
xcodebuild -project BauCua.xcodeproj -scheme BauCua -configuration Release \
  -archivePath build/BauCua.xcarchive -destination 'generic/platform=iOS' \
  -allowProvisioningUpdates \
  -authenticationKeyPath /Users/q/.appstoreconnect/private_keys/AuthKey_G85WXB4AF5.p8 \
  -authenticationKeyID G85WXB4AF5 -authenticationKeyIssuerID 2e969722-fc4d-444c-af74-7e0233efd016 \
  archive
xcodebuild -exportArchive -archivePath build/BauCua.xcarchive -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist -allowProvisioningUpdates \
  -authenticationKeyPath /Users/q/.appstoreconnect/private_keys/AuthKey_G85WXB4AF5.p8 \
  -authenticationKeyID G85WXB4AF5 -authenticationKeyIssuerID 2e969722-fc4d-444c-af74-7e0233efd016
xcrun altool --upload-app --type ios -f build/export/BauCua.ipa \
  --apiKey G85WXB4AF5 --apiIssuer 2e969722-fc4d-444c-af74-7e0233efd016
```
Metadata scripts are idempotent — re-run after copy changes. No `asc_submit_baucua.py`
exists; submission was done via one-off `reviewSubmissions` → `reviewSubmissionItems` →
`PATCH submitted=true` calls (copy the pattern from `asc_submit_woktonight.py` if
resubmitting).

## ⚠️ Compliance constraint — read before touching game logic or IAP

Bầu Cua Tôm Cá is traditionally a betting/wagering dice game, but **this app deliberately
has no wagering, staking, or gambling mechanic of any kind**, and that must stay true
forever — this is the direct fix for the 2.3.6 rejection above, not a stylistic choice:

- **There is nothing to stake and nothing to lose.** The player predicts symbols
  (`GameModel.predictions: Set<Symbol>`, a plain toggle, no amounts) and every match earns
  a fixed number of points (`GameModel.pointsPerMatch`). `score` only ever goes up — there
  is no "spend," no "balance that can hit 0," and therefore no top-up/refill mechanic at
  all (the old chip-balance/free-top-up system was deleted along with the wagering loop,
  not just hidden).
- **Nothing is, or will ever be, purchasable with real money that affects scoring.** No IAP
  may sell points, currency, extra predictions, or anything that affects match odds or
  points-per-match. Do not reintroduce a stake/wager mechanic even in a disguised form
  (e.g. "double your points" gambles, loot-box style bonuses) — that would recreate the
  exact problem this redesign fixed.
- The Pro IAP (`com.quyenngo.baucua.pro`, non-consumable, see `Core/PurchaseManager.swift`)
  unlocks **cosmetic/QoL only**: alternate dice/bowl visual themes, a detailed stats
  screen, and no ads. Pro must never touch scoring or introduce anything wager-like. See
  the compliance comment block at the bottom of `PurchaseManager.swift` before changing
  anything there.
- **Age rating for the ASC step:** unlike the rejected v1.0.0, this version's age rating
  must declare `gamblingSimulated: "NONE"` (see `asc_push_baucua_review.py`) — it is no
  longer accurate or necessary to declare a gambling descriptor, and declaring one again
  would just reproduce the same Individual-account rejection.

## The game

- 6 symbols (`Core/Symbol.swift`): Bầu, Cua, Tôm, Cá, Gà, Nai. Emoji placeholders
  (🍐🦀🦐🐟🐓🦌) — real dice-face art is a later step.
- Player starts with 0 score (`GameModel.score`), persisted via `UserDefaults`
  (`AppStorage`-style keys prefixed `bc_`). Score only ever increases — there is no way to
  spend it or lose it, so there's no balance-hits-0 state to handle.
- **Prediction phase:** tap any of the 6 symbols to predict it'll come up; multiple
  simultaneous predictions allowed (`GameModel.predictions: Set<Symbol>`, a plain toggle —
  no amounts). Must predict ≥1 symbol before rolling (`GameModel.canRoll`).
- **Roll:** 3 dice, each independently uniform-random over the 6 symbols
  (`GameModel.roll()` → `Symbol.allCases.randomElement()!` ×3). `DiceBowlView` animates a
  ~0.9s shake (SwiftUI offset/rotation jitter) before settling.
- **Scoring**, per symbol predicted: count matches among the 3 dice (0–3). Each match is
  worth `GameModel.pointsPerMatch` (10) points — 0 matches earns 0 for that symbol, never a
  loss. Implemented in `Core/Guess.swift` (`GuessResult.pointsEarned`) and settled in
  `GameModel.settle(dice:predicted:)`.
- **Round loop:** after settling, predictions clear and the board returns to the
  prediction phase. No AI opponent — solo, no opponent at all — so there's no
  `AIPlayer.swift` and no difficulty concept anywhere in this app (deliberate difference
  from SamLoc's structure).
- **Stats** (`GameModel.roundsPlayed` / `.bestRoundScore` / `.bestStreak`, persisted):
  shown in the Pro-only stats sheet (`StatsSheetView`, defined privately inside
  `Views/HomeView.swift` rather than as its own file).

## Structure

- `BauCua/Core/` — `Symbol.swift`, `Guess.swift` (`GuessResult`), `GameModel.swift`
  (prediction/rolling/scoring + `#if DEBUG` `captureSetup(_:)` for screenshots),
  `PurchaseManager.swift`, `Localization.swift` (copied verbatim from SamLoc — no
  app-specific strings live in this file).
- `BauCua/Views/` — `HomeView`, `GameView`, `DiceBowlView` (the shaking dice/bowl),
  `PredictionBoardView` (the 6-symbol prediction grid), `RulesView`, `OnboardingView`,
  `UpgradeView`.
- `BauCua/{en,vi}.lproj/Localizable.strings` — real hand-written bilingual UI strings
  (not machine-translated), using the correct terms: Bầu, Cua, Tôm, Cá, Gà, Nai, "đặt
  cược" (place bet), "lắc" (shake/roll). No `%@`-for-name templated strings exist in this
  app (no opponent), so SamLoc's documented "%@ = You" grammar trap doesn't apply here —
  still worth a re-check if templated strings are ever added.
- `capture_shots.py` — drives the simulator via `BC_CAPTURE` / `BC_LANG` DEBUG launch args
  (mirrors SamLoc's `SL_CAPTURE`/`SL_LANG` convention) to produce real in-app screenshots
  into `screenshots/final/{en,vi}/`. Capture scenarios: `home`, `predicting`, `rolling`,
  `result`, `upgrade`, `rules` (wired in `ContentView.swift` + `GameModel.captureSetup`).
- `make_icon.py` — generates the real app icon: a bold gold crab (Cua) silhouette emblem
  on a red/gold Tet-festival gradient. See "App-Store-ready pass" below for details.
- `project.yml` — XcodeGen. Regenerate the `.xcodeproj` with `xcodegen generate` after
  adding/removing files (or just run `./rebuild.sh`).

## Judgment calls made during this build (not spelled out in the original spec)

- **No separate `StatsView.swift` file:** the spec's target file list only names
  `HomeView/GameView/DiceBowlView/PredictionBoardView/RulesView/OnboardingView/UpgradeView`,
  but also calls out a Pro "detailed stats screen" as a feature. Implemented as a small
  private `StatsSheetView` inside `Views/HomeView.swift` rather than adding an eighth Views
  file, to stay literally within the given structure.
- `rebuild.sh` didn't exist in SamLoc (despite being referenced as a convention) — built it
  fresh, closely modeled on `~/Projects/ChineseChess/rebuild.sh`'s clean/build-for-sim/
  build-for-device shape, plus an `xcodegen generate` step up front.

## Redesign (2026-08-05): removed the wagering mechanic entirely

The original v1.0.0 build (`Bet.swift`/`BetBoardView.swift`, chip stakes, payout multiples,
a chip-balance-hits-0 free-top-up system) was rejected by App Review under Guideline 2.3.6
— see the Status line at the top. Rather than enroll as an Organization developer account,
the whole stake/wager/payout loop was deleted and replaced with a no-stakes
prediction-and-score loop:

- `Bet.swift` → `Core/Guess.swift` (`GuessResult`, points-only, no `netChange`/loss concept).
- `GameModel`: `chips`/`bets: [Symbol: Int]`/`adjustBet`/`setBet`/`totalBet` → `score`/
  `predictions: Set<Symbol>`/`toggle`/`clearPredictions`. `roll()` no longer debits
  anything up front. `settle()` only ever adds points. The free-top-up system
  (`claimFreeTopUp`, `freeTopUpAmount`, `freeTopUpCooldown`, `lastFreeTopUpDate`,
  `unlimitedFreeRefills`, `topUpAvailable`, `topUpCooldownRemaining`) was deleted outright —
  it's structurally impossible to run out of points now, so there's nothing to top up.
- `BetBoardView.swift` → `Views/PredictionBoardView.swift`: cells are a plain on/off toggle
  (checkmark), no chip-value picker, no long-press-to-clear (tap toggles both ways).
- `GameView`: removed the chip-value picker row and `topUpOverlay`/tick timer entirely.
- `UpgradeView`/Pro feature set: dropped "unlimited free chip refills" (nothing to refill
  anymore) — Pro is now purely alternate themes + detailed stats + no ads.
- All `en`/`vi` `Localizable.strings`, `RulesView`/`OnboardingView` copy, `capture_shots.py`
  headlines, and the ASC store description/promo/keywords (`asc_push_baucua.py`) needed
  matching copy changes away from "bet"/"stake"/"wager" language toward "predict"/"guess"/
  "score" — Apple's 2.3.6 rejection is about the app's *declared nature* matching its
  *actual behavior*, so leftover betting language in the description would be just as
  wrong as leftover betting code.

## Build

```
cd ~/Projects/BauCua
xcodegen generate
xcodebuild -project BauCua.xcodeproj -scheme BauCua -destination 'generic/platform=iOS Simulator' build
```

Verified clean simulator build after the redesign (2026-08-05), plus a real runtime pass on
iPhone 17 Pro Max: ran `capture_shots.py` (home/predicting/rolling/result/upgrade, en+vi —
this exercises the actual `GameModel.roll()`/`settle()` async flow, not just static state)
and separately captured Rules and Onboarding via `BC_CAPTURE=rules`/`onboarding`. All screens
visually inspected — score persistence across launches confirmed (UserDefaults `bc_score`
carried a real value from a prior capture into a later plain-home launch), prediction
toggle/checkmark UI correct, result math correct (e.g. 2×+3×1 matches → +30, shown and
computed identically), Rules/Onboarding copy reads correctly in both languages, Upgrade
screen shows the 3 Pro features with no leftover refill-wait text. Did not exercise a live
StoreKit purchase (no `.storekit` local test config in this project; `#if DEBUG` forces
`isPro = true` so the buy button doesn't render in Debug builds) — this matches how Pro was
tested for the original v1.0.0 submission, and the purchase code path itself was not
touched by this redesign (only its feature-description text changed).

`./rebuild.sh` runs both a simulator build and a device-archive build (mirroring
`~/Projects/ChineseChess/rebuild.sh`'s shape). **The device-archive step will fail today**
with "No profiles for 'com.quyenngo.baucua' were found" — expected, since the bundle ID
isn't registered in App Store Connect yet (that registration is part of the later ASC
step, out of scope here). The simulator build step succeeds on its own; re-run just that
step, or the plain `xcodebuild ... -destination 'generic/platform=iOS Simulator' build`
command above, until the device build is needed.

## App-Store-ready pass (icon, screenshots, legal site)

Completed a follow-up pass to get the app-facing assets ready (App Store Connect
registration/submission itself is still a separate, later step — out of scope here too).

- **App icon:** `make_icon.py` was rewritten from the placeholder bowl-and-dice stub into
  a bold single-emblem icon — an oversized gold crab (Cua) silhouette, tilted, on a deep
  red-to-black Tet-festival gradient — matching the house style set by
  `~/Projects/SamLoc/make_icon.py` (one bold tilted emblem, no busy scene, no text). First
  draft had the claws positioned outside the canvas (rendered as clipped "pac-man" shapes)
  and disconnected from their arms; rewrote the geometry using normalized fraction-of-SIZE
  coordinates so every part of the crab (body, 2 claws, 6 legs, eye stalks) is verified to
  stay within the 1024×1024 frame with margin. Output confirmed at
  `Assets.xcassets/AppIcon.appiconset/AppIcon.png`, 1024×1024.
- **Screenshots:** ran `capture_shots.py` and visually inspected every one of the 10 output
  PNGs (`screenshots/final/{en,vi}/*.png`) with the image reader, not just spot-checked.
  Found and fixed two real bugs in the process:
  - `01-home.png` in both languages was actually capturing the **onboarding** flow, not
    the home screen — `ContentView.swift`'s DEBUG branch explicitly skipped the capture
    override for `BC_CAPTURE=home` and fell through to the normal `hasSeenOnboarding`
    check, which is always `false` on a fresh simulator install. Fixed by adding an
    explicit `capture == "home"` → `HomeView()` branch in `ContentView.swift` (mirrors the
    existing `BC_SKIP_ONBOARDING` path).
  - The `vi` pass produced a solid-black `03-rolling.png` and, worse, a `05-upgrade.png`
    that captured a **different app entirely** ("Cờ Cá Ngựa") bleeding through from the
    shared simulator's prior foreground state — `capture_shots.py` used a bare
    `subprocess.run` (no `check=True`) for `simctl launch` and only a 2s settle sleep, so a
    slow/failed launch silently left stale screen content to be screenshotted. Hardened
    `capture_shots.py`: launch now goes through the `sh()` helper (raises on failure
    instead of silently continuing), added a 0.5s pause after `terminate` before
    `launch`, and increased the post-launch settle sleep from 2s to 3.5s. Re-ran after
    both fixes — all 10 images re-inspected and confirmed correct: right screen, right
    language (Vietnamese diacritics render correctly, no mojibake), right chip
    balance/payout numbers, no placeholder text, no mid-animation garbage.
- **Legal site:** built `~/Projects/baucua-legal/` (`index.html` / `privacy.html` /
  `support.html`, en + `vi/`), following the exact template/CSS of
  `~/Projects/fanorona-legal/`. Live at **https://qngo9871-cmyk.github.io/baucua-legal/**
  (public repo `qngo9871-cmyk/baucua-legal`, GitHub Pages enabled from `main`/`/`). Carries
  **explicit no-wagering language**: `support.html` states there's nothing to stake and
  nothing to lose, points are never purchasable and hold no cash value; `privacy.html`'s
  Purchases section states the Pro IAP is cosmetic/QoL-only (alternate dice/bowl themes,
  detailed stats, no ads) and never affects scoring. **Updated 2026-08-05** (all 6 pages,
  en + vi) to match the redesign — "chip/stake/bet" language fully replaced with
  "point/predict/score" across all pages; not yet pushed to the live GitHub Pages site,
  just committed locally (see ASC/legal push step below).

## Not done yet (later steps, not this session's scope)

- Sideload / device testing, TestFlight.
- Push the updated `baucua-legal` repo (git commit + push) so the live site matches the
  local files before resubmission — GitHub Pages won't pick up the redesign copy until
  that happens.
- **IAP metadata text is stale and currently un-editable via the API.** The Pro IAP's
  name/description/reviewNote still say "unlimited free refills" (a feature this redesign
  removed) — `asc_push_baucua.py`'s IAP-localization PATCH 409s with
  `STATE_ERROR.IAP_VERSION_UNMODIFIABLE` / `ENTITY_ERROR...UNMODIFIABLE` because the IAP's
  `inAppPurchaseVersion` is "inflight" (`STATE_ERROR.ALREADY_EXISTS` on trying to create a
  fresh one) — this is normal Apple IAP-versioning behavior: it locks for editing once
  attached to a version under review, and only unlocks after that review cycle resolves
  (approve or reject), regardless of the parent app's own reviewSubmission being canceled.
  **Once this resubmission comes back from Apple (either outcome), re-run
  `asc_push_baucua.py` to push the corrected IAP name/description** (already updated in
  the script's `IAP` dict — just couldn't push yet). Same lock applies to
  `asc_upload_baucua_iap_screenshot.py` (409 `UNMODIFIABLE` on `reviewScreenshot`) — the
  IAP's review screenshot is still the one from the original v1.0.0 submission (the Pro
  paywall screen; doesn't show any gambling content, so low risk to leave as-is for this
  cycle) — re-run that script too once unlocked.
