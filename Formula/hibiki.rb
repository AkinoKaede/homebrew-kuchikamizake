class Hibiki < Formula
  desc "Share OpenPGP cards and PIN entry across devices"
  homepage "https://github.com/AkinoKaede/hibiki"
  url "https://github.com/AkinoKaede/hibiki/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "09c4c934fff0cb51ee8cdb8210b9ad29633bb298dfa21aeab07a377bc7db95fd"
  # Upstream does not currently declare a license.
  license :cannot_represent
  head "https://github.com/AkinoKaede/hibiki.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/akinokaede/kuchikamizake"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "880b07c757048d5a3b776ac280171c404eefd52c4bd3d9a305a8523f3e3d935c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "88f96fb113a1b26658e4cd38be30a7b7f5c74bcec7fbb7371662597e839713ec"
  end

  depends_on "rust" => :build
  depends_on "gnupg"

  def install
    system "cargo", "install", *std_cargo_args(path: "client")
    pkgshare.install "examples/client.toml"
  end

  service do
    run [opt_bin/"hibiki", "daemon"]
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
