all : clean test-macOS

docs : playground html

test: test-iOS test-macOS test-tvOS test-swiftpm

test-iOS:
	set -o pipefail && \
		xcodebuild \
		-project Just.xcodeproj \
		-scheme Just \
		-destination "name=iPhone X" \
		test

test-macOS:
	set -o pipefail && \
		xcodebuild \
		-project Just.xcodeproj \
		-scheme Just \
		test

test-tvOS:
	set -o pipefail && \
		xcodebuild \
		-project Just.xcodeproj \
		-scheme Just \
		-destination "name=Apple TV" \
		test

test-swiftpm:
	swift test

playground:
	@mkdir -p Docs/QuickStart.playground/Sources
	@cp Sources/Just/Just.swift Docs/QuickStart.playground/Sources/Just.swift
	cd ./Docs && zip -r -X QuickStart.zip QuickStart.playground/*

html :
	@docco -L Docs/docco.json -l linear -o Docs/html Docs/QuickStart.playground/Contents.swift
	mv Docs/html/Docs/QuickStart.playground/Contents.html Docs/html/QuickStart.html

clean :
	@xcodebuild clean
	@rm -rf build
