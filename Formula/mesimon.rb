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
      url "https://github.com/amitozalvo/mesimon-releases/releases/download/v0.1.0-beta.18/mesimon-v0.1.0-beta.18-aarch64-apple-darwin.tar.gz"
      sha256 "0195223f9c6d5e019a301bf3027469062b3c245f92a0801beeffb090c7df1d55"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amitozalvo/mesimon-releases/releases/download/v0.1.0-beta.18/mesimon-v0.1.0-beta.18-x86_64-unknown-linux-musl.tar.gz"
      sha256 "253057e5f34770106ced07d2c99c8d5406ae170670bcf8fe3708fd912e6b7c33"
    end
    on_arm do
      url "https://github.com/amitozalvo/mesimon-releases/releases/download/v0.1.0-beta.18/mesimon-v0.1.0-beta.18-aarch64-unknown-linux-musl.tar.gz"
      sha256 "bb6aff8a2f72dbda18fcdee943dc901c62b293096294f5bf4025b231ceb2c691"
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
