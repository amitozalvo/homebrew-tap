# The Homebrew formula, as ci/homebrew-formula.sh fills it in and ci/release.sh
# pushes it to amitozalvo/homebrew-tap (Formula/mesimon.rb) after every
# release. The copy in the tap is generated; edit this one.
#
# It installs the published binaries, not a source build: the same tarballs,
# checksums and bundled tmux that install.sh puts in ~/.local/bin.
#
# To check a change against a published release (a bare path is linted with
# Homebrew's own rules, not a formula's, so it goes through a local tap):
#
#   ci/homebrew-formula.sh <tag> <dir> > "$(brew --repo msmn-test/local)/Formula/mesimon.rb"
#       (after: brew tap-new --no-git msmn-test/local)
#   brew style msmn-test/local/mesimon
#   brew audit --strict --online --formula msmn-test/local/mesimon
#   brew install msmn-test/local/mesimon && brew test msmn-test/local/mesimon
#   brew uninstall mesimon && brew untap msmn-test/local
class Mesimon < Formula
  desc "Terminal kanban board that runs many coding-agent sessions"
  homepage "https://mesimon.dev"
  # No `version`: brew reads it off each url (`brew audit` calls a stated one
  # redundant), and orders alpha.10 after alpha.9.
  license "Apache-2.0"

  on_macos do
    # One macOS build is published, for Apple Silicon.
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/amitozalvo/mesimon-releases/releases/download/v0.1.0-beta.17/mesimon-v0.1.0-beta.17-aarch64-apple-darwin.tar.gz"
      sha256 "d3b9c93cc8d43cafea0864caada4218c9724d94b823a7611b29b665341f70d5f"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amitozalvo/mesimon-releases/releases/download/v0.1.0-beta.17/mesimon-v0.1.0-beta.17-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d36afc33f3678fdc2f9f766aa62c3db121c9b273a01ae5dc17d1c6608f917eac"
    end
    on_arm do
      url "https://github.com/amitozalvo/mesimon-releases/releases/download/v0.1.0-beta.17/mesimon-v0.1.0-beta.17-aarch64-unknown-linux-musl.tar.gz"
      sha256 "445f00cf77fcbca8e8baaa443241783b392533b0146656bfb84e26146e699219"
    end
  end

  def install
    bin.install "mesimon"
    # Every tarball carries mesimon's own tmux. It goes beside mesimon, where
    # tmux_bin() looks first, and never as `tmux`, which would shadow the
    # user's own on PATH.
    bin.install "mesimon-tmux"
    doc.install "licenses-bundled"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mesimon --version")
    # The bundled tmux runs, and it is the one mesimon resolves rather than a
    # tmux on PATH.
    assert_match "tmux", shell_output("#{bin}/mesimon-tmux -V")
    assert_match "/mesimon-tmux", shell_output("#{bin}/mesimon doctor multiplexer --verbose")
  end
end
