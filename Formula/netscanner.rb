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
      url "https://github.com/Criseda/NetScanner/releases/download/v1.8.0/macos-arm64.zip"
      sha256 "c777c766801d16398730257c121c1ef8c11349b7280803d0a1eac2bc31ffbc20"
    end
    on_intel do
      url "https://github.com/Criseda/NetScanner/releases/download/v1.8.0/macos-x86_64.zip"
      sha256 "21fd5a8878ea2389304e8abe269c25ccbbe7606006327b145cc7ccd4dc59b492"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Criseda/NetScanner/releases/download/v1.8.0/linux-arm64.zip"
      sha256 "9ac2e2af856c7463b369010c8165f7d969d87cc0b4913652fe8b0147ca5df888"
    end
    on_intel do
      url "https://github.com/Criseda/NetScanner/releases/download/v1.8.0/linux-x86_64.zip"
      sha256 "4e943b8ae6a96bd4e8238967d4d66bd541dd6fdade8eea09ef257ae316a2bb83"
    end
  end

  def install
    bin.install "ns"
  end

  test do
    assert_equal "v#{version}", shell_output("#{bin}/ns --version").strip
  end
end
