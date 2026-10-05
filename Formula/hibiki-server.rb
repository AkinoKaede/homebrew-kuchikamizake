class HibikiServer < Formula
  desc "Relay for end-to-end encrypted Hibiki OpenPGP operations"
  homepage "https://github.com/AkinoKaede/hibiki"
  url "https://github.com/AkinoKaede/hibiki/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "9aa965aa768555ea98314b3d2e3f81e892461f20dee4a616f4505dda7b4e27fa"
  # Upstream does not currently declare a license.
  license :cannot_represent
  head "https://github.com/AkinoKaede/hibiki.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/akinokaede/kuchikamizake"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "4f6783538d8437134db068945ac252eb3fc5c87b1e099445972fdc1f3d69fee6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "5058d9347fbf57212dc74365e04a1896e83ef6d771107900c87b27b28f71a80d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "68d9e305e62054543313f0a436e6bf93cdf4cb560f93c9f190f75db34e0aa5f1"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "server")
    inreplace "examples/server.toml", "/var/lib/hibiki/hibiki.sqlite3", "#{var}/lib/hibiki/hibiki.sqlite3"
    (etc/"hibiki").install "examples/server.toml"
  end

  service do
    run [opt_bin/"hibiki-server", "--config", etc/"hibiki/server.toml"]
    keep_alive true
    log_path var/"log/hibiki-server.log"
    error_log_path var/"log/hibiki-server.log"
  end

  def caveats
    <<~EOS
      Configuration: #{etc}/hibiki/server.toml
      The relay listens on 127.0.0.1:7749 by default. Use a TLS endpoint for remote access.
      To manage channels with the same configuration as the service:
        hibiki-server --config #{etc}/hibiki/server.toml channel list
    EOS
  end

  test do
    port = free_port
    database = testpath/"state/hibiki.sqlite3"
    pid = spawn bin/"hibiki-server", "--listen", "127.0.0.1:#{port}", "--database", database.to_s
    begin
      sleep 1
      system bin/"hibiki-server", "--listen", "127.0.0.1:#{port}", "health"
      assert_path_exists database
      assert_match version.to_s, shell_output("#{bin}/hibiki-server --version")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
