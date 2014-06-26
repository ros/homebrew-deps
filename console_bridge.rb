require "formula"

class ConsoleBridge < Formula
  homepage "http://wiki.ros.org/console_bridge"
  url "https://github.com/ros/console_bridge/archive/0.2.5.tar.gz"
  sha1 "541b7b6bae5443c466bfadd5fe159a25835e583f"

  depends_on "cmake" => :build
  depends_on "boost" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "pkg-config --cflags-only-I console_bridge"
  end
end
