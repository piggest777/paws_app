# Paws of Peace

A Flutter app that helps Paws of Peace volunteers track supply requests, packing, and shipments from shared inventory.

## Volunteer workflows

- **Requests** creates requests, tracks their status, and groups supplies into boxes with QR labels.
- **Sent Items** organizes boxes into delivery batches and tracks which packages are ready to ship. Volunteers can export a batch summary as CSV.
- **Storage** manages supply records and uses barcode scanning to find items. The app can also generate PDF paperwork for packed supplies.

The app uses Dart and Flutter, Google sign-in through Firebase Authentication, and Cloud Firestore for shared records. The main navigation and Firebase initialization are in [`lib/main.dart`](lib/main.dart). Screens live in [`lib/src/views/`](lib/src/views), with models and Firebase operations in [`lib/src/models/`](lib/src/models) and [`lib/src/services/`](lib/src/services).

## Run with a development backend

1. Install Flutter with Dart 3.1 or later in the Dart 3 series, plus the toolchain for your target platform. Run `flutter pub get` from the repository root.
2. Create a separate Firebase development project. Enable Cloud Firestore and Google sign-in, then use [FlutterFire setup](https://firebase.google.com/docs/flutter/setup) to generate Firebase options for Android, iOS, or web. For web, update the separate Firebase initialization in [`lib/main.dart`](lib/main.dart) and the Google sign-in client ID in [`web/index.html`](web/index.html). Configure native Google sign-in for the app identifiers you register.
3. Configure Firestore access rules for your test accounts. Add the test account to the development project's `users` collection with an `email` field. Seed sample inventory and initialize the `counters/boxId` and `counters/batchDeliveryID` documents with numeric `current` fields to test packing and dispatch.
4. Run `flutter run` with a configured device or browser selected. Use a camera-capable mobile device to try scanning.

The repository contains the client app. Full workflows require a configured backend with sample records. The storage barcode maintenance action also depends on a Cloud Function managed separately from the client.
