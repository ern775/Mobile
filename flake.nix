{
  description = "Flutter 3.13.x";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
          # overlays = [
          #   (final: prev: {
          #     jdk8 = prev.jdk8.overrideAttrs {
          #       separateDebugInfo = false;
          #       __structuredAttrs = false;
          #     };
          #   })
          # ];
        };
        buildToolsVersion = "34.0.0";
        platformVersion = "35";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          includeSources = true;
          includeSystemImages = true;
          systemImageTypes = [ "google_apis_playstore" ];
          includeEmulator = true;
          emulatorVersion = "latest";
          includeNDK = true;
          platformToolsVersion = "latest";
          buildToolsVersions = [ buildToolsVersion ];
          cmdLineToolsVersion = "latest";
          # numLatestPlatformVersions = 1;
          platformVersions = [ platformVersion ];
          ndkVersions = [ "26.3.11579264" ];
          abiVersions = [ "x86_64" ];
          includeCmake = true;
          cmakeVersions = [ "3.22.1" ];
          # useGoogleAPIs = false;
          useGoogleTVAddOns = false;
        };
        androidSdk = androidComposition.androidsdk;
        androidEmulator = pkgs.androidenv.emulateApp {
          name = "emulate-MyAndroidApp";
          deviceName = "default";
          platformVersion = platformVersion;
          abiVersion = "x86_64"; # armeabi-v7a, mips, x86_64
          systemImageType = "google_apis_playstore";
          configOptions = {
            "disk.cachePartition.size" = "66MB";
            "disk.dataPartition.size" = "16G";
            "hw.audioInput" = "no";
            "hw.cpu.ncore" = "8";
            "hw.gpu.enabled" = "yes";
            "hw.gpu.mode" = "host";
            "hw.keyboard" = "yes";
            "hw.lcd.height" = "1280";
            "hw.lcd.vsync" = "120";
            "hw.lcd.width" = "720";
            "hw.ramSize" = "4096";
            "vm.heapSize" = "256M";
          };
          avdHomeDir = "$HOME/.config/.android/avd";
        };
        # androidSdk = pkgs.androidenv.androidPkgs.androidsdk;
      in
      {
        devShell =
          with pkgs;
          mkShell rec {
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2";
            ANDROID_EMULATOR_WAIT_TIME_BEFORE_KILL = "0";
            buildInputs = [
              flutter
              androidSdk
              jdk17
              android-studio
              androidEmulator
            ];
            shellHook = ''
              ln -sfn ${androidEmulator} ./result
            '';
          };
      }
    );
}
