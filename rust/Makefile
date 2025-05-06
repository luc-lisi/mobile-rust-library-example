build-bindings-kt:
	cargo build --release
	cargo run --bin uniffi-bindgen generate --library target/release/libdogs.dylib --language kotlin --out-dir out/kotlin-out
build-bindings-swift:
	cargo build --release
	cargo run --bin uniffi-bindgen generate --library target/release/libdogs.dylib --language swift --out-dir out/swift-out

build-bindings:
	make build-bindings-kt
	make build-bindings-swift

