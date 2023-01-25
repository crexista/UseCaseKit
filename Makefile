USE_RBENV=true

ifeq ($(USE_RBENV),true)
    BUNDLE := rbenv exec bundle

else
    BUNDLE := bundle

endif

echo:
	$(BUNDLE) --version

install:
ifeq ($(USE_RBENV),true)
	rbenv install -s
	rbenv rehash
else
	echo "Skip rbenv setup..."
endif
	$(BUNDLE) install

test:
	make install
	$(BUNDLE) exec fastlane mac test
	$(BUNDLE) exec fastlane ios test

clean:
	rm -rf vendor
	rm -rf .build
	rm -rf .swiftpm
	rm -rf Package.resolved

format:
	SDKROOT=(xcrun --sdk macosx --show-sdk-path);swift run -c release swiftlint --fix --format
