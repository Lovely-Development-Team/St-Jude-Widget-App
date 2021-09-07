FILE=build_app
FILE_HASH=$(sha3sum build_app)
LAST_BUILD_HASH=$(cat last_build 2>/dev/null)
# Build file must exist and be different from the last we processed
if test -f "$FILE" -a "$FILE_HASH" != "$LAST_BUILD_HASH"; then
	rm last_build
	# Bump the build version
	agvtool bump
	# Store the new build number for use in commit
	NEW_BUILD=$(agvtool what-version -terse)
	PROJECT_FILE=$(find . -maxdepth 1 -name '*.xcodeproj')
	# Build the app and upload
	xcodebuild -project "$PROJECT_FILE" -scheme "St Jude (iOS)" -configuration Release -archivePath ./app.xcarchive  archive
	xcodebuild -exportArchive -archivePath ./app.xcarchive -exportOptionsPlist exportOptions.plist
	# PR with new version number
	git checkout -B "release/$NEW_BUILD"
	rm build_app
	git add "$PROJECT_FILE/project.pbxproj"
	git add build_app
	git commit -m "Bump build ($NEW_BUILD)"
	gh pr create --title "Release $NEW_BUILD" --body "" -B main
	# Store hash of this build file
	rm last_build
	sha3sum $FILE >> last_build
	# Return to the main branch
	git checkout main
fi
