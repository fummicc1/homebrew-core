class Webhook < Formula
  desc "Lightweight, configurable incoming webhook server"
  homepage "https://github.com/adnanh/webhook"
  url "https://github.com/adnanh/webhook/archive/refs/tags/2.8.2.tar.gz"
  sha256 "c233a810effc24b5ed5653f4fa82152f288ec937d5744a339f7066a6cbccc565"
  license "MIT"
  head "https://github.com/adnanh/webhook.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "38e7bbf2dd97094eeb2190f13de30eb044a841b8fd96e992c46820056a9d236b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "38e7bbf2dd97094eeb2190f13de30eb044a841b8fd96e992c46820056a9d236b"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "38e7bbf2dd97094eeb2190f13de30eb044a841b8fd96e992c46820056a9d236b"
    sha256 cellar: :any_skip_relocation, sonoma:        "991f9bb7960fc618cf27455b18480a581f4ed96282d3202e727132420106d48b"
    sha256 cellar: :any_skip_relocation, ventura:       "991f9bb7960fc618cf27455b18480a581f4ed96282d3202e727132420106d48b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ae3a9af4020f1dee92642e36d5282f1a96b5c2c47dbb9914300600a13b7298d2"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args
  end

  test do
    (testpath/"hooks.yaml").write <<~EOS
      - id: test
        execute-command: /bin/sh
        command-working-directory: "#{testpath}"
        pass-arguments-to-command:
        - source: string
          name: -c
        - source: string
          name: "pwd > out.txt"
    EOS

    port = free_port
    fork do
      exec bin/"webhook", "-hooks", "hooks.yaml", "-port", port.to_s
    end
    sleep 1

    system "curl", "localhost:#{port}/hooks/test"
    sleep 1
    assert_equal testpath.to_s, (testpath/"out.txt").read.chomp
  end
end
