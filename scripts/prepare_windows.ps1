Write-Output "Running flutter pub get..."
flutter pub get
Write-Output "Dart format..."
dart format .
Write-Output "Done. Commit changes and push to your Mac or CI."
