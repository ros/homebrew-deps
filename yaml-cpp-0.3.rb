require 'formula'

class YamlCpp03 < Formula
  homepage 'https://github.com/jbeder/yaml-cpp'
  url 'https://github.com/jbeder/yaml-cpp/archive/release-0.3.0.tar.gz'
  sha256 "ab8d0e07aa14f10224ed6682065569761f363ec44bc36fcdb2946f6d38fe5a89"

  depends_on 'cmake' => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end
