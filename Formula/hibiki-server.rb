class HibikiServer < Formula
  desc "Relay for end-to-end encrypted Hibiki OpenPGP operations"
  homepage "https://github.com/AkinoKaede/hibiki"
  url "https://github.com/AkinoKaede/hibiki/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "f8174412226519c61a1d2e3b0934332701047b2ad2ead0877c66faa94a61760a"
  # Upstream does not currently declare a license.
  license :cannot_represent
  head "https://github.com/AkinoKaede/hibiki.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/akinokaede/kuchikamizake"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "564076d80982716548b91b8f06761b4e8c413fee422c54a541b771a8b5b92f88"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a862f82dfb454a04c9021cecff29f37cd92c97457a16f9ed9aa7d3ceff739589"
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
