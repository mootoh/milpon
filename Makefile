.PHONY : test clean
test:
	xcodebuild -parallelizeTargets -target UnitTest -configuration Debug -sdk macosx10.5 | grep -v setenv |grep -v '^objc'

clean:
	xcodebuild -parallelizeTargets -target UnitTest -configuration Debug -sdk macosx10.5 clean
