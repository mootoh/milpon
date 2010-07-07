.PHONY : test_api_list task_test test clean

test_api_list:
	xcodebuild  -parallelizeTargets -target UnitTest-ListAPI -configuration UnitTest -sdk iphonesimulator3.0

test_api_task:
	xcodebuild  -parallelizeTargets -target UnitTest-TaskAPI -configuration UnitTest -sdk iphonesimulator3.0

task_test:
	xcodebuild -parallelizeTargets -target TaskUnitTest -configuration Debug -sdk macosx10.5 | grep -v setenv |grep -v '^objc'

test:
	xcodebuild -parallelizeTargets -target UnitTest -configuration Debug -sdk macosx10.5 | grep -v setenv |grep -v '^objc'

clean:
	xcodebuild -parallelizeTargets -target UnitTest -configuration Debug -sdk macosx10.5 clean

wc:
	wc */*.[mh]
