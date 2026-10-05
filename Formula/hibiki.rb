class Hibiki < Formula
  desc "Share OpenPGP cards and PIN entry across devices"
  homepage "https://github.com/AkinoKaede/hibiki"
  url "https://github.com/AkinoKaede/hibiki/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "a0850a2043a29ef23b5efe9eb0659df71a98b37ab29c370cf058020ceeeeab0f"
  # Upstream does not currently declare a license.
  license :cannot_represent
  head "https://github.com/AkinoKaede/hibiki.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/akinokaede/kuchikamizake"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "7323e143614c847dcf9bdef41dbff7104ee2935437fa2c69d736d061bf0233bd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f6d18ff2e74b72f9ecf1f6d0a57ebc55c4713d3e89f59f11f47581389286875e"
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
