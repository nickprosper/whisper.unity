#!/bin/bash

whisper_path="$1"
targets=${2:-all}
android_sdk_path="$3"
unity_project="$PWD"
build_path="$1/build"

clean_build(){
  rm -rf "$build_path"
  mkdir "$build_path"
  cd "$build_path"
}

build_mac() {
  clean_build
  echo "Starting building for Mac..."

  cmake -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" -DWHISPER_METAL=OFF \
   -DWHISPER_NO_AVX=ON -DWHISPER_NO_AVX2=ON -DWHISPER_NO_FMA=ON -DWHISPER_NO_F16C=ON \
   -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=OFF ../
  make

  echo "Build for Mac complete!"

  artifact_path="$build_path/libwhisper.dylib"
  target_path="$unity_project/Packages/com.whisper.unity/Plugins/MacOS/libwhisper.dylib"
  cp "$artifact_path" "$target_path"

  echo "Build files copied to $target_path"
}

build_mac_metal() {
  clean_build
  echo "Starting building for Mac (Metal)..."

  cmake -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" -DWHISPER_METAL=ON \
   -DWHISPER_NO_AVX=ON -DWHISPER_NO_AVX2=ON -DWHISPER_NO_FMA=ON -DWHISPER_NO_F16C=ON \
   -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=OFF ../
  make

  echo "Build for Mac (Metal) complete!"

  artifact_path="$build_path/libwhisper.dylib"
  target_path="$unity_project/Packages/com.whisper.unity/Plugins/MacOS/libwhisper_metal.dylib"
  cp "$artifact_path" "$target_path"

  artifact_path="$build_path/bin/ggml-metal.metal"
  target_path="$unity_project/Packages/com.whisper.unity/Plugins/MacOS/ggml-metal.metal"
  cp "$artifact_path" "$target_path"

  echo "Build files copied to $target_path"
}

build_ios() {
  clean_build
  echo "Starting building for ios..."

  cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" -DWHISPER_METAL=OFF \
  -DCMAKE_SYSTEM_PROCESSOR=arm64 -DCMAKE_IOS_INSTALL_COMBINED=YES \
  -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=OFF ../
  make

  echo "Build for ios complete!"

  artifact_path="$build_path/libwhisper.a"
  target_path="$unity_project/Packages/com.whisper.unity/Plugins/iOS/libwhisper.a"
  cp "$artifact_path" "$target_path"

  echo "Build files copied to $target_path"
}

build_android() {
  clean_build
  echo "Starting building for Android..."

  cmake -DCMAKE_TOOLCHAIN_FILE="$android_sdk_path" -DANDROID_ABI=arm64-v8a -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
  -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=OFF ../
  make

  echo "Build for Android complete!"

  artifact_path="$build_path/libwhisper.a"
  target_path="$unity_project/Packages/com.whisper.unity/Plugins/Android/libwhisper.a"
  cp "$artifact_path" "$target_path"

  echo "Build files copied to $target_path"
}

if [ "$targets" = "all" ]; then
  build_mac
  build_ios
  build_android
elif [ "$targets" = "mac" ]; then
  build_mac
elif [ "$targets" = "mac_metal" ]; then
  build_mac_metal
elif [ "$targets" = "ios" ]; then
  build_ios
elif [ "$targets" = "android" ]; then
  build_android
else
  echo "Unknown targets: $targets"
fi
