test :
	@xcodebuild test -project Requests.xcodeproj -scheme Requests -destination 'platform=iOS Simulator,name=iPhone 6' | xcpretty
