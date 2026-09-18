import SwiftUI
import BuildGraphGuard
import BuildGraphGuardUI

/// The demo app owns the *configuration*; the library owns the *rendering*.
///
/// That split is the point of the two-repo structure. `BuildGraphGuardUI` ships no
/// fixtures and no policy of its own — it renders whatever scenarios it is handed —
/// so a real adopter supplies their repository's policy file and their own project
/// files without forking the view. This app is that adopter, with its policy
/// compiled in rather than read from disk.
@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            BuildGraphReviewView(scenarios: DemoConfiguration.scenarios)
        }
    }
}

/// The app's own policy and scenario set, built from the library's primitives.
enum DemoConfiguration {

    /// Starts from the library's baseline and tightens it the way a real repository
    /// would.
    ///
    /// The tightening is deliberately one that *changes a verdict on screen*: the
    /// baseline's membership ceiling of 40 is meaningless in a four-file project, so
    /// the routine-work scenario — clean under the library defaults — comes back as
    /// "Needs review" here, because two files moving in one commit is worth a glance
    /// at this size. A customisation that no fixture ever reaches would let the app
    /// claim to demonstrate "bring your own policy" while rendering byte-identical
    /// output to the defaults.
    static let policy: BuildGraphPolicy = {
        var policy = BuildGraphPolicy.baseline
        policy.maximumMembershipChanges = 1
        return policy
    }()

    /// The library's sample scenarios, re-bound to this app's policy.
    ///
    /// Rebuilt rather than used as-is so the app demonstrates the thing an adopter
    /// actually does — bring your own policy — instead of demonstrating the
    /// library's defaults and calling it integration.
    static let scenarios: [ReviewScenario] = ReviewScenario.samples.map { sample in
        ReviewScenario(
            id: sample.id,
            title: sample.title,
            detail: sample.detail,
            baseline: sample.baseline,
            proposed: sample.proposed,
            policy: policy
        )
    }
}
