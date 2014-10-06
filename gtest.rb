require 'formula'

class Gtest <Formula
  skip_clean "lib"
  url 'http://googletest.googlecode.com/files/gtest-1.7.0.zip'
  homepage 'http://code.google.com/p/googletest/'
  sha256 '247ca18dd83f53deb1328be17e4b1be31514cedfc1e3424f672bf11fd7e0d60d'

  def patches
    # This is necessary to get gtest to function wtih libc++
    # Otherwise, every catkin package has to export that flag.
    # The patch only changes the default behavior.
    DATA
  end

  def install
    system "./configure", "CPPFLAGS=-DGTEST_HAS_TR1_TUPLE=0", "--prefix=#{prefix}", "--disable-dependency-tracking"
    inreplace 'scripts/gtest-config', '`dirname $0`', '$bindir'
    system "make"
    lib.install Dir['lib/*.la']
    lib.install Dir['lib/.libs/*.dylib']
    (include / 'gtest').install Dir["include/gtest/*"]
  end
end

__END__
diff --git a/include/gtest/gtest.h b/include/gtest/gtest.h
index 6fa0a39..7f8656f 100644
--- a/include/gtest/gtest.h
+++ b/include/gtest/gtest.h
@@ -55,6 +55,10 @@
 #include <ostream>
 #include <vector>
 
+#ifndef GTEST_HAS_TR1_TUPLE
+#define GTEST_HAS_TR1_TUPLE 0
+#endif
+
 #include "gtest/internal/gtest-internal.h"
 #include "gtest/internal/gtest-string.h"
 #include "gtest/gtest-death-test.h"
