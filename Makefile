## ALL DIRECTORY REFERENCES IN VARIABLES SHOULD USE THE DIRECTORY OF THIS MAKE FILE AS A BASE

BINDINGS_OUT_DIR := bindings
KOTIN_BINDINGS_OUT_DIR := $(BINDINGS_OUT_DIR)/kotin
SWIFT_BINDINGS_OUT_DIR := $(BINDINGS_OUT_DIR)/swift

RUST_BUILD_DIR := rust/target/release
DYNAMIC_LIB_NAME := libdogs

UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	DYNAMIC_LIB_NAME := $(addsuffix .so, $(DYNAMIC_LIB_NAME))
endif
ifeq ($(UNAME), Darwin)
	DYNAMIC_LIB_NAME := $(addsuffix .dylib, $(DYNAMIC_LIB_NAME))
endif

build-bindings-kt:
	cd rust && \
	cargo build --release && \
	cargo run --bin uniffi-bindgen generate --library ../$(RUST_BUILD_DIR)/$(DYNAMIC_LIB_NAME) --language kotlin --out-dir ../$(KOTIN_BINDINGS_OUT_DIR)
build-bindings-swift:
	cd rust && \
	cargo build --release && \
	cargo run --bin uniffi-bindgen generate --library ../$(RUST_BUILD_DIR)/$(DYNAMIC_LIB_NAME) --language swift --out-dir ../$(SWIFT_BINDINGS_OUT_DIR)

build-bindings:
	@echo $(UNAME)
	make build-bindings-kt
	make build-bindings-swift

