test : clean
	@xcodebuild test -project Just.xcodeproj -scheme Just-OSX -destination 'platform=OS X' | xcpretty

clean :
	@xcodebuild clean
	@rm -rf build
