cask "mygo-music" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.24"
  sha256 arm:   "ed2870e12f73156121320d3a7da3e9efe67f52852dac835351d30dbbee6c70ce",
         intel: "9b32705679da2a5d724fabcb5e97deb08f48cd3681522012ba6d9a996dcb9248"

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
