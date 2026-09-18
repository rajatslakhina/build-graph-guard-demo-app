# BuildGraphGuard Demo

**Four proposed edits to an Xcode project file. Three of them are the ones nobody reviews.**

This is a SwiftUI app that renders a build-graph review screen: for each scenario it parses two project files, diffs them *semantically*, judges the diff against a policy, and shows the verdict, the findings and the changes. It consumes **[build-graph-guard-kit](https://github.com/rajatslakhina/build-graph-guard-kit)** as a remote, version-pinned Swift package — there is no copy of the library in this repository.

---

## Why this matters

Xcode 27.2 beta replaces `project.pbxproj` with `project.xcproj`, a JSON format Apple describes as easier for coding agents to edit. Teams learned to skim the project file when it was unreadable; the format changed, and the habit didn't. The scenarios in this app are the three shapes that habit misses:

1. **"Add the promo code screen."** The agent does that — and also disables `ENABLE_USER_SCRIPT_SANDBOXING` and adds a `CODE_SIGN_IDENTITY[config=Release]` override. The unconditioned signing key is untouched, so a reviewer reading the Debug column sees nothing. **Blocked.**
2. **The look-alike re-point.** `example-org` becomes `example-0rg`, the pin moves from a version to a branch, the deployment floor drops to 15.0, and the app target starts compiling a file that resolves outside the project directory (`../shared-tools/Telemetry.swift`). Every version number on screen stays plausible. **Blocked.**
3. **Routine feature work.** The same feature, its tests, one warning flag. Nothing frozen moves. **Needs review** under this app's tightened ceiling, and *clean* under the library's defaults — which is the point of the tightening.
4. **The migration.** The same project in both formats. The bridge projects the legacy file into the same graph and hoists settings that are uniform across configurations, so the migration reads as **no structural change at all** rather than as every setting in the file moving at once — plus one advisory naming exactly what a cross-format comparison cannot check.

A gate that fires on scenario 3 under default settings would be switched off within a week. That is why the library's baseline leaves it clean, and why this app has to change something explicit to make it speak up.

---

## Screenshots

**There are none, and that is a statement of fact rather than an omission.**

The app has never been launched. Automated access to Xcode and Simulator was requested three times while this repository was built and refused each time, verbatim: `Computer-use access to "Xcode 26.3", "Simulator" can't be approved during a scheduled run.` No screenshot exists, no `Demo/Screenshots/` directory exists, and nothing in this README describes an image that isn't here.

What *is* verified is below, and "compiles for a Simulator destination" is not the same claim as "ran on a Simulator."

---

## How to run it

```bash
git clone https://github.com/rajatslakhina/build-graph-guard-demo-app.git
cd build-graph-guard-demo-app
open Demo.xcodeproj
```

Then in Xcode: wait for **Package Dependencies** to resolve `build-graph-guard-kit` from GitHub, select the **Demo** scheme (it is committed as a shared scheme, so it is there on a fresh clone), pick any iOS Simulator, and **Build & Run**.

The app opens on scenario 1 — blocked, with findings visible — so the default state shows the product doing its job. Use the picker at the top to move between the four.

Requires Xcode 16 or later; the project targets iOS 17 and Swift 6.

---

## How it is wired

```
Demo.xcodeproj
└── Demo (app target)
    ├── XCRemoteSwiftPackageReference → github.com/rajatslakhina/build-graph-guard-kit
    │   requirement: upToNextMajorVersion, minimumVersion 1.1.2
    ├── BuildGraphGuard      ← the engine: policy type, sample project files
    └── BuildGraphGuardUI    ← the review screen
```

**The dependency is remote and pinned to a published tag, not a local path and not a branch.** A branch pin means every clone and every CI run resolves whatever `main` happens to be that day — which is the wrong default for anything, and a strange one for a portfolio artifact whose subject is unreviewed dependency drift.

**The app imports both products for real reasons.** `DemoApp.swift` owns the *configuration* — a `BuildGraphPolicy` built from the library's baseline and tightened, plus the scenario set rebound to it — and hands it to the library's view. `BuildGraphGuardUI` ships no fixtures and no policy of its own; it renders what it is given. That split is what lets a real adopter supply their repository's policy without forking the view, and this app is that adopter.

The tightening is deliberately one that changes a verdict on screen (`maximumMembershipChanges = 1`, down from the baseline's 40, which is meaningless in a four-file project). A customisation no fixture ever reaches would let this app claim to demonstrate "bring your own policy" while rendering output byte-identical to the defaults.

---

## Verification

**What was verified:**

- **This repo's CI** (see the [Actions tab](https://github.com/rajatslakhina/build-graph-guard-demo-app/actions)) runs `xcodebuild -resolvePackageDependencies` and then `xcodebuild build -scheme Demo -destination 'generic/platform=iOS Simulator'` on `macos-15`. That is the cheapest honest substitute for a human opening the project: it proves the remote package genuinely resolves from github.com at its published tag, and that the app compiles against it.
- The destination is `generic/platform=iOS Simulator`, never a named device. Pinning to `name=iPhone 16,OS=latest` ties the job to whichever simulator *runtimes* happen to be installed on that day's runner image, and they are not guaranteed. A compile check needs no device to exist.
- `Demo.xcodeproj/project.pbxproj` was checked for balanced braces and parentheses, 24-hex-character object ids, and zero dangling object references — using this project's own `OpenStepPlist` scanner and `PbxprojBridge`, which is a pleasant way to find out the library works.
- The library repo itself: `swift build -Xswiftc -warnings-as-errors` clean from a wiped `.build`, 119 tests passing, and green CI on Linux and macOS.

**What was not verified:**

- **The app has never been built locally and never been run on a Simulator.** See Screenshots above for why. CI compiling it is evidence that it compiles; it is not evidence that it runs, and this README does not treat the two as interchangeable.

---

## Licence

MIT. See [LICENSE](LICENSE).
