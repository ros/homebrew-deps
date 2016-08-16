require 'formula'

class MongodbDev < Formula
  homepage 'http://www.mongodb.org/'
  url 'https://github.com/mongodb/mongo/archive/r2.5.4.tar.gz'
  sha256 "95b078ccec581b58e7f36bcd66e8d3d874101f26e9d53787f230683d3cc8cebb"
  version '2.5.4'

  depends_on 'scons'
  depends_on 'boost'

  conflicts_with "mongodb", :because=>"installs the same binaries"

  patch :DATA

  def install
    args =  ["--full", "--use-system-boost", "-j4", "--prefix=#{prefix}"]
    boost = Formula.factory('boost').prefix

    if ENV.compiler == :clang && MacOS.version >= :mavericks
        args << "--64"
        args << "--libc++"
        args << "--osx-version-min=10.9"
        args << "--extrapath=#{boost}"
    end

    system "scons", "install", *args
  end

  test do
    system "false"
  end

end

__END__
diff --git a/SConstruct b/SConstruct
index b6168a7..085ab5c 100644
--- a/SConstruct
+++ b/SConstruct
@@ -845,7 +845,7 @@ if nix:
                          "-Winvalid-pch"] )
     # env.Append( " -Wconversion" ) TODO: this doesn't really work yet
     if linux or darwin:
-        env.Append( CCFLAGS=["-Werror", "-pipe"] )
+        env.Append( CCFLAGS=[ "-pipe"] )
 
     env.Append( CPPDEFINES=["_FILE_OFFSET_BITS=64"] )
     env.Append( CXXFLAGS=["-Wnon-virtual-dtor", "-Woverloaded-virtual"] )
@@ -1136,7 +1136,7 @@ def doConfigure(myenv):
         # For GCC, we don't need anything since bad flags are already errors, but
         # adding -Werror won't hurt. For clang, bad flags are only warnings, so we need -Werror
         # to make them real errors.
-        cloned.Append(CCFLAGS=['-Werror'])
+        # cloned.Append(CCFLAGS=['-Werror'])
         conf = Configure(cloned, help=False, custom_tests = {
                 'CheckFlag' : lambda(ctx) : CheckFlagTest(ctx, tool, extension, flag)
         })
diff --git a/src/mongo/client/dbclientcursor.cpp b/src/mongo/client/dbclientcursor.cpp
index f6dc575..468ed78 100644
--- a/src/mongo/client/dbclientcursor.cpp
+++ b/src/mongo/client/dbclientcursor.cpp
@@ -308,9 +308,6 @@ namespace mongo {
     }
 
     DBClientCursor::~DBClientCursor() {
-        if (!this)
-            return;
-
         DESTRUCTOR_GUARD (
 
         if ( cursorId && _ownCursor && ! inShutdown() ) {
diff --git a/src/mongo/client/dbclientcursor.h b/src/mongo/client/dbclientcursor.h
index 785734d..993999c 100644
--- a/src/mongo/client/dbclientcursor.h
+++ b/src/mongo/client/dbclientcursor.h
@@ -116,7 +116,7 @@ namespace mongo {
            'dead' may be preset yet some data still queued and locally
            available from the dbclientcursor.
         */
-        bool isDead() const { return  !this || cursorId == 0; }
+        bool isDead() const { return  cursorId == 0; }
 
         bool tailable() const { return (opts & QueryOption_CursorTailable) != 0; }
 
diff --git a/src/mongo/db/geo/geoparser.cpp b/src/mongo/db/geo/geoparser.cpp
index a4d21ca..5e9142d 100644
--- a/src/mongo/db/geo/geoparser.cpp
+++ b/src/mongo/db/geo/geoparser.cpp
@@ -221,7 +221,7 @@ namespace mongo {
         y1 = coordinates[0].Array()[1].Number();
         x2 = coordinates[coordinates.size() - 1].Array()[0].Number();
         y2 = coordinates[coordinates.size() - 1].Array()[1].Number();
-        return (fabs(x1 - x2) < 1e-6) && fabs(y1 - y2) < 1e-6;
+        return (abs(x1 - x2) < 1e-6) && abs(y1 - y2) < 1e-6;
     }
 
     static bool isGeoJSONPolygonCoordinates(const vector<BSONElement>& coordinates) {
diff --git a/src/mongo/db/geo/hash.cpp b/src/mongo/db/geo/hash.cpp
index 32c9119..d1c047b 100644
--- a/src/mongo/db/geo/hash.cpp
+++ b/src/mongo/db/geo/hash.cpp
@@ -586,7 +586,7 @@ namespace mongo {
         if (bx == _params.min)
             bx = _params.max;
 
-        return fabs(ax - bx);
+        return abs(ax - bx);
     }
 
     // Convert from an unsigned in [0, (max-min)*scaling] to [min, max]
diff --git a/src/mongo/db/geo/shapes.cpp b/src/mongo/db/geo/shapes.cpp
index 2be9323..64bb638 100644
--- a/src/mongo/db/geo/shapes.cpp
+++ b/src/mongo/db/geo/shapes.cpp
@@ -435,7 +435,7 @@ namespace mongo {
 
         if (cross_prod >= 1 || cross_prod <= -1) {
             // fun with floats
-            verify(fabs(cross_prod)-1 < 1e-6);
+            verify(std::fabs(cross_prod)-1 < 1e-6);
             return cross_prod > 0 ? 0 : M_PI;
         }
 
@@ -456,8 +456,8 @@ namespace mongo {
         double b = p1.y - p2.y;
 
         // Avoid numerical error if possible...
-        if (a == 0) return abs(b);
-        if (b == 0) return abs(a);
+        if (a == 0) return std::fabs(b);
+        if (b == 0) return std::fabs(a);
 
         return sqrt((a * a) + (b * b));
     }
diff --git a/src/mongo/db/pdfile.cpp b/src/mongo/db/pdfile.cpp
index 34f55a2..02217af 100644
--- a/src/mongo/db/pdfile.cpp
+++ b/src/mongo/db/pdfile.cpp
@@ -42,6 +42,7 @@ _ disallow system* manipulations from the database.
 #include <algorithm>
 #include <boost/filesystem/operations.hpp>
 #include <boost/optional/optional.hpp>
+#include <boost/utility/in_place_factory.hpp>
 #include <list>
 
 #include "mongo/base/counter.h"
diff --git a/src/mongo/shell/linenoise_utf8.h b/src/mongo/shell/linenoise_utf8.h
index cb41822..29ecfff 100644
--- a/src/mongo/shell/linenoise_utf8.h
+++ b/src/mongo/shell/linenoise_utf8.h
@@ -17,6 +17,7 @@
 
 #include <boost/smart_ptr/scoped_array.hpp>
 #include <string.h>
+#include <algorithm>
 
 namespace linenoise_utf8 {
 
diff --git a/src/mongo/unittest/unittest.cpp b/src/mongo/unittest/unittest.cpp
index 2142509..eb2c15c 100644
--- a/src/mongo/unittest/unittest.cpp
+++ b/src/mongo/unittest/unittest.cpp
@@ -249,7 +249,7 @@ namespace mongo {
             for ( std::vector<Result*>::iterator i=results.begin(); i!=results.end(); i++ ) {
                 Result* r = *i;
                 log() << r->toString();
-                if ( abs( r->rc() ) > abs( rc ) )
+                if ( std::fabs( r->rc() ) > std::fabs( rc ) )
                     rc = r->rc();
 
                 tests += r->_tests;
diff --git a/src/mongo/util/concurrency/mutexdebugger.h b/src/mongo/util/concurrency/mutexdebugger.h
index f0674e6..ff652ff 100644
--- a/src/mongo/util/concurrency/mutexdebugger.h
+++ b/src/mongo/util/concurrency/mutexdebugger.h
@@ -87,7 +87,7 @@ namespace mongo {
         }
 
         void entering(mid m) {
-            if( this == 0 || m == 0 ) return;
+            if( m == 0 ) return;
             verify( magic == 0x12345678 );
 
             Preceeding *_preceeding = us.get();
@@ -147,7 +147,7 @@ namespace mongo {
             }
         }
         void leaving(mid m) {
-            if( this == 0 || m == 0 ) return; // still in startup pre-main()
+            if( m == 0 ) return; // still in startup pre-main()
             Preceeding& preceeding = *us.get();
             preceeding[m]--;
             if( preceeding[m] < 0 ) {
diff --git a/src/mongo/util/md5main.cpp b/src/mongo/util/md5main.cpp
index e99de9b..3ea09b0 100644
--- a/src/mongo/util/md5main.cpp
+++ b/src/mongo/util/md5main.cpp
@@ -107,7 +107,7 @@ static int
 do_t_values(void) {
     int i;
     for (i = 1; i <= 64; ++i) {
-        unsigned long v = (unsigned long)(4294967296.0 * fabs(sin((double)i)));
+        unsigned long v = (unsigned long)(4294967296.0 * abs(sin((double)i)));
 
         /*
          * The following nonsense is only to avoid compiler warnings about
diff --git a/src/third_party/s2/util/math/mathutil.cc b/src/third_party/s2/util/math/mathutil.cc
index 10be916..fab5f7b 100755
--- a/src/third_party/s2/util/math/mathutil.cc
+++ b/src/third_party/s2/util/math/mathutil.cc
@@ -117,9 +117,16 @@ bool MathUtil::RealRootsForCubic(long double const a,
     return true;
   }
 
+// Disable error about fabs causing truncation of value because
+// it takes a double instead of a long double (Clang 3.5+)
+// See SERVER-15183
+#pragma clang diagnostic push
+#pragma clang diagnostic ignored "-Wabsolute-value"
+
   long double const A =
     -sgn(R) * pow(fabs(R) + sqrt(R_squared - Q_cubed), 1.0/3.0L);
-
+#pragma clang diagnostic pop
+    
   if (A != 0.0) {  // in which case, B from NR is zero
     *r1 = A + Q / A - a_third;
     return false;
diff --git a/src/third_party/s2/util/math/mathutil.h b/src/third_party/s2/util/math/mathutil.h
index 0515912..82ca93c 100755
--- a/src/third_party/s2/util/math/mathutil.h
+++ b/src/third_party/s2/util/math/mathutil.h
@@ -105,6 +105,9 @@ template<typename T> struct MathLimits {
 #endif  //UTIL_MATH_MATHLIMITS_H
 // ========================================================================= //
 
+#pragma clang diagnostic push
+#pragma clang diagnostic ignored "-Wabsolute-value"
+
 class MathUtil {
  public:
 
@@ -746,4 +749,6 @@ bool MathUtil::WithinFractionOrMargin(const T x, const T y,
   }
 }
 
+#pragma clang diagnostic pop
+
 #endif  // UTIL_MATH_MATHUTIL_H__
