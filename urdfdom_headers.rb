require "formula"

class UrdfdomHeaders < Formula
  homepage "http://wiki.ros.org/urdfdom_headers"
  url "https://github.com/ros/urdfdom_headers/archive/0.2.3.tar.gz"
  sha1 "c68e965e3e98263fb908dc26e6e7e450431b71f2"

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "pkg-config --cflags-only-I urdfdom_headers"
  end
end
