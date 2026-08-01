# Bầu Cua Tôm Cá — Vietnamese Dice Game

Native SwiftUI iOS app for Bầu Cua Tôm Cá, the traditional Vietnamese dice game (Bầu/Cua/
Tôm/Cá/Gà/Nai — gourd/crab/shrimp/fish/rooster/deer). Bundle `com.quyenngo.baucua`. One
app in a 5-app Vietnamese-games lineup; built following the house pattern established by
the sibling card game `~/Projects/SamLoc` (bundle `com.quyenngo.samloc`, already shipped).

**Status: 🟢 SUBMITTED, WAITING_FOR_REVIEW (2026-08-01).** App id `6796833635`, version `1.0.0`
(id `8b0e943a-241f-4b66-8b7e-c3e8d81b4537`), build `5137618b-f6a5-4aab-a178-72d83c206d3d`
attached, reviewSubmission `a6a5a951-cc67-436d-a2d5-9226ef4e812e`. Age rating declaration used
`gamblingSimulated: "FREQUENT_OR_INTENSE"` — confirmed accepted by Apple's API on first try
(live-verified, not guessed). Release type: automatic (`AFTER_APPROVAL`).

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

Bầu Cua Tôm Cá is traditionally a betting/wagering dice game. This app is a **pure
chip-based simulation with zero connection to real money or real value**, and that must
stay true forever:

- **Chips are NEVER purchasable with real money.** No IAP may sell chips, currency, or
  anything that affects betting odds/payouts. Do not add a "buy chips" / "refill chips"
  IAP, even disguised as "remove the wait" — that's a real-money gambling-adjacent
  mechanic and is exactly what this app (and the whole lineup, per SamLoc's CLAUDE.md) is
  built to avoid.
- If the chip balance hits 0, the player always gets a **free** top-up
  (`GameModel.claimFreeTopUp()` — `GameModel.freeTopUpAmount` chips, first one instant,
  then gated by `GameModel.freeTopUpCooldown`, 4h). Never make this a paid path.
- The Pro IAP (`com.quyenngo.baucua.pro`, non-consumable, see `Core/PurchaseManager.swift`)
  unlocks **cosmetic/QoL only**: alternate dice/bowl visual themes, a detailed stats
  screen, no ads, and unlimited free chip refills (`GameModel.unlimitedFreeRefills` — this
  removes the cooldown timer, it does **not** grant purchasable chips). Pro must never
  touch odds, payouts, or the chip economy. See the compliance comment block at the bottom
  of `PurchaseManager.swift` before changing anything there.
- **Age rating flag for the later ASC step:** unlike the other apps in this lineup, this
  one is a dice/betting simulation and will need a **"Simulated Gambling" content
  descriptor** set in the ASC review-info script when that step happens. Don't forget it —
  it's the one thing that makes this app's ASC setup differ from SamLoc's.

## The game

- 6 symbols (`Core/Symbol.swift`): Bầu, Cua, Tôm, Cá, Gà, Nai. Emoji placeholders
  (🍐🦀🦐🐟🐓🦌) — real dice-face art is a later step.
- Player starts with 1000 chips (`GameModel.startingChips`), persisted via
  `UserDefaults` (`AppStorage`-style keys prefixed `bc_`).
- **Betting phase:** stake chips on any of the 6 symbols, multiple simultaneous bets
  allowed at different amounts (`GameModel.bets: [Symbol: Int]`). Must stake ≥1 chip on
  ≥1 symbol before rolling (`GameModel.canRoll`).
- **Roll:** 3 dice, each independently uniform-random over the 6 symbols
  (`GameModel.roll()` → `Symbol.allCases.randomElement()!` ×3). `DiceBowlView` animates a
  ~0.9s shake (SwiftUI offset/rotation jitter) before settling.
- **Payout**, per symbol bet on: count matches among the 3 dice (0–3). 0 matches loses the
  stake. 1/2/3 matches returns the stake plus stake × matches (net gain = stake × matches —
  e.g. bet 10, 2 matches → net +20, total returned 30). Implemented in
  `Core/Bet.swift` (`BetResult.netChange` / `.totalReturned`) and settled in
  `GameModel.settle(dice:staked:)`.
- **Round loop:** after settling, bets clear and the board returns to the betting phase.
  No AI opponent — solo vs. the house — so there's no `AIPlayer.swift` and no difficulty
  concept anywhere in this app (deliberate difference from SamLoc's structure).
- **Stats** (`GameModel.roundsPlayed` / `.biggestWin` / `.bestStreak`, persisted): shown
  in the Pro-only stats sheet (`StatsSheetView`, defined privately inside
  `Views/HomeView.swift` rather than as its own file).

## Structure

- `BauCua/Core/` — `Symbol.swift`, `Bet.swift` (`Bet` + `BetResult`), `GameModel.swift`
  (betting/rolling/payout/free-top-up + `#if DEBUG` `captureSetup(_:)` for screenshots),
  `PurchaseManager.swift`, `Localization.swift` (copied verbatim from SamLoc — no
  app-specific strings live in this file).
- `BauCua/Views/` — `HomeView`, `GameView`, `DiceBowlView` (the shaking dice/bowl),
  `BetBoardView` (the 6-symbol betting grid), `RulesView`, `OnboardingView`, `UpgradeView`.
- `BauCua/{en,vi}.lproj/Localizable.strings` — real hand-written bilingual UI strings
  (not machine-translated), using the correct terms: Bầu, Cua, Tôm, Cá, Gà, Nai, "đặt
  cược" (place bet), "lắc" (shake/roll). No `%@`-for-name templated strings exist in this
  app (no opponent), so SamLoc's documented "%@ = You" grammar trap doesn't apply here —
  still worth a re-check if templated strings are ever added.
- `capture_shots.py` — drives the simulator via `BC_CAPTURE` / `BC_LANG` DEBUG launch args
  (mirrors SamLoc's `SL_CAPTURE`/`SL_LANG` convention) to produce real in-app screenshots
  into `screenshots/final/{en,vi}/`. Capture scenarios: `home`, `betting`, `rolling`,
  `result`, `upgrade`, `rules` (wired in `ContentView.swift` + `GameModel.captureSetup`).
- `make_icon.py` — generates the real app icon: a bold gold crab (Cua) silhouette emblem
  on a red/gold Tet-festival gradient. See "App-Store-ready pass" below for details.
- `project.yml` — XcodeGen. Regenerate the `.xcodeproj` with `xcodegen generate` after
  adding/removing files (or just run `./rebuild.sh`).

## Judgment calls made during this build (not spelled out in the original spec)

- **`Bet.swift` scope:** holds both the staging-area line item (`Bet`) and the
  post-roll outcome (`BetResult`), since a single-purpose `Bet` struct alone wouldn't
  carry match-count/payout math anywhere sensible.
- **No separate `StatsView.swift` file:** the spec's target file list only names
  `HomeView/GameView/DiceBowlView/BetBoardView/RulesView/OnboardingView/UpgradeView`, but
  also calls out a Pro "detailed stats screen" as a feature. Implemented as a small private
  `StatsSheetView` inside `Views/HomeView.swift` rather than adding an eighth Views file,
  to stay literally within the given structure.
- **Free top-up UX:** first time the balance hits 0, the top-up is instant (no
  `lastFreeTopUpDate` yet); after that it's gated by a 4-hour cooldown for free-tier
  players, shown as a live countdown in `GameView`'s `topUpOverlay`. Pro
  (`unlimitedFreeRefills`) always shows the "Claim Free Chips" button with no wait — still
  free, just no timer, per the compliance constraint.
- **Bet input control:** used tap-to-add-current-chip-value + long-press-to-clear per
  symbol cell (`BetBoardView`) rather than steppers, to keep the 6-symbol grid compact on
  one screen; chip denominations are 10/50/100/500, selectable via a pill row in
  `GameView`.
- `rebuild.sh` didn't exist in SamLoc (despite being referenced as a convention) — built it
  fresh, closely modeled on `~/Projects/ChineseChess/rebuild.sh`'s clean/build-for-sim/
  build-for-device shape, plus an `xcodegen generate` step up front.

## Build

```
cd ~/Projects/BauCua
xcodegen generate
xcodebuild -project BauCua.xcodeproj -scheme BauCua -destination 'generic/platform=iOS Simulator' build
```

Verified clean simulator build + runtime smoke test (launch, betting screen, roll/settle,
result overlay) on iPhone 17 Pro simulator during this build pass — payout math confirmed
correct (e.g. 50-chip stake × 2 matches → +100 net, shown and computed identically).

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
  `support.html`), following the exact template/CSS of `~/Projects/fanorona-legal/`. Live
  at **https://qngo9871-cmyk.github.io/baucua-legal/** (public repo
  `qngo9871-cmyk/baucua-legal`, GitHub Pages enabled from `main`/`/`). Unlike the other
  legal sites in this lineup, this one carries **explicit, prominent no-real-money /
  not-a-gambling language** per this app's compliance constraint (see above): `support.html`
  has a callout-boxed statement that chips are virtual only, cannot be purchased with real
  money, hold no cash value, and that the app is not a gambling app; `privacy.html`'s
  Purchases section explicitly states the Pro IAP is cosmetic/QoL-only (alternate
  dice/bowl themes, detailed stats, no ads, unlimited free refill wait-removal) and never
  sells or affects chips, odds, or payouts. The Pro feature list in `support.html` was
  pulled from the actual current code (`PurchaseManager.swift`'s compliance comment +
  `Localizable.strings`'s `upgrade.feature.*` keys), not guessed.

**⚠️ Reminder for the ASC step (still pending):** this privacy site now publicly and
explicitly commits to the no-real-money stance — so when App Store Connect registration
happens, **do not forget the "Simulated Gambling" age-rating content descriptor** in the
review-info script. This is still the one thing that makes this app's ASC setup differ
from SamLoc's, and it's now doubly important to get right since the published legal site
is making public claims that the age rating needs to match.

## Not done yet (later steps, not this session's scope)

- App Store Connect: bundle ID registration, app record, IAP product, pricing, review
  info (**remember the Simulated Gambling content descriptor**), screenshots upload.
- Sideload / device testing, TestFlight, submission.
