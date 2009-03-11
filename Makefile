.PHONY : task_test test clean

task_test:
	xcodebuild -parallelizeTargets -target TaskUnitTest -configuration Debug -sdk macosx10.5 | grep -v setenv |grep -v '^objc'

test:
	xcodebuild -parallelizeTargets -target UnitTest -configuration Debug -sdk macosx10.5 | grep -v setenv |grep -v '^objc'

clean:
	xcodebuild -parallelizeTargets -target UnitTest -configuration Debug -sdk macosx10.5 clean

wc:
	wc */*.m */*.h test/*/*.m test/*/*.h
