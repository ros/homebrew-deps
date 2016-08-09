require "formula"

class Urdfdom < Formula
  homepage "http://wiki.ros.org/urdf"
  url "https://github.com/ros/urdfdom/archive/0.2.10.tar.gz"
  sha256 "2171c61bc6f46575fb0847112b4b7c766a6d664da83bfa327692ba99fc474041"

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
