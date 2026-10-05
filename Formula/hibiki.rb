class Hibiki < Formula
  desc "Share OpenPGP cards and PIN entry across devices"
  homepage "https://github.com/AkinoKaede/hibiki"
  url "https://github.com/AkinoKaede/hibiki/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "68801c40c024401ce6480e4a4317553834c690b63cae6303f5186c345f25d853"
  # Upstream does not currently declare a license.
  license :cannot_represent
  head "https://github.com/AkinoKaede/hibiki.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/akinokaede/kuchikamizake"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a6050398f21e027974640f5ace96516341989e9f9b19d7628466a930abde5182"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8a035ed0b01e23de1183e3f8ae64b7620f2cd7008ef30edd5580b474f45e10b0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3b541f5e56006c2701c8b47313f6b074b6b84a7d14e8f25ede5520d46b552d40"
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
