all : clean test

docs : playground html

test :
	@set -o pipefail \
	&& xcodebuild test -workspace Just.xcworkspace -scheme Just-OSX -destination 'platform=OS X' | xcpretty \
	&& xcodebuild test -workspace Just.xcworkspace -scheme Just-iOS -destination 'OS=9.1,name=iPhone 6 Plus' | xcpretty \
	&& xcodebuild test -workspace Just.xcworkspace -scheme Just-tvOS -destination 'OS=9.0,name=Apple TV 1080p' | xcpretty \
	&& pod lib lint

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
