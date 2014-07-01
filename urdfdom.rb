require "formula"

class Urdfdom < Formula
  homepage "http://wiki.ros.org/urdf"
  url "https://github.com/ros/urdfdom/archive/0.2.10.tar.gz"
  sha1 "79e33e91f79c4775983ffeffcf02b155af942af2"

  depends_on "cmake" => :build
  depends_on "boost" => :build
  depends_on "tinyxml" => :build
  depends_on "console_bridge"
  depends_on "urdfdom_headers"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "pkg-config --cflags-only-I urdfdom"
  end
end
