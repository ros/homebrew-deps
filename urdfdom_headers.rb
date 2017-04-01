class UrdfdomHeaders < Formula
  desc "Headers for URDF parsers "
  homepage "http://wiki.ros.org/urdfdom_headers"
  url "https://github.com/ros/urdfdom_headers/archive/1.0.0.tar.gz"
  sha256 "f341e9956d53dc7e713c577eb9a8a7ee4139c8b6f529ce0a501270a851673001"
  head "https://github.com/ros/urdfdom_headers", :branch => "master"

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "brew", "list", "urdfdom_headers"
  end
end
