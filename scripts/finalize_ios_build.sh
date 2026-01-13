#!/usr/bin/env bash
set -e

echo "Running flutter pub get..."
flutter pub get

echo "Installing CocoaPods (if Podfile exists)..."
cd ios
if [ -f Podfile ]; then
  pod install
fi
cd ..

echo "Build (optional): flutter build ios --release"
echo "To create an IPA (optional): flutter build ipa --export-method ad-hoc"
echo "Opening Xcode workspace to set signing and archive..."
open ios/Runner.xcworkspace

echo "Done. In Xcode: select the Runner target → Signing & Capabilities → set Team, then Product → Archive to export/upload."
