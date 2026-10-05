class PinentryModern < Formula
  desc "SwiftUI pinentry with Touch ID support for macOS"
  homepage "https://github.com/Stapxs/pinentry-modern"
  url "https://github.com/Stapxs/pinentry-modern/archive/refs/tags/1.0.2.tar.gz"
  sha256 "f8c0cb930a056cd07c7b1854d5b21452891422369fec8dc63890d038a1193196"
  license all_of: ["GPL-2.0-or-later", "GPL-3.0-or-later"]
  head "https://github.com/Stapxs/pinentry-modern.git", branch: "main"

  livecheck do
    url :stable
    strategy :git
  end

  bottle do
    root_url "https://ghcr.io/v2/akinokaede/kuchikamizake"
    sha256 cellar: :any, arm64_golden_gate: "df6604c4f0fa307d9a379681c2cc225ccb32bce7747211e3c7f2a7332ac7537a"
    sha256 cellar: :any, arm64_tahoe:       "215f39ba0ab187ca567b3011f16d7c0ec388744f7875241c48578cdd1290f364"
    sha256 cellar: :any, arm64_sequoia:     "8a8faa8bc12d54aa0c2fe58115ddd8e2da87834f474b7bebc1a620b2cec4212f"
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

    prefix.install products/"pinentry-modern.app"
    bin.write_exec_script prefix/"pinentry-modern.app/Contents/MacOS/pinentry-modern"
  end

  def caveats
    <<~EOS
      To use pinentry-modern with GnuPG, add this line to
      ~/.gnupg/gpg-agent.conf:

        pinentry-program #{opt_bin}/pinentry-modern

      Then reload gpg-agent:

        gpgconf --kill gpg-agent
    EOS
  end

  test do
    assert_match "pinentry-modern (pinentry)", shell_output("#{bin}/pinentry-modern --version")
  end
end
