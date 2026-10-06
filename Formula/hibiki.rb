class Hibiki < Formula
  desc "Share OpenPGP cards and PIN entry across devices"
  homepage "https://github.com/AkinoKaede/hibiki"
  url "https://github.com/AkinoKaede/hibiki/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "bbc046acbabffc56c6fc4057459a87b3496df6f7734750957347d7d9f0237cf8"
  # Upstream does not currently declare a license.
  license :cannot_represent
  head "https://github.com/AkinoKaede/hibiki.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/akinokaede/kuchikamizake"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ceb359868a14914178f622c651ee2316da89af456284cc1647bf3986cfed119f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "d67467a436ed47e8c09ff07088341c3e659ef849336e12b7bd59cb8fe00f28fd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "7030424279a1fe00624399e352c01d16b03f85043a10a6671088c3214bc33438"
  end

  depends_on "rust" => :build
  depends_on "gnupg"

  def install
    system "cargo", "install", *std_cargo_args(path: "client")
    pkgshare.install "examples/client.toml"
  end

  service do
    run [opt_bin/"hibiki", "daemon"]
    environment_variables PATH: std_service_path_env
    keep_alive true
    log_path var/"log/hibiki.log"
    error_log_path var/"log/hibiki.log"
  end

  def caveats
    <<~EOS
      Initialize Hibiki before starting its service:
        hibiki init --server wss://YOUR_SERVER
        hibiki setup

      For remote card access and PIN entry, add the needed lines to ~/.gnupg/gpg-agent.conf:
        scdaemon-program #{opt_bin}/hibiki-scdaemon
        pinentry-program #{opt_bin}/hibiki-pinentry
      Then run: gpgconf --kill gpg-agent
    EOS
  end

  test do
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    ENV["XDG_DATA_HOME"] = testpath/"data"
    system bin/"hibiki", "init", "--server", "wss://127.0.0.1:7749", "--name", "homebrew-test"
    assert_path_exists testpath/"config/hibiki/client.toml"
    assert_match "wss://127.0.0.1:7749", (testpath/"config/hibiki/client.toml").read
    assert_match version.to_s, shell_output("#{bin}/hibiki --version")
    assert_match version.to_s, shell_output("#{bin}/hibiki-scdaemon --version")
    assert_match version.to_s, shell_output("#{bin}/hibiki-pinentry --version")
  end
end
