test : clean
	@xcodebuild test -project Just.xcodeproj -scheme Just -destination 'platform=iOS Simulator,name=iPhone 6' | xcpretty

clean :
	@xcodebuild clean
	@rm -rf build
