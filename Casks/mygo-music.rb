cask "mygo-music" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.8"
  sha256 arm:   "632c3369e3a254e5518e4d902754cb104dbbc8142ecd331122c18ea781bfdbf3",
         intel: "ee4a6557dfef66aaef067121141ddac982f523c11a19b005ae246c6ef0e1668c"

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
