# Side Street

A Flutter application for discovering and sharing underrated local spots. Share hidden gems, explore local places, and save favorites.

## Features

- Account creation and sign-in.
- Add spots with photos and manage posted places.
- Browse locations, search by keywords and location, and filter by category.
- Save favorites and manage a profile.

## Stack

Dart, Flutter, Firebase Authentication, Cloud Firestore, Firebase Storage, and image_picker.

## Source guide

- Authentication: `lib/auth_gate.dart`, `lib/login_screen.dart`, `lib/signup_screen.dart`.
- Discovery: `lib/home_screen.dart`, `lib/place_details_screen.dart`.
- Place management: `lib/add_spot_screen.dart`, `lib/edit_spot_screen.dart`, `lib/my_spots_screen.dart`.
- Personalization: `lib/favorites_screen.dart`, `lib/profile_screen.dart`, `lib/settings_screen.dart`.

## Local development

Use a Flutter SDK compatible with the package's Dart requirement, `^3.10.7`.

1. Clone the repository and open its directory.
2. Run `flutter pub get`.
3. Configure a Firebase project you control for your target platform, including Authentication, Firestore, and Storage. Review `lib/firebase_options.dart` and configure service access rules.
4. Start an emulator or connect a device, then run `flutter run`.

Connected features require Firebase access and platform configuration.
