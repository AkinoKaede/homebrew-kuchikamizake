cask "kelivo" do
  version "1.2.4,68"
  sha256 "45faee14871ecfa2d8542b7bbaac11ec65a402ce0427ebb06944eea1f0eeb8b7"

  url "https://github.com/Chevey339/kelivo/releases/download/v#{version.csv.first}/Kelivo_macos_#{version.csv.first}%2B#{version.csv.second}.dmg",
      verified: "github.com/Chevey339/kelivo/"
  name "Kelivo"
  desc "Multi-platform, multi-provider LLM chat client"
  homepage "https://kelivo.psycheas.top/"

  livecheck do
    url :url
    regex(/^Kelivo[._-]macos[._-]v?(\d+(?:\.\d+)+)\+(\d+)\.dmg$/i)
    strategy :github_latest do |json, regex|
      json["assets"]&.map do |asset|
        match = asset["name"]&.match(regex)
        next if match.blank?

        "#{match[1]},#{match[2]}"
      end
    end
  end

  depends_on macos: :catalina

  app "kelivo.app"

  zap trash: [
    "~/Library/Application Support/com.psyche.kelivo",
    "~/Library/Caches/com.psyche.kelivo",
    "~/Library/Preferences/com.psyche.kelivo.plist",
    "~/Library/Saved Application State/com.psyche.kelivo.savedState",
  ]
end
