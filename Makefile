.PHONY: test

test:
	xcodebuild -target MilkCocoaTest -configuration Debug -sdk iphonesimulator4.2
