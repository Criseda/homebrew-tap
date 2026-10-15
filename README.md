# Criseda's Homebrew tap

Formulae and casks for my projects.

```sh
brew tap criseda/tap
brew install criseda/tap/<formula>
brew install --cask criseda/tap/<cask>
```

## Formulae

| Formula | What it is |
| --- | --- |
| `netscanner` | `ns` from [NetScanner](https://github.com/Criseda/NetScanner), a fast LAN scanner (macOS and Linux) |

## Casks

| Cask | What it is |
| --- | --- |
| `netscanner-app` | [NetScanner for macOS](https://github.com/Criseda/NetScanner-MacOS), the native app for NetScanner (macOS 26 or later). Not notarized yet: its caveats say how to allow the first launch. |

## Maintaining

Formulae live in `Formula/`, casks in `Casks/`. Packages that install
prebuilt files from a project's GitHub releases need their version,
URLs and every `sha256` bumped after each release. The Bump workflow
does that daily: it runs livecheck over the tap and opens a pull
request per outdated package (`.github/scripts/bump.py`). Run it by
hand from the Actions tab, or locally with
`python3 .github/scripts/bump.py --dry-run` to list what is outdated.

CI runs `brew style` and `brew audit` on the whole tap, and installs
and tests every formula, on each push and pull request.
