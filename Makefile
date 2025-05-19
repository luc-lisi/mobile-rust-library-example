ANDROID_ABIS = armeabi-v7a arm64-v8a x86 x86_64
IOS_TARGETS = aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim

RUST_BUILD_DIR := rust/target/release
OUT_DIR = ./dist

ANDROID_ARTIFACT_DIR = $(OUT_DIR)/android/android-artifacts
IOS_ARTIFACT_DIR = $(OUT_DIR)/ios

ANDROID_PACKAGE_DIR = ./dist/android/rustlib/src/main
ANDROID_AAR_PATH = ./dist/android/rustlib/build/outputs/aar/rustlib-release.aar
JNI_LIBS_DIR = $(ANDROID_ARTIFACT_DIR)/jniLibs


SWIFT_OUT_DIR = $(ANDROID_ARTIFACT_DIR)/kotlin
KOTLIN_OUT_DIR = $(ANDROID_ARTIFACT_DIR)/kotlin

LIB_NAME = dogs

DYNAMIC_LIB_NAME := libdogs
UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	DYNAMIC_LIB_NAME := $(addsuffix .so, $(DYNAMIC_LIB_NAME))
endif
ifeq ($(UNAME), Darwin)
	DYNAMIC_LIB_NAME := $(addsuffix .dylib, $(DYNAMIC_LIB_NAME))
endif

.PHONY: all clean

all: build-rust build-android build-ios

# Build local dynamic lib files to use when generating Uniffi bindings
build-rust:
	cd rust && \
	cargo build --release

build-android: build-android-targets generate-android-bindings package-android build-android-aar summarize-android

build-ios: build-ios-targets generate-ios-bindings package-ios build-android-aar summarize-ios

# Build .so files for all ANDROID_ABIS
build-android-targets:
	cd rust && \
	for target in $(ANDROID_ABIS); do \
	echo "Building for $$target..."; \
	cargo ndk -t $$target -o ../$(JNI_LIBS_DIR) build --release; \
	done

# Generate IOS build files
build-ios-targets:
	cd rust && \
  for target in $(IOS_TARGETS); do \
  cargo build --release --target=$$target; \
  done

# Generate Kotlin bindings using Uniffi
generate-android-bindings:
	cd rust && \
	cargo run --bin uniffi-bindgen generate --library ../$(RUST_BUILD_DIR)/$(DYNAMIC_LIB_NAME) --language kotlin --out-dir ../$(KOTLIN_OUT_DIR)

# Generate ios bindings
generate-ios-bindings:
	cd rust && \
	cargo run --bin uniffi-bindgen generate --library ../$(RUST_BUILD_DIR)/$(DYNAMIC_LIB_NAME) --language swift --out-dir ../$(IOS_ARTIFACT_DIR)

# Organizes android artifacts into a usable Kotlin directory structure
package-android:
	rm -rf $(ANDROID_PACKAGE_DIR)
	mkdir -p $(ANDROID_PACKAGE_DIR)
	cp -r $(JNI_LIBS_DIR) $(ANDROID_PACKAGE_DIR)
	cp -r $(KOTLIN_OUT_DIR) $(ANDROID_PACKAGE_DIR)/kotlin
	rm -rf $(ANDROID_ARTIFACT_DIR)

package-ios:
	rm -rf $(IOS_ARTIFACT_DIR)/Frameworks && \
	rm -rf $(IOS_ARTIFACT_DIR)/RustLib && \
	mkdir $(IOS_ARTIFACT_DIR)/Frameworks && \
	xcodebuild -create-xcframework \
  -library rust/target/aarch64-apple-ios/release/lib${LIB_NAME}.a \
  -headers $(IOS_ARTIFACT_DIR)/dogsFFI.h \
  -library rust/target/aarch64-apple-ios-sim/release/lib${LIB_NAME}.a \
  -headers $(IOS_ARTIFACT_DIR)/dogsFFI.h \
  -output $(IOS_ARTIFACT_DIR)/Frameworks/$(LIB_NAME).xcframework && \
	mkdir $(IOS_ARTIFACT_DIR)/RustLib && \
	mkdir $(IOS_ARTIFACT_DIR)/RustLib/include && \
	mv $(IOS_ARTIFACT_DIR)/$(LIB_NAME)FFI.h $(IOS_ARTIFACT_DIR)/RustLib/include/$(LIB_NAME)FFI.h && \
	mv $(IOS_ARTIFACT_DIR)/$(LIB_NAME)FFI.modulemap $(IOS_ARTIFACT_DIR)/RustLib/include/module.modulemap


# Not using this currently
package-ios-module:
	swiftc \
    -module-name dogLib \
		-emit-library -o ./rust/target/release/libdogs.dylib \
		-emit-module -emit-module-path ./dist/ios/module  \
		-parse-as-library \
    -L ./rust/target/release/ \
    -ldogs \
		-Xcc -fmodule-map-file=./dist/ios/dogsFFI.modulemap \
		./dist/ios/dogs.swift \


# Creates a bundled .aar package usable for import
build-android-aar:
	cd dist/android && \
	gradle wrapper && \
  ./gradlew :rustlib:assembleRelease
	@echo "Android build complete! .aar file in: $(ANDROID_AAR_PATH)"

# Print summary to user
summarize:
	@echo "Packaging .so files and Kotlin bindings..."
	@echo "JNI libs copied to $(ANDROID_PACKAGE_DIR)/jniLibs"
	@echo "Kotlin bindings in $(ANDROID_PACKAGE_DIR)/kotlin"

# Clean build and output artifacts
clean:
	rm -rf dist/android/build && \
	rm -rf dist/android/gradle && \
	rm -rf dist/android/.gradle && \
	rm -rf dist/android/rustlib/build && \
	rm -rf dist/android/rustlib/src && \
	rm -rf dist/ios/Frameworks && \
	rm -rf dist/RustLib && \
	rm -rf dist/.gradle && \
	rm dist/android/gradlew && \
	rm dist/android/gradlew.bat && \
	cd rust && \
	cargo clean
