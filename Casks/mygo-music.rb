cask "mygo-music" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.20"
  sha256 arm:   "42fa737acaa981ef3799ab4182a42e4e36ab845e6a01fc25c37d80e8b92ac7ac",
         intel: "02730edce6d4ba34a302594be554a164f874992fc2ef87c6e509439d409431c3"

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
