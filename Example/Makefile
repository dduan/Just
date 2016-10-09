test-integration: \
	clean \
	test-integration-spm \
	test-integration-cocoapods \
	test-integration-carthage

test-integration-spm:
	cd SPM && swift build

test-integration-cocoapods: \
	test-integration-cocoapods-iOS \
	test-integration-cocoapods-macOS \
	test-integration-cocoapods-watchOS \
	test-integration-cocoapods-tvOS

test-integration-cocoapods-iOS:
	cd Cocoapods && \
	pod install && \
	set -o pipefail && \
		xcodebuild \
		-workspace Example.xcworkspace \
		-scheme Example-iOS \
		-destination "name=iPhone 6s" \
		| xcpretty -ct

test-integration-cocoapods-macOS:
	cd Cocoapods && \
	pod install && \
	set -o pipefail && \
		xcodebuild \
		-workspace Example.xcworkspace \
		-scheme Example-macOS \
		| xcpretty -ct

test-integration-cocoapods-watchOS:
	cd Cocoapods && \
	pod install && \
	set -o pipefail && \
		xcodebuild \
		-workspace Example.xcworkspace \
		-scheme Example-watchOS \
		-destination "name=iPhone 6" \
		| xcpretty -ct

test-integration-cocoapods-tvOS:
	cd Cocoapods && \
	pod install && \
	set -o pipefail && \
		xcodebuild \
		-workspace Example.xcworkspace \
		-scheme Example-tvOS \
		-destination "name=Apple TV 1080p" \
		| xcpretty -ct

test-integration-carthage: \
	test-integration-carthage-iOS \
	test-integration-carthage-macOS \
	test-integration-carthage-watchOS \
	test-integration-carthage-tvOS

test-integration-carthage-iOS:
	cd Carthage && \
	carthage update --platform iOS && \
	set -o pipefail && \
		xcodebuild \
		-project Example.xcodeproj \
		-scheme Example-iOS \
		-destination "name=iPhone 6s" \
		| xcpretty -ct

test-integration-carthage-macOS:
	cd carthage && \
	carthage update --platform Mac && \
	set -o pipefail && \
		xcodebuild \
		-project Example.xcodeproj \
		-scheme Example-macOS \
		| xcpretty -ct

test-integration-carthage-watchOS:
	cd carthage && \
	carthage update --platform watchOS && \
	set -o pipefail && \
		xcodebuild \
		-project Example.xcodeproj \
		-scheme Example-watchOS \
		-destination "name=iPhone 6" \
		| xcpretty -ct

test-integration-carthage-tvOS:
	cd carthage && \
	carthage update --platform tvOS && \
	set -o pipefail && \
		xcodebuild \
		-project Example.xcodeproj \
		-scheme Example-tvOS \
		-destination "name=Apple TV 1080p" \
		| xcpretty -ct

clean:
	rm -rf Carthage/Carthage
	rm -rf Carthage/Cartfile.resolved
	rm -rf Cococapods/Pods
	rm -rf Cococapods/Podfile.lock
	cd SPM && swift build --clean
