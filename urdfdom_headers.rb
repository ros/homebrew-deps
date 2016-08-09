require "formula"

class UrdfdomHeaders < Formula
  homepage "http://wiki.ros.org/urdfdom_headers"
  url "https://github.com/ros/urdfdom_headers/archive/0.2.3.tar.gz"
  sha256 "b0a707c77d6defc567b3fd2bdc6b74fc7e190504e50653107a0725ea22ae086f"

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "pkg-config --cflags-only-I urdfdom_headers"
  end
end
