# Preview notes (Flutter container)

This repository’s **Preview** is configured to run the Flutter app as a **web build** and serve it over HTTP.
This avoids emulator/device requirements and ensures the migrated UI is visible in the preview iframe.

## Why you may see “app is being generated”
If the preview serves `web/index.html` without the compiled Flutter web artifacts (e.g. `flutter_bootstrap.js`, `main.dart.js`),
Flutter cannot start and the preview system may show a placeholder “app is being generated” screen.

## Local run (web)
From `hello-world-flutter-app-10256-10266/hello_world_frontend`:

```bash
flutter pub get
flutter build web --release
python3 -m http.server 3000 --directory build/web
```

Then open: http://localhost:3000
