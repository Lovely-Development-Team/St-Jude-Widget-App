set -ex
FILE=build_app
FILE_HASH=$(sha3sum $FILE)

LAST_BUILD_FILE=last_build
LAST_BUILD_HASH=$(cat $LAST_BUILD_FILE || echo "") 2>/dev/null

ICON_FILE=icon.png
ICON_HASH=$(sha3sum $ICON_FILE)

LAST_ICON_FILE=icon_hash
LAST_ICON_HASH=$((cat $LAST_ICON_FILE || echo "") 2>/dev/null)

CHANGE_ICON=false

# PR body
BODY=$(cat $FILE)

PROJECT_FILE=$(find . -maxdepth 1 -name '*.xcodeproj')

# Build file must exist and be different from the last we processed
if test -f "$FILE" -a "$FILE_HASH" != "$LAST_BUILD_HASH"; then
	if test -f "$ICON_FILE" -a "$ICON_HASH" != "$LAST_ICON_HASH"; then
		CHANGE_ICON=true
		npx app-icon generate
		sha3sum $ICON_FILE > $LAST_ICON_FILE
	fi 
	touch $LAST_BUILD_FILE
	rm $LAST_BUILD_FILE
	# Bump the build version
	agvtool bump
	# Store the new build number for use in commit
	NEW_BUILD=$(agvtool what-version -terse)
	# Clean up previous builds
	rm -rf build
	xcodebuild clean
	# Build the app and upload
	xcodebuild -project "$PROJECT_FILE" -scheme "St Jude (iOS)" -configuration Release -destination 'platform=iOS Simulator,name=iPhone 12' -archivePath ./app.xcarchive -allowProvisioningUpdates archive
	xcodebuild -exportArchive -archivePath ./app.xcarchive -exportOptionsPlist exportOptions.plist
	# PR with new version number
	git checkout -B "release/$NEW_BUILD"
	# Store hash of this build file
	sha3sum $FILE > $LAST_BUILD_FILE
	# Remove file & continue PR
	rm $FILE
	git add "$PROJECT_FILE/project.pbxproj"
	git add "$FILE"
	if "$CHANGE_ICON" == "true"; then
		git add Shared/Assets.xcassets/AppIcon.appiconset/*
	fi
	git commit -m "Bump build ($NEW_BUILD)"
	git push -u origin "release/$NEW_BUILD"
	gh pr create --title "Release $NEW_BUILD" --body "$BODY" -B main
	# Return to the main branch
	git checkout main
	# Remove app.xcarchive
	rm -rf app.xcarchive
fi
