class ConsoleBridge < Formula
  desc "ROS-independent package for logging"
  homepage "http://wiki.ros.org/console_bridge"
  url "https://github.com/ros/console_bridge/archive/0.3.2.tar.gz"
  sha256 "fd12e48c672cb9c5d516d90429c4a7ad605859583fc23d98258c3fa7a12d89f4"
  head "https://github.com/ros/console_bridge", :branch => "master"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build # for test

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "brew", "list", "console_bridge"
  end
end
