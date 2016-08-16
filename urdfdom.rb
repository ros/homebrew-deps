require "formula"

class Urdfdom < Formula
  homepage "http://wiki.ros.org/urdf"
  url "https://github.com/ros/urdfdom/archive/0.2.10.tar.gz"
  sha256 "e200f5adefa6bf8304e56ab8a3e1c04d3b6cced5df472f4aeb430ff81f1ffa0d"

  depends_on "cmake" => :build
  depends_on "boost" => :build
  depends_on "tinyxml" => :build
  depends_on "ros/deps/console_bridge"
  depends_on "ros/deps/urdfdom_headers"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "pkg-config --cflags-only-I urdfdom"
  end
end
