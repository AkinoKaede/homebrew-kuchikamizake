cask "mygo-music" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.9"
  sha256 arm:   "138ed8f5354ead5cc708d2c0a723fb1a2369883faf9758c8aa6e24a80288e3ec",
         intel: "cea7628ff1bb21d66683d0a0ad99498ce15aa62e6e77b1d90fda198b00ee21f1"

  url "https://github.com/egoist/mygo-music/releases/download/v#{version}/mygo-music-#{version}-#{arch}.dmg"
  name "MyGo Music"
  desc "Native music player with plugin support"
  homepage "https://github.com/egoist/mygo-music"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :ventura

  app "MyGo Music.app"

  zap trash: [
    "~/Library/Application Support/MyGo Music",
    "~/Library/Caches/dev.egoist.music",
    "~/Library/Caches/MyGo Music",
    "~/Library/Logs/MyGo Music",
    "~/Library/Preferences/dev.egoist.music.plist",
    "~/Library/Saved Application State/dev.egoist.music.savedState",
  ]
end
