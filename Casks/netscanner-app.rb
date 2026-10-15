# NetScanner for macOS, the native app. The token has an -app suffix
# because the `netscanner` formula in this tap already takes the name.
cask "netscanner-app" do
  version "0.1.0"
  sha256 "a52ef544da3cee04cebe378cacc1a454e9d5e91d225495fdb51dacd94b7ee24a"

  url "https://github.com/Criseda/NetScanner-MacOS/releases/download/v#{version}/NetScanner-#{version}.zip"
  name "NetScanner"
  desc "Native app for the NetScanner LAN scanner"
  homepage "https://github.com/Criseda/NetScanner-MacOS"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :tahoe

  app "NetScanner.app"

  zap trash: [
    "~/Library/Application Support/io.github.criseda.netscanner.app",
    "~/Library/Caches/io.github.criseda.netscanner.app",
    "~/Library/Preferences/io.github.criseda.netscanner.app.plist",
    "~/Library/Saved Application State/io.github.criseda.netscanner.app.savedState",
  ]

  caveats <<~EOS
    NetScanner is not notarized by Apple yet, so macOS blocks the first launch.
    To allow it, open NetScanner once, then choose Open Anyway in
    System Settings > Privacy & Security. Or run:
      xattr -dr com.apple.quarantine #{appdir}/NetScanner.app
  EOS
end
