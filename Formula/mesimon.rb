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
      url "https://github.com/amitozalvo/mesimon-releases/releases/download/v0.1.0-beta.6/mesimon-v0.1.0-beta.6-aarch64-apple-darwin.tar.gz"
      sha256 "c969d4e87572ed87bb026b2c0444d5e9e13fb1710a5da7a287ed6c98fb376e0b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/amitozalvo/mesimon-releases/releases/download/v0.1.0-beta.6/mesimon-v0.1.0-beta.6-x86_64-unknown-linux-musl.tar.gz"
      sha256 "a36d3540afa95edd2fc0d36e7e4473795472289553d806555eac52dc3b1aa8bc"
    end
    on_arm do
      url "https://github.com/amitozalvo/mesimon-releases/releases/download/v0.1.0-beta.6/mesimon-v0.1.0-beta.6-aarch64-unknown-linux-musl.tar.gz"
      sha256 "31a3d995516f0d9e0ee76169b0491abf4c1be6eaf717ea10bc525f8a4f86d08a"
    end
  end

  def install
    bin.install "mesimon"
    # The macOS tarball carries mesimon's own tmux. It goes beside mesimon,
    # where tmux_bin() looks first, and never as `tmux`, which would shadow
    # the user's own on PATH. The Linux tarballs carry none: mesimon runs the
    # distro's tmux there.
    return unless OS.mac?

    bin.install "mesimon-tmux"
    doc.install "licenses-bundled"
  end

  def caveats
    return unless OS.linux?

    <<~EOS
      mesimon runs agents on tmux 3.3 or newer, from your distro:
        sudo apt install tmux
      `mesimon doctor` checks it.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mesimon --version")
    # The bundled tmux runs, and it is the one mesimon resolves rather than a
    # tmux on PATH.
    if OS.mac?
      assert_match "tmux", shell_output("#{bin}/mesimon-tmux -V")
      assert_match "/mesimon-tmux", shell_output("#{bin}/mesimon doctor multiplexer --verbose")
    end
  end
end
