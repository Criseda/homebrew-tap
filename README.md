# Criseda's Homebrew tap

Homebrew packages for [NetScanner](https://github.com/Criseda/NetScanner),
a fast LAN scanner.

```sh
brew tap criseda/tap
```

| Package | Install | What it is |
| --- | --- | --- |
| `netscanner` | `brew install criseda/tap/netscanner` | The `ns` command-line scanner (macOS and Linux) |

## Updating these packages

Packages install prebuilt files from the projects' GitHub releases.
After a release, bump the URLs and every `sha256`:

- `Formula/netscanner.rb`: the four zips of a
  [NetScanner release](https://github.com/Criseda/NetScanner/releases).

`brew livecheck --tap criseda/tap` lists packages with a newer release.
CI runs `brew style` and `brew audit` on every push.
