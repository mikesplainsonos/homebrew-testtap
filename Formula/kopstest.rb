class Kopstest < Formula
  desc "Production grade Kops test formula"
  homepage "https://kops.sigs.k8s.io/"
  url "https://github.com/kubernetes/kops/archive/v1.22.3.tar.gz"
  sha256 "76fb2e20f1d4d54904311c3aec2298ae99dcea5ea8473677a61f6e6c7418d341"
  license "Apache-2.0"
  head "https://github.com/kubernetes/kops.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/mikesplainsonos/testtap"
    sha256 cellar: :any_skip_relocation, big_sur:      "70d86303faafdf6bddcca4133df987dca89f24959d724f400e35926d8dc74d6f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3cec279c2bdeb961dc17f459d8140acaf9c9f92411eddffe841a7dff84b896f3"
  end

  depends_on "go" => :build
  depends_on "kubernetes-cli"

  def install
    ENV["VERSION"] = version unless build.head?
    ENV["GOPATH"] = buildpath
    kopspath = buildpath/"src/k8s.io/kops"
    kopspath.install Dir["*"]
    system "make", "-C", kopspath
    bin.install "bin/kops"

    # Install bash completion
    output = Utils.safe_popen_read(bin/"kops", "completion", "bash")
    (bash_completion/"kops").write output

    # Install zsh completion
    output = Utils.safe_popen_read(bin/"kops", "completion", "zsh")
    (zsh_completion/"_kops").write output

    # Install fish completion
    output = Utils.safe_popen_read(bin/"kops", "completion", "fish")
    (fish_completion/"kops.fish").write output
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kops version")
    assert_match "no context set in kubecfg", shell_output("#{bin}/kops validate cluster 2>&1", 1)
  end
end
