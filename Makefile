all : clean test-macOS

docs : playground html

test: test-iOS test-macOS test-tvOS

test-iOS:
	set -o pipefail && \
		xcodebuild \
		-project Just.xcodeproj \
		-scheme Just \
		-destination "name=iPhone 6s" \
		test \
		| xcpretty -ct

test-macOS:
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

test-integration:
	rm -rf DistributionTests
	git clone https://github.com/dduan/DistributionTests.git
	cd DistributionTests && \
		git checkout f161a0df63a2da168e190b2f6127f781d924304c && \
		./customize --name Just --git "https://github.com/JustHTTP/Just.git" --major 0 && \
		make -f Makefile

playground :
	@mkdir -p Docs/QuickStart.playground/Sources
	@cp Sources/Just/Just.swift Docs/QuickStart.playground/Sources/Just.swift
	cd ./Docs && zip -r -X QuickStart.zip QuickStart.playground/*

html :
	@docco -L Docs/docco.json -l linear -o Docs/html Docs/QuickStart.playground/Contents.swift
	mv Docs/html/Contents.html Docs/html/QuickStart.html

clean :
	@xcodebuild clean
	@rm -rf build
