all : clean test-OSX

docs : playground html

test-iOS:
	set -o pipefail && \
		xcodebuild \
		-project Just.xcodeproj \
		-scheme Just \
		-destination "name=iPhone 6s" \
		test \
		| xcpretty -ct

test-OSX:
	set -o pipefail && \
		xcodebuild \
		-project Just.xcodeproj \
		-scheme Just \
		test \
		| xcpretty -ct

test-tvOS:
	set -o pipefail && \
		xcodebuild \
		-project Just.xcodeproj \
		-scheme Just \
		-destination "name=Apple TV 1080p" \
		test \
		| xcpretty -ct

playground :
	@mkdir -p Docs/QuickStart.playground/Sources
	@cp Just/Just.swift Docs/QuickStart.playground/Sources/Just.swift
	cd ./Docs && zip -r -X QuickStart.zip QuickStart.playground/*

html :
	@docco -L Docs/docco.json -l linear -o Docs/html Docs/QuickStart.playground/Contents.swift
	mv Docs/html/Contents.html Docs/html/QuickStart.html

clean :
	@xcodebuild clean
	@rm -rf build
