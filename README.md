# Step to Reproduce "FontSubset error"

```
$ cd ios 
$ pod install 
$ flutter build ios                                            git[branch:master]
Building suzotmo.hello for device (ios-release)...
Automatically signing iOS for device deployment using specified development team in Xcode project: M3QX44L9Y2
Running Xcode build...                                                  
                                                   
Xcode build done.                                           34.2s
Failed to build iOS app
Error output from Xcode build:
↳
    ** BUILD FAILED **


Xcode's output:
↳
    Failed to subset font; aborting.

    Target release_ios_bundle_flutter_assets failed: FontSubset error: Font subsetting failed with exit code
    255.
    build failed.
    Command PhaseScriptExecution failed with a nonzero exit code
    note: Using new build system
    note: Building targets in parallel
    note: Planning build
    note: Constructing build description
```

# Flutter doctor

I use Flutter beta channel.

```
/tmp/font-subset-error/hello $ flutter doctor                                               git[branch:master]
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel beta, 1.19.0-4.2.pre, on Mac OS X 10.15.5 19F101, locale en-US)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html
      On first launch it will assist you in installing the Android SDK components.
      (or visit https://flutter.dev/docs/get-started/install/macos#android-setup for detailed instructions).
      If the Android SDK has been installed to a custom location, set ANDROID_SDK_ROOT to that location.
      You may also want to add it to your PATH environment variable.

[✓] Xcode - develop for iOS and macOS (Xcode 11.5)
[!] Android Studio (not installed)
[✓] IntelliJ IDEA Community Edition (version 2020.1.2)
[✓] VS Code
 
[!] Connected device                          
    ! No devices available

! Doctor found issues in 3 categories.
```
