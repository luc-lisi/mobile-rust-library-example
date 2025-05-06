BINDINGS_OUT_DIR := bindings
KOTIN_BINDINGS_OUT_DIR := $(BINDINGS_OUT_DIR)/kotin
SWIFT_BINDINGS_OUT_DIR := $(BINDINGS_OUT_DIR)/swift

RUST_BUILD_DIR := target/release
DYNAMIC_LIB_NAME := libdogs.dylib


build-bindings-kt:
	cd rust && \
	cargo build --release && \
	cargo run --bin uniffi-bindgen generate --library $(RUST_BUILD_DIR)/$(DYNAMIC_LIB_NAME) --language kotlin --out-dir $(KOTIN_BINDINGS_OUT_DIR)
build-bindings-swift:
	cd rust && \
	cargo build --release && \
	cargo run --bin uniffi-bindgen generate --library $(RUST_BUILD_DIR)/$(DYNAMIC_LIB_NAME) --language swift --out-dir $(SWIFT_BINDINGS_OUT_DIR)

build-bindings:
	make build-bindings-kt
	make build-bindings-swift

