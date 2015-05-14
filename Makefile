all : clean test

docs : playground html

test :
	@xcodebuild test -project Just.xcodeproj -scheme Just-OSX -destination 'platform=OS X' | xcpretty

playground :
	@mkdir -p Docs/JustStarting.playground/Sources
	@cp Just/Just.swift Docs/JustStarting.playground/Sources/Just.swift
	@zip -r -X Docs/JustStarting.zip Docs/JustStarting.playground/*

html :
	@docco -L Docs/docco.json -l linear -o Docs/html Docs/JustStarting.playground/Contents.swift
	mv Docs/html/Contents.html Docs/html/JustStarting.html

clean :
	@xcodebuild clean
	@rm -rf build
