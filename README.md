# CutTrack — TestFlight-ready project

This package is arranged for a real native iPhone build and TestFlight distribution.

## What is included

- SwiftUI iPhone app
- Apple Health / Apple Watch active-calorie import
- Running workout detection
- Food and macro logging
- Barcode scanning with VisionKit
- Open Food Facts product lookup
- Built-in workouts for kettlebells, running and cycling
- Interval timer and workout history
- Completed workouts saved to Apple Health
- Weight charts with Swift Charts
- Smart notifications
- Home-screen widget
- Lock Screen / Dynamic Island Live Activity
- App icon and asset catalog
- HealthKit, App Group and Live Activity configuration
- XcodeGen project definition
- Codemagic TestFlight workflow
- Fastlane TestFlight lane

## What you need before TestFlight can accept it

1. An active Apple Developer Program membership.
2. An App Store Connect app record with bundle ID `dk.blbit.cuttrack`.
3. A Widget Extension identifier: `dk.blbit.cuttrack.widgets`.
4. An App Group named `group.dk.blbit.cuttrack`.
5. HealthKit enabled for the main App ID.
6. A GitHub repository containing this folder.
7. A Codemagic account connected to GitHub and App Store Connect.

## Phone-first route using Codemagic

1. Create a private GitHub repository from your iPhone.
2. Upload all files in this ZIP to that repository.
3. In Apple Developer, register:
   - `dk.blbit.cuttrack`
   - `dk.blbit.cuttrack.widgets`
   - `group.dk.blbit.cuttrack`
4. Create the CutTrack app in App Store Connect.
5. Connect the repository in Codemagic.
6. Add an App Store Connect integration named exactly:
   `CutTrack App Store Connect`
7. Add environment variable `APP_STORE_ID` containing the numeric App Store Connect app ID.
8. Start the `cuttrack-testflight` workflow.
9. When processing completes, add yourself as an internal tester in TestFlight.
10. Install CutTrack from Apple’s TestFlight app.

## Bundle IDs

Change the bundle identifiers in `project.yml` before the first build if these identifiers are
already taken in your Apple Developer account.

## First-build troubleshooting

The most common first-build issue is signing. Confirm that the main app, widget extension and
App Group exist in Apple Developer and that Codemagic downloaded matching profiles.

The first TestFlight upload still requires your Apple account because only the account owner or
an authorized App Store Connect user can sign and upload the app.


## Workout support

The Workouts tab includes:

- Kettlebell full-body and swing sessions
- Easy running and run/walk intervals
- Easy cycling and cycling intervals
- A live timer with pause/resume
- Round-by-round interval prompts
- Optional active-calorie and distance entry
- Local workout history
- Saving completed workouts to Apple Health

A future Apple Watch extension can add live heart rate, route recording and wrist controls.
