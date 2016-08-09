require "formula"

class ConsoleBridge < Formula
  homepage "http://wiki.ros.org/console_bridge"
  url "https://github.com/ros/console_bridge/archive/0.2.5.tar.gz"
  sha256 "6e4f3e8a56903f157829d8928b9ed8c8c9e1cc16f281a90ecd2abfdc904a3b92"

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
