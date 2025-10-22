#!/bin/bash
echo "🔧 Forcing iOS deployment target to 12.0..."
find ios/Runner.xcodeproj -type f -name "project.pbxproj" -exec sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 13.0;/IPHONEOS_DEPLOYMENT_TARGET = 12.0;/g' {} +
find ios/Flutter -type f -name "AppFrameworkInfo.plist" -exec sed -i '' 's/<string>13.0<\/string>/<string>12.0<\/string>/g' {} +
find ios -type f -name "Podfile" -exec sed -i '' 's/platform :ios, '\''13.0'\''/platform :ios, '\''12.0'\''/g' {} +
echo "✅ iOS deployment target successfully forced to 12.0!"
