FILE=build_app
LAST_BUILD_FILE=last_build
FILE_HASH=$(sha3sum $FILE)
LAST_BUILD_HASH=$(cat $LAST_BUILD_FILE 2>/dev/null)
# Build file must exist and be different from the last we processed
if test -f "$FILE" -a "$FILE_HASH" != "$LAST_BUILD_HASH"; then
	rm $LAST_BUILD_FILE
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
	# Store hash of this build file
	sha3sum $FILE > $LAST_BUILD_FILE
	# Remove file & continue PR
	rm $FILE
	git add "$PROJECT_FILE/project.pbxproj"
	git add "$FILE"
	git commit -m "Bump build ($NEW_BUILD)"
	git push -u orign "release/$NEW_BUILD"
	gh pr create --title "Release $NEW_BUILD" --body "$(cat $FILE)" -B main
	# Return to the main branch
	git checkout main
	# Remove app.xcarchive
	rm -rf app.xcarchive
fi
