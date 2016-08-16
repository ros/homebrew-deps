require "formula"

class ConsoleBridge < Formula
  homepage "http://wiki.ros.org/console_bridge"
  url "https://github.com/ros/console_bridge/archive/0.2.5.tar.gz"
  sha256 "a8843e1d8447c099ef271a942af1c57294c4c51f43bbde2c6d03f7b805989fa7"

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
