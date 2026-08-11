class PinentryMacSwift < Formula
  desc "SwiftUI pinentry with Touch ID support for macOS"
  homepage "https://github.com/Stapxs/pinentry-mac-swift"
  url "https://github.com/Stapxs/pinentry-mac-swift/archive/4442fa4da951b7ec076fb057dc1b4595801e29f3.tar.gz"
  version "1.0.0-4442fa4"
  sha256 "583ae4d44016d804134d6509630193ec2c0cb6846595b037dc44a6cf3468b069"
  license all_of: ["GPL-2.0-or-later", "GPL-3.0-or-later"]
  head "https://github.com/Stapxs/pinentry-mac-swift.git", branch: "main"

  livecheck do
    skip "Pinned to a commit temporarily"
  end

  depends_on xcode: :build
  depends_on "libassuan"
  depends_on "libgpg-error"
  depends_on macos: :ventura

  def install
    assuan = Formula["libassuan"]
    gpg_error = Formula["libgpg-error"]
    frontend = buildpath/"macosx-swift"

    # Homebrew manages these shared libraries as runtime dependencies.
    inreplace frontend/"pinentry-mac-swift.xcodeproj/project.pbxproj",
              "\t\t\t\tA10B03000000000000000002 /* Bundle Pinentry Dynamic Libraries */,\n", ""

    ENV["PINENTRY_MAC_SWIFT_ASSUAN_PREFIX"] = assuan.opt_prefix
    ENV["PINENTRY_MAC_SWIFT_GPG_ERROR_PREFIX"] = gpg_error.opt_prefix

    products = buildpath/"Products"
    header_paths = [
      buildpath,
      buildpath/"pinentry",
      buildpath/"secmem",
      buildpath/"macosx",
      assuan.include,
      gpg_error.include,
    ].join(" ")
    linker_flags = [
      buildpath/"pinentry/libpinentry.a",
      buildpath/"secmem/libsecmem.a",
      "-L#{assuan.opt_lib}",
      "-L#{gpg_error.opt_lib}",
      "-lassuan",
      "-lgpg-error",
      "-framework Security",
      "-framework LocalAuthentication",
    ].join(" ")

    xcodebuild "-project", frontend/"pinentry-mac-swift.xcodeproj",
               "-scheme", "pinentry-mac-swift",
               "-configuration", "Release",
               "-derivedDataPath", buildpath/"DerivedData",
               "-destination", "platform=macOS",
               "CONFIGURATION_BUILD_DIR=#{products}",
               "HEADER_SEARCH_PATHS=#{header_paths}",
               "OTHER_LDFLAGS=#{linker_flags}",
               "ONLY_ACTIVE_ARCH=YES",
               "CODE_SIGNING_ALLOWED=NO",
               "build"

    prefix.install products/"pinentry-mac-swift.app"
    bin.write_exec_script prefix/"pinentry-mac-swift.app/Contents/MacOS/pinentry-mac-swift"
  end

  def caveats
    <<~EOS
      To use pinentry-mac-swift with GnuPG, add this line to
      ~/.gnupg/gpg-agent.conf:

        pinentry-program #{opt_bin}/pinentry-mac-swift

      Then reload gpg-agent:

        gpgconf --kill gpg-agent
    EOS
  end

  test do
    assert_match "pinentry-mac-swift (pinentry)", shell_output("#{bin}/pinentry-mac-swift --version")
  end
end
