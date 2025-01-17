class Crossplane < Formula
  desc "Build control planes without needing to write code"
  homepage "https://github.com/crossplane/crossplane"
  url "https://github.com/crossplane/crossplane/archive/refs/tags/v1.18.0.tar.gz"
  sha256 "fb39ade93436e2c9903ef433f60efd53ca4fb2bf6662ea5e91488a2881960da1"
  license "Apache-2.0"
  head "https://github.com/crossplane/crossplane.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ccafab16f0e33a904641744f1bf5b8a5dc2d5b2b4f380472ea9a9b562ee625f2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "ccafab16f0e33a904641744f1bf5b8a5dc2d5b2b4f380472ea9a9b562ee625f2"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "ccafab16f0e33a904641744f1bf5b8a5dc2d5b2b4f380472ea9a9b562ee625f2"
    sha256 cellar: :any_skip_relocation, sonoma:        "e063b008c37354efe8fbf4265a54c662a1afaaaeeaca0c1f34c8863ea2d594eb"
    sha256 cellar: :any_skip_relocation, ventura:       "e063b008c37354efe8fbf4265a54c662a1afaaaeeaca0c1f34c8863ea2d594eb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d9014ee6b3519ba8e1ffe8e0973a9aa838f65310368b69c4e86d1753d7abd146"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/crossplane/crossplane/internal/version.version=v#{version}"), "./cmd/crank"
  end

  test do
    assert_match "Client Version: v#{version}", shell_output("#{bin}/crossplane version --client")

    (testpath/"controllerconfig.yaml").write <<~EOS
      apiVersion: pkg.crossplane.io/v1alpha1
      kind: ControllerConfig
      metadata:
       name: irsa
      spec:
       args:
         - --enable-external-secret-stores
    EOS
    expected_output = <<~EOS
      apiVersion: pkg.crossplane.io/v1beta1
      kind: DeploymentRuntimeConfig
      metadata:
        name: irsa
      spec:
        deploymentTemplate:
          spec:
            selector: {}
            strategy: {}
            template:
              metadata:
              spec:
                containers:
                - args:
                  - --enable-external-secret-stores
                  name: package-runtime
                  resources: {}
    EOS
    system bin/"crossplane", "beta", "convert", "deployment-runtime", "controllerconfig.yaml", "-o",
"deploymentruntimeconfig.yaml"
    inreplace "deploymentruntimeconfig.yaml", /^\s+creationTimestamp.+$\n/, ""
    assert_equal expected_output, File.read("deploymentruntimeconfig.yaml")
  end
end
