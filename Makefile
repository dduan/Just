all : clean test

test :
	@xcodebuild test -project Just.xcodeproj -scheme Just-OSX -destination 'platform=OS X' | xcpretty

playground :
	cp Just/Just.swift Docs/JustStarting.playground/Sources/Just.swift
	zip Docs/JustStarting.zip Docs/JustStarting.playground

clean :
	@xcodebuild clean
	@rm -rf build
