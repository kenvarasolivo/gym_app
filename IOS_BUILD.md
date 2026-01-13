# iOS Build — Anleitung (kurz)

Ziel: Auf dem Mac nur noch Xcode öffnen und archivieren müssen.

Vorbereitung (kannst du hier unter Windows ausführen):

- Im Projekt-Root ausführen:

```powershell
# Windows
scripts\prepare_windows.ps1
```

Was das Skript macht:
- `flutter pub get` – alle Abhängigkeiten herunterladen
- `dart format .` – optionales Formatieren

Auf dem Mac (empfohlen):

1. Repository pullen / kopieren.
2. Im Projekt-Root auf dem Mac:

```bash
# im mac Terminal
chmod +x scripts/finalize_ios_build.sh
./scripts/finalize_ios_build.sh
```

3. Das Skript öffnet `ios/Runner.xcworkspace` in Xcode. In Xcode:
- Wähle das `Runner` target → `Signing & Capabilities` → setze dein Apple Team.
- Product → Archive → Distribute App (App Store / Ad-Hoc / Enterprise).

Hinweise / Probleme:
- Du kannst kein IPA oder echten iOS-Build auf Windows erzeugen — die finale Signatur und das Archiv müssen auf macOS/Xcode erfolgen.
- Falls CocoaPods Probleme macht: auf M1 Macs ggf. `arch -x86_64 pod install` verwenden.
- Wenn du automatische Builds willst, kann ich eine GitHub Actions Workflow-Datei anlegen.
