class Urdfdom < Formula
  desc "URDF parser"
  homepage "http://wiki.ros.org/urdf"
  url "https://github.com/ros/urdfdom/archive/1.0.0.tar.gz"
  sha256 "243ea925d434ebde0f9dee35ee5615ecc2c16151834713a01f85b97ac25991e1"
  head "https://github.com/ros/urdfdom", :branch => "master"

  depends_on "cmake" => :build

  depends_on "tinyxml"
  depends_on "ros/deps/console_bridge"
  depends_on "ros/deps/urdfdom_headers"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "brew", "list", "urdfdom"
  end
end
