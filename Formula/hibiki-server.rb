class HibikiServer < Formula
  desc "Relay for end-to-end encrypted Hibiki OpenPGP operations"
  homepage "https://github.com/AkinoKaede/hibiki"
  url "https://github.com/AkinoKaede/hibiki/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "77a39d045193e1c1e6ecc20b8c269648311618e3a0313899d423da9f4ba881c2"
  # Upstream does not currently declare a license.
  license :cannot_represent
  head "https://github.com/AkinoKaede/hibiki.git", branch: "main"

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
