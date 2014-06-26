require 'formula'

class Openni2 < Formula
  homepage 'https://github.com/OpenNI/OpenNI2'
  url 'https://launchpad.net/~v-launchpad-jochen-sprickerhof-de/+archive/pcl/+files/openni2_2.1.0.4.orig.tar.gz'
  sha1 '8d423621f7c0c3a72b64fedf8ec5193f8e1341b5'

  def patches
    # fixes compilation on OS X with clang (e.g. 10.9)
    # See https://github.com/ros/homebrew-hydro/issues/10
    # This patch was introduced when openni2_2.1.0.4 was being built with this formula.
    # Apparently the issue is addressed upstream. So when updating to the next release, consider removing the patch.
    "https://gist.github.com/NikolausDemmel/7901983/raw/3746869662473860cd5f57e6bc685e76cdb831c2/equiv-is-a-thing-for-clang-apparently.patch"
  end

  def install
    # Change the default location of drive libraries to a sane default
    inreplace 'Source/Core/OniContext.cpp',
      'static const char* ONI_DEFAULT_DRIVERS_REPOSITORY = XN_FILE_LOCAL_DIR "OpenNI2" XN_FILE_DIR_SEP "Drivers";',
      "static const char* ONI_DEFAULT_DRIVERS_REPOSITORY = \"#{lib}\" XN_FILE_DIR_SEP \"OpenNI2\" XN_FILE_DIR_SEP \"Drivers\";"

    # make
    system 'make'
    # Install the examples
    bin.install Dir['Bin/*-Release/ClosestPointViewer']
    bin.install Dir['Bin/*-Release/EventBasedRead']
    bin.install Dir['Bin/*-Release/MWClosestPointApp']
    bin.install Dir['Bin/*-Release/MultiDepthViewer']
    bin.install Dir['Bin/*-Release/MultipleStreamRead']
    bin.install Dir['Bin/*-Release/NiViewer']
    bin.install Dir['Bin/*-Release/SimpleRead']
    bin.install Dir['Bin/*-Release/SimpleViewer']
    # Install the libraries
    lib.install Dir['Bin/*-Release/lib*']
    # Install the driver plugin libraries
    (lib + 'OpenNI2/Drivers').install Dir['Bin/*-Release/OpenNI2/Drivers/lib*']
    # Install development headers
    (include + 'openni2').install Dir['Include/*']
    # Install default configs
    (etc + 'openni2').install Dir['Config/*.ini']
    # Create and install a pkg-config file
    pkg_config_file = "prefix=#{prefix}
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include/openni2

Name: OpenNI2
Description: A general purpose driver for all OpenNI cameras.
Version: 2.2.0.3
Cflags: -I${includedir}
Libs: -L${libdir} -lOpenNI2 -L${libdir}/OpenNI2/Drivers -lDummyDevice -lOniFile -lPS1080
"
    File.open('openni2.pc', 'w') {|f| f.write(pkg_config_file)}
    (lib + 'pkgconfig').install 'openni2.pc'
  end
end
