cask "mygo-music" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.16"
  sha256 arm:   "5147aab78081bc26354f3eb03c4cdd958d9dbe1ebf314cdd8f4c036dc7f341bc",
         intel: "7b2a346ebdbce716cf6c5c382ddb03859fbed34351b8285484c670fea681a438"

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
