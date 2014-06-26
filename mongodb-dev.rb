require 'formula'

class MongodbDev < Formula
  homepage 'http://www.mongodb.org/'
  url 'https://github.com/mongodb/mongo/archive/r2.5.4.tar.gz'
  sha1 '0d8b8dad3b5909af2b9b7ba7ed22d5cb0a7cfd98'
  version '2.5.4'

  depends_on 'scons'
  depends_on 'boost'

  conflicts_with "mongodb", :because=>"installs the same binaries"

  def install
    args =  ["--full", "--use-system-boost", "--prefix=#{prefix}"]

    if ENV.compiler == :clang && MacOS.version >= :mavericks
        args << "--64"
        args << "--libc++"
        args << "--osx-version-min=10.9"
    end

    system "scons", "install", *args
  end

  test do
    system "false"
  end

end
