class HibikiServer < Formula
  desc "Relay for end-to-end encrypted Hibiki OpenPGP operations"
  homepage "https://github.com/AkinoKaede/hibiki"
  url "https://github.com/AkinoKaede/hibiki/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "a0850a2043a29ef23b5efe9eb0659df71a98b37ab29c370cf058020ceeeeab0f"
  # Upstream does not currently declare a license.
  license :cannot_represent
  head "https://github.com/AkinoKaede/hibiki.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/akinokaede/kuchikamizake"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8f2172596713b67ecf28c8a4453aa796382d6831fa7d78c07f2e7bfb1ee1811d"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4918331db076c3f5abba082056818779186b6477e732abe9bf8a873e1792ac4d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "254cdb887fc303a1ed4c6dd26a7904248bd5d1257961e6a86c6235cfff2a862a"
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
