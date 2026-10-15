# NetScanner's `ns` command-line LAN scanner, from its prebuilt release
# binaries. The macOS binaries come ad-hoc signed with the identifier
# io.github.criseda.netscanner: without that code identity, macOS hides
# the ARP table (MAC addresses, manufacturers, quiet hosts) from `ns`.
class Netscanner < Formula
  desc "Fast LAN scanner: host discovery, device identification and port scans"
  homepage "https://github.com/Criseda/NetScanner"
  license "GPL-3.0-only"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/Criseda/NetScanner/releases/download/v1.7.0/macos-arm64.zip"
      sha256 "b7209515de3bf364fb6b6d0b76ea17ddee21440e33ba0a537bb6b7b107d8e744"
    end
    on_intel do
      url "https://github.com/Criseda/NetScanner/releases/download/v1.7.0/macos-x86_64.zip"
      sha256 "7b05effed2f091a50b6c0592b7589af6a9816ec9673242dc49bc0fcc9d5f27f6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Criseda/NetScanner/releases/download/v1.7.0/linux-arm64.zip"
      sha256 "450a4942f43d26a7cd6c94775652e3526c994a1b877221f6627e221fab2306fa"
    end
    on_intel do
      url "https://github.com/Criseda/NetScanner/releases/download/v1.7.0/linux-x86_64.zip"
      sha256 "0e98a830cdc040b2b0e60c7d615901178e9386357063c01b6811b5c6cb57ea1b"
    end
  end

  def install
    bin.install "ns"
  end

  test do
    assert_equal "v#{version}", shell_output("#{bin}/ns --version").strip
  end
end
