# NOTICE: this formula was removed from Homebrew core:
#
#   https://github.com/Homebrew/homebrew-core/issues/6827
#
# We've resurrected it here because ROS Indigo still needs it.
# We used this command to get the most recent content:
#
#   git -C "$(brew --repo homebrew/core)" show 0aadb3f^:Formula/libqglviewer.rb

class Libqglviewer < Formula
  desc "C++ Qt library to create OpenGL 3D viewers"
  homepage "http://www.libqglviewer.com/"
  url "http://www.libqglviewer.com/src/libQGLViewer-2.6.3.tar.gz"
  sha256 "be611b87bdb8ba794a4d18eaed87f22491ebe198d664359829233c4ea69f4d02"

  head "https://github.com/GillesDebunne/libQGLViewer.git"

  option :universal

  depends_on "qt4-no-webkit"

  def install
    args = %W[
      PREFIX=#{prefix}
      DOC_DIR=#{doc}
    ]
    args << "CONFIG += x86 x86_64" if build.universal?

    cd "QGLViewer" do
      system "qmake", *args
      system "make", "install"
    end
  end
end
