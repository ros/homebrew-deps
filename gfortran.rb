require 'formula'

# Note: The reason for providing our own gfortran is that upstream
#       homebrew merged gfortran with gcc, gcc has causes issues with
#       the default c/c++ compiler and is thus keg-only. If this
#       situation ever changes, we can remove gfortran from our tap.
class Gfortran < Formula
  homepage 'http://gcc.gnu.org/wiki/GFortran'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2'
  sha256 '09dc2276c73424bbbfda1dbddc62bbbf900c9f185acf7f3e1d773ce2d7e3cdc8'

  option 'enable-profiled-build', 'Make use of profile guided optimization when bootstrapping GCC'
  option 'check', 'Run the make check fortran. This is for maintainers.'
  option 'enable-multilib', 'Build with multilib support' if Hardware::CPU.is_64_bit?

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'cloog'
  depends_on 'isl'

  # http://gcc.gnu.org/install/test.html
  depends_on 'dejagnu' if build.include? 'check'

  def install
    # Sandbox the GCC lib, libexec and include directories so they don't wander
    # around telling small children there is no Santa Claus. This results in a
    # partially keg-only brew following suggestions outlined in the "How to
    # install multiple versions of GCC" section of the GCC FAQ:
    #     http://gcc.gnu.org/faq.html#multiple
    gfortran_prefix = prefix/'gfortran'

    args = [
      # Sandbox everything...
      "--prefix=#{gfortran_prefix}",
      # ...except the stuff in share...
      "--datarootdir=#{share}",
      # ...and the binaries...
      "--bindir=#{bin}",
      "--enable-languages=fortran",
      "--with-system-zlib",
      # ...opt_prefix survives upgrades and works even if `brew unlink gmp`
      "--with-gmp=#{Formula['gmp'].opt_prefix}",
      "--with-mpfr=#{Formula['mpfr'].opt_prefix}",
      "--with-mpc=#{Formula['libmpc'].opt_prefix}",
      "--with-cloog=#{Formula['cloog'].opt_prefix}",
      "--with-isl=#{Formula['isl'].opt_prefix}",
      # ...and disable isl and cloog version checks in case they upgrade
      "--disable-cloog-version-check",
      "--disable-isl-version-check",
      # ...we build the stage 1 gcc with clang (which is know to fail checks)
      "--enable-checking=release",
      "--disable-stage1-checking",
      # ...speed up build by stop building libstdc++-v3
      "--disable-libstdcxx",
      "--enable-lto",
      # ...disable translations avoid conflict with brew install gcc --enable-nls
      '--disable-nls'
    ]

    # https://github.com/Homebrew/homebrew/issues/19584#issuecomment-19661219
    if build.include? 'enable-multilib' and Hardware::CPU.is_64_bit?
      args << '--enable-multilib'
    else
      args << '--disable-multilib'
    end

    mkdir 'build' do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # 'native-system-header's will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system '../configure', *args

      if build.include? 'enable-profiled-build'
        # Takes longer to build, may bug out. Provided for those who want to
        # optimise all the way to 11.
        system 'make profiledbootstrap'
      else
        system 'make bootstrap'
      end

      system "make"
      system "make check-fortran" if build.include? 'check'
      system 'make install'
    end

    # This package installs a whole GCC suite. Removing non-fortran components:
    bin.children.reject{ |p| p.basename.to_s.match(/gfortran/) }.each(&:unlink)
    info.children.reject{ |p| p.basename.to_s.match(/gfortran/) }.each(&:unlink)
    man1.children.reject{ |p| p.basename.to_s.match(/gfortran/) }.each(&:unlink)
    man7.rmtree  # dupes: fsf fundraising and gpl
    (share/"gcc-#{version}").rmtree # dupes: libstdc++ pretty printer, will be added by gcc* formula
  end

  test do
    fixture = <<-EOS.undent
      integer,parameter::m=10000
      real::a(m), b(m)
      real::fact=0.5

      do concurrent (i=1:m)
        a(i) = a(i) + fact*b(i)
      end do
      print *, "done"
      end
    EOS
    Pathname('in.f90').write(fixture)
    system "#{bin}/gfortran -c in.f90"
    system "#{bin}/gfortran -o test in.o"
    assert_equal 'done', `./test`.strip
  end

  def caveats; <<-EOS.undent
    This formula had been removed and merged with the gcc formula in
    upstream homebrew. However, installing gcc causes potential
    conflicts with the default c/c++ compiler (see
    https://github.com/ros-infrastructure/rosdep/issues/328) and
    therefore gcc is keg-only. Thus, the ros tap provides a copy of
    the old standalone (not keg-only) gfortran formula needed outside of
    homebrew for python packages like scipy.

    Formulae that require a Fortran compiler should use
      depends_on :fortran
    which will resolve to the gfortran of the (keg-only) gcc formula and
    do the right thing even for future changes in the way homebrew
    provides gfortran.
    EOS
  end
end
