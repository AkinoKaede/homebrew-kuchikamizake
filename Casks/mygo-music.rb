cask "mygo-music" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.19"
  sha256 arm:   "c80d52c3fc4cd5dcd4887e13fe6e827e5e14867c27baf470c0bb4a3d14becf72",
         intel: "1eea1071670894c189302b2514b5285fb459255148b145da860dcda774682af0"

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
