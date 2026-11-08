cask "mygo-music" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.22"
  sha256 arm:   "f1074aab65cee1530e5038eb63d9860e77f0c376858110baf85d5f240a7ec43d",
         intel: "29fd1b5835e8f483a8da602e42c39066f1742185667b5dea60944f9a5b2251b4"

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
