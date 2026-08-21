# Bầu Cua Tôm Cá — Vietnamese Dice Game

Native SwiftUI iOS app for Bầu Cua Tôm Cá, the traditional Vietnamese dice game (Bầu/Cua/
Tôm/Cá/Gà/Nai — gourd/crab/shrimp/fish/rooster/deer). Bundle `com.quyenngo.baucua`. One
app in a 5-app Vietnamese-games lineup; built following the house pattern established by
the sibling card game `~/Projects/SamLoc` (bundle `com.quyenngo.samloc`, already shipped).

**Status: 🟡 7-day trial-then-lock gate added 2026-08-22, code-complete, NOT YET SUBMITTED.**
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
compliance comment block in `PurchaseManager.swift`). **Not yet
archived/submitted** — needs a version bump (currently still 1.0.0 build 2) and
an ASC submission pass before this ships; sales data as of 2026-08-22 showed 36
downloads since 2026-08-01 (29 from VN) with **zero** IAP conversions, which is
what prompted this fix.

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
