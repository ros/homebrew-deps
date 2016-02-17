require 'formula'

class MongodbDev < Formula
  homepage 'http://www.mongodb.org/'
  url 'https://github.com/fjonath1/mongodb-ros-osx/archive/master.zip'
  sha1 '8e045846213484ca5de64217daf401f0ffd72237'
  version '2.5.4'

  depends_on 'scons'
  depends_on 'boost'

  conflicts_with "mongodb", :because=>"installs the same binaries"

  def install
    args =  ["--full", "--use-system-boost", "-j4", "--prefix=#{prefix}"]

    if ENV.compiler == :clang
        args << "--64"
        # args << "--libc++"
        args << "--osx-version-min=10.9"
    end

    system "scons", "install", *args
  end

  test do
    system "false"
  end

end
