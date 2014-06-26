require 'formula'

class Gtest <Formula
  url 'http://googletest.googlecode.com/files/gtest-1.5.0.tar.gz'
  homepage 'http://code.google.com/p/googletest/'
  md5 '7e27f5f3b79dd1ce9092e159cdbd0635'

  def patches
      # This is necessary to get gtest to function wtih libc++
      # Based on the patch under upstream code review: https://codereview.appspot.com/6332052/
    DATA
  end

  def install
    system "./configure", "CPPFLAGS=-DGTEST_HAS_TR1_TUPLE=0", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    inreplace 'scripts/gtest-config', '`dirname $0`', '$bindir'
    system "make install"
  end
end

__END__
diff --git a/include/gtest/internal/gtest-port.h b/include/gtest/internal/gtest-port.h
index a2a62be..b4a8ac8 100644
--- a/include/gtest/internal/gtest-port.h
+++ b/include/gtest/internal/gtest-port.h
@@ -221,6 +221,11 @@
 #define GTEST_OS_AIX 1
 #endif  // __CYGWIN__
 
+#if __GXX_EXPERIMENTAL_CXX0X__ || __cplusplus >= 201103L
+// Compiling in at least C++11 mode.
+# define GTEST_LANG_CXX11 1
+#endif
+
 #if GTEST_OS_CYGWIN || GTEST_OS_LINUX || GTEST_OS_MAC || GTEST_OS_SYMBIAN || \
     GTEST_OS_SOLARIS || GTEST_OS_AIX
 
@@ -399,7 +404,8 @@
 // defining __GNUC__ and friends, but cannot compile GCC's tuple
 // implementation.  MSVC 2008 (9.0) provides TR1 tuple in a 323 MB
 // Feature Pack download, which we cannot assume the user has.
-#if (defined(__GNUC__) && !defined(__CUDACC__) && (GTEST_GCC_VER_ >= 40000)) \
+#if (defined(__GNUC__) && !defined(__CUDACC__) && (GTEST_GCC_VER_ >= 40000) \
+    && !GTEST_OS_QNX && (GTEST_LANG_CXX11 || !defined(_LIBCPP_VERSION))) \
     || _MSC_VER >= 1600
 #define GTEST_USE_OWN_TR1_TUPLE 0
 #else
@@ -415,6 +421,20 @@
 
 #if GTEST_USE_OWN_TR1_TUPLE
 #include <gtest/internal/gtest-tuple.h>
+#elif GTEST_LANG_CXX11
+#  include <tuple>
+// C++11 puts its tuple into the ::std namespace rather than
+// ::std::tr1.  gtest expects tuple to live in ::std::tr1, so put it there.
+namespace std {
+    namespace tr1 {
+        using ::std::get;
+        using ::std::make_tuple;
+        using ::std::tuple;
+        using ::std::tuple_element;
+        using ::std::tuple_size;
+    }
+}
+
 #elif GTEST_OS_SYMBIAN
 
 // On Symbian, BOOST_HAS_TR1_TUPLE causes Boost's TR1 tuple library to

