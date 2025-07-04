# Mobile Rust Template

**:warning: WORK IN PROGRESS :warning:**

The purpose of this repo is to serve as an example/template of a project which implements a shared Rust library between IOS and Android mobile apps. In this example, we implement a very important, business critical Rust library which is responsible for fetching a picture of a dog from the lovely open API: https://dog.ceo/dog-api/documentation/.

The example applications using this library let you select a dog breed or simply request a random dog image.

While this example possibly risks being [too silly](https://www.youtube.com/watch?v=qfwTRVnO5No), the purpose here is to show how we can use Rust to implement some shared library across two completely different apps written in both Swift and Kotlin using [uniffi-rs](https://github.com/mozilla/uniffi-rs). In a real use-case, this would only be worth the effort for a library with significantly more complexity.

## Overview

This project is organized into 3 main sub directories:

1. `rust/`
2. `dist/`
3. `example_apps/`

Let's quickly describe what each directory is doing before we get into the meat of what is really happening under the hood.

### Directories
#### Rust Library

`rust/`  contains a [workspace](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html) which includes the library's main source code (`dogs/`) as well as a crate to handle the generation of the Rust bindings (`uniffi-bindgen/`).

This directory also contains the compiled Rust code in `rust/target/` which will only be seen after compiling locally. How to do this will be discussed in the build process section.

#### Dist

`dist/` is split up into both `android/` and `ios/` distributions.

##### Android Dist

To package our Rust library in a way that Android can make sense of it, we bundle it using gradle into a `.aar` file. The gradle files can be found in this repo but the actual built src files cannot. You will need to run the make commands below to see the final contents here.

##### IOS Dist

Similar to Android, IOS has it's own particular way to package libraries. Once built, this folder will contain the following items:

```
dist/ios
├── Frameworks
│ └── dogs.xframework    # This contains bundled binaries for different platforms
├── RustLib
│ └── include
│   └── dogsFFI.h        # C header file needed for app build
│   └── module.modulemap # Modulemap file needed for app build (it must have this exact name regarless of library name)
└── dogs.swift           # Bindings generated by Uniffi-bindgen
```

#### Example Apps
`example_apps` contains both an `android` and `ios` application that renders a glorious dog picture on the screen of your phone using our Rust library! This document wont outline how to build these in detail as Android Studio and XCode can do all the heavy lifting there.

### Local Setup

To try this locally, you will need to make sure you have a few dependencies installed.

Things you will need:
- [`cargo`](https://doc.rust-lang.org/cargo/getting-started/installation.html)
- [`gradle`](https://gradle.org/install/) (For android builds)
- [`openjdk`](https://openjdk.org/) or something equivalent (We need this)
  - `brew install openjdk`
- [Android Studio](https://developer.android.com/studio)
- [`ndk`] (Environment config helper for building Android libs from rust, install via Android Studio's "SDK Manager" > "SDK Tools" tab)
- [`cargo-ndk`](https://github.com/bbqsrc/cargo-ndk) `cargo install cargo-ndk`
- Set `ANDROID_HOME= ~/Library/Android/sdk` in your `.zshrc`
- [XCode](https://developer.apple.com/xcode/) (For the IOS app and xcframework creation -- you will need to create an AppleId account, but you can skip entering your credit card info with the small "None" at the end of the CC options)


You will also have to ensure that you have the correct targets added to your Rust toolchain. To download and link them, just run:

```
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim
```


### Building locally

Once you have all your local dependencies installed, you can use the `Makefile` to control what gets built:

If you want to do everything in a single step, just use:

```
make all
```

However, for clarity I will go over each step of the build process below.


#### Compiling our Rust Code

To compile all the Rust code for local use, run:

```
make build-rust
```

To compile the Rust src to android and ios architectures, you can use:

```
make build-android-targets
make build-ios-targets
```

The different targets for each build can be set with the top-level variables set in the Makefile. See: `ANDROID_ABIS` and `IOS_TARGETS`.

In addition, the android target build process also uses `cargo ndk` to create the JNIs needed for our code to run across different Android architectures.

#### Generating Bindings with Uniffi

To generate our binding for Kotlin and Swift that let us actually import and use our Rust code in our apps naively, we use Uniffi's bindgen process. To do this, either run the make command:

```
make generate-android-bindings
make generate-ios-bindings
```

Or you can manually run:
```
cargo run --bin uniffi-bindgen generate --library {PATH_TO_DYNAMIC_LIB} --language {swift/kotlin} --out-dir {SOME_DIR}
```

For Kotlin, this will output a `.kt` file.

For Swift, this will generate a `.modulemap` file, a `.h` file, and a `.swift` file. Note that the `modulemap` file generated in the Swift process will *not* be named correctly if we want it to be compatible with the `xcframework` we generate later on. It must be named exactly `module.modulemap`.

As a result, I included a `package-android` and `package-ios` which cleans up the directory structure of our output to place everything in a form that will be easy for our app to ingest.


#### Building distributable bundles

Okay so this has been a lot of compiling and cross-compiling. But there are a *lot* of different architectures we need our code to be able to run on. But if you've gotten this far, we are done with we are finally ready to bundle all these binaries into a naive form our apps can ingest!

To do this, we need to build a `.aar` file for Android, and a `.xcframework` file for IOS.

For android, we use [gradle wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html) to do this. The make command is:

`make build-android-aar`

For IOS, we use a (`xcframework` artifact)[https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle] which we build using `xcodebuild`.

The make command for this is:

`make build-ios-xcframework`

### Using our generated Artifacts in the Apps

Once you've run `make all` successfully, you are ready to link the artifact to your local example app! The process is pretty different across Android and IOS, so I'll go over each individually.

#### Android

#### IOS

## Step-by-step Walkthrough

### Initial Repo Setup

#### Rust

- Cargo init dogs and uniffi uniffi-bindgen
- Setup the workspace
- install deps where they need to good
- Write some code to get those dogs
- Setup the Makefile

#### Android

- Get android studio
- init a new repo in our android directory
- brew install gradle
- brew install openjdk
- cargo install cargo-ndk


- gradle wrapper
- echo "sdk.dir=$HOME/Library/Android/sdk" > local.properties
- <uses-permission android:name="android.permission.INTERNET"/> in AndroidManifext.xml

Example app:

```kt
implementation(files("../../../../dist/android/rustlib/build/outputs/aar/rustlib-release.aar"))
implementation("net.java.dev.jna:jna:5.12.0@aar")
```


##### Setting up Cargo NDK
https://github.com/willir/cargo-ndk-android-gradle

First, we need to setup our binaries for android so that rust can cross-compile to them.

To do this we install the rust tollchains for android like:

```sh
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
```


#### IOS
