# Simon Says - Flutter

Single-file Flutter game with a GitHub Actions APK build workflow.

## Build locally
```bash
flutter pub get
flutter run
flutter build apk --release
```

## GitHub Actions
Push to `main`, or run the workflow manually from GitHub Actions.
The release APK is uploaded as the `simon-says-apk` artifact.
