# Mobile Rust Template

**:warning: WORK IN PROGRESS :warning:**

The purpose of this repo is to serve as an example/template of a project which implements a shared Rust library between IOS and Android mobile apps. In this example, we implement a very important, business critical Rust library which is responsible for fetching a picture of a dog from the lovely open API: https://dog.ceo/dog-api/documentation/.

The example applications using this library let you select a dog breed or simply request a random dog image.

While this example possibly risks being [too silly](https://www.youtube.com/watch?v=qfwTRVnO5No), the purpose here is to show how we can use Rust to implement some shared library across two completely different apps written in both Swift and Kotlin using [uniffi-rs](https://github.com/mozilla/uniffi-rs).

## Overview

This project is organized into 3 main sub directories:

1. `rust/`
2. `dist/`
3. `example_apps/`

Let's quickly describe what each directory is doing before we get into the meat of what is really happening under the hood.

### Directories
#### Rust Library

`rust/`  contains a [workspace](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html) which includes the library's main source code (`dogs/`) as well as a crate to handle the generation of the Rust bindings (`uniffi-bindgen/`).

This directory also contains the compiled Rust code in `rust/target/` which will only be seen after running the make command to build the bindings locally for the first time. `target/release` will contain both static and dynamic lib files once built.

#### Dist

`dist/` is split up into both `android/` and `ios/` distributions.

##### Android Dist

To package our Rust library in a way that android can make sense of it, we bundle it using gradle into a `.aar` file. The gradle files can be found in this repo but the actual built src files cannot. You will need to run the make commands below to see the final contents here.

##### IOS Dist

WIP

#### Example Apps
`example_apps` contains both an `android` and `ios` application that renders a glorious dog picture on the screen of your phone using our Rust library!

### Local Setup

To try this locally, you will need to make sure you have a few dependencies installed.

Things you will need:
- `cargo`
- `gradle`
- `openjdk` or something equivalent
- Android Studio is also highly recommended


You will also have to ensure that you have the correct targets added to your Rust toolchain.

```
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim
```


### Building locally

Once you have all your local dependencies sorted out, you should be able to just run:

```
make all
```

From the top-level directory.

I final success message should be seen with the location of the `.aar` output for android.

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

