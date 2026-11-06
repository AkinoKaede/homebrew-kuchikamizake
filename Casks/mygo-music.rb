cask "mygo-music" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.7"
  sha256 arm:   "0b3b0b78b0ab84011192f1506e6f4e7ff7f00db8ccbbe2df5123775720e9b6a9",
         intel: "a71eff7b88ea1ed78251d62313a9b63a7c4831dafc9e2832ebea2d00208c3b1f"

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
