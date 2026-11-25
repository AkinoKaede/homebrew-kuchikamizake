cask "mygo-music" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.26"
  sha256 arm:   "477391ea53a2cda47dfa9428f8a1bc50c0cf3e91598b05b31a09ddc28420967d",
         intel: "201debff855a249b56af0b72b79793916ada60f68dc23535cce0b4fdf4e65216"

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
