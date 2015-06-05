all : clean test

docs : playground html

test :
	@xcodebuild test -project Just.xcodeproj -scheme Just-OSX -destination 'platform=OS X' | xcpretty

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
