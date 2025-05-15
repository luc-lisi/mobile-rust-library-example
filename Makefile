ABIS = armeabi-v7a arm64-v8a x86 x86_64

RUST_BUILD_DIR := rust/target/release
OUT_DIR = ./dist
ANDROID_ARTIFACT_DIR = $(OUT_DIR)/android/android-artifacts
ANDROID_PACKAGE_DIR = ./dist/android/android-package/src/main
JNI_LIBS_DIR = $(ANDROID_ARTIFACT_DIR)/jniLibs
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

.PHONY: all build-rust build-android generate-android-bindings package-android build-android-aar summarize clean

all: build-rust build-android generate-android-bindings package-android build-android-aar summarize

# Build local dynamic lib files to use when generating Uniffi bindings
build-rust:
	cd rust && \
	cargo build --release

# Build .so files for all ABIs
build-android:
	cd rust && \
	for target in $(ABIS); do \
	echo "Building for $$target..."; \
	cargo ndk -t $$target -o ../$(JNI_LIBS_DIR) build --release; \
	done

# Generate Kotlin bindings using Uniffi
generate-android-bindings:
	cd rust && \
	cargo run --bin uniffi-bindgen generate --library ../$(RUST_BUILD_DIR)/$(DYNAMIC_LIB_NAME) --language kotlin --out-dir ../$(KOTLIN_OUT_DIR)

# Organizes android artifacts into a usable Kotlin directory structure
package-android:
	rm -rf $(ANDROID_PACKAGE_DIR)
	mkdir -p $(ANDROID_PACKAGE_DIR)
	cp -r $(JNI_LIBS_DIR) $(ANDROID_PACKAGE_DIR)
	cp -r $(KOTLIN_OUT_DIR) $(ANDROID_PACKAGE_DIR)/kotlin
	rm -rf $(ANDROID_ARTIFACT_DIR)

# Creates a bundled .aar package usable for import
build-android-aar:
	cd android && \
	gradle wrapper && \
  ./gradlew :rustlib:assembleRelease

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
	rm -rf dist/.gradle && \
	cd rust && \
	cargo clean
