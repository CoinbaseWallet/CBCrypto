format:
	ios/Pods/SwiftFormat/CommandLineTool/swiftformat ios/Source --header "Copyright (c) 2017-{year} Coinbase Inc. See LICENSE"
	android/gradlew ktlintFormat -p android

lint:
	Pods/SwiftLint/swiftlint

init:
	git submodule update --force

