require "formula"

class UrdfdomHeaders < Formula
  homepage "http://wiki.ros.org/urdfdom_headers"
  url "https://github.com/ros/urdfdom_headers/archive/0.2.3.tar.gz"
  sha256 "6b1f27b002c6d897b43ed57988133f40aac093a2a6e84d9bf08ed36a13b401ae"

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "pkg-config --cflags-only-I urdfdom_headers"
  end
end
