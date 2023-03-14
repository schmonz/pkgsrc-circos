$NetBSD$

Look in PKG_SYSCONFDIR first.

--- lib/Circos/Configuration.pm.orig	2017-06-04 01:05:34.000000000 +0000
+++ lib/Circos/Configuration.pm
@@ -798,6 +798,7 @@ sub loadconfiguration {
   }
 
   my @configpath = (
+										"@PKG_SYSCONFDIR@",
 										dirname($file),
 										dirname($file)."/etc",
 										"$FindBin::RealBin/etc", 
