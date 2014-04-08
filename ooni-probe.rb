require 'formula'

class OoniProbe < Formula
  homepage 'https://github.com/TheTorProject/ooni-probe'
  url 'https://github.com/TheTorProject/ooni-probe/archive/v0.0.10.tar.gz'
  sha1 '2028840ef0ccf1eab79012b3c7287b805e573eba'

  depends_on :python => :recommended
  depends_on 'argparse' => :python
  depends_on 'docutils' => :python
  depends_on 'ipaddr' => :python
  depends_on 'pygeoip' => :python
  depends_on 'repoze.sphinx.autointerface' => :python
  depends_on 'txsocksx' => :python
  depends_on 'storm' => :python
  depends_on 'transaction' => :python
  depends_on 'txtorcon' => :python
  depends_on 'wsgiref' => :python
  depends_on 'zope.component' => :python
  depends_on 'zope.event' => :python
  depends_on 'zope.interface' => :python
  depends_on 'Pyrex' => :python
  depends_on 'dns' => :python
  depends_on 'twisted' => :python
  depends_on 'pygments' => :python
  depends_on 'yaml' => :python
  depends_on 'OpenSSL' => :python

  depends_on 'libdnet'
  depends_on 'scapy'
  depends_on 'pypcap'

  # Fixed a syntax err bug and the requirements.txt seems buggy, too.
  # So we check with homebrew for all the needed python deps.
  # The user will need to do a lot of pip install.
  # Oh and further, there is no `bin/canary`. Is that important?
  def patches
    DATA
  end

  def install
    system "python", 'setup.py', 'install', "--prefix=#{prefix}",
                   "--record=installed.txt",  "--single-version-externally-managed"
  end

end

__END__
diff --git a/nettests/tls-handshake.py b/nettests/tls-handshake.py
index eba950e..1b1a927 100644
--- a/nettests/tls-handshake.py
+++ b/nettests/tls-handshake.py
@@ -22,7 +22,7 @@ ciphers = [
   "DHE-RSA-CAMELLIA128-SHA",
   "DHE-DSS-CAMELLIA128-SHA"
 ]
-def checkBridgeConnection(host, port)
+def checkBridgeConnection(host, port):
   cipher_arg = ":".join(ciphers)
   cmd  = ["openssl", "s_client", "-connect", "%s:%s" % (host,port)]
   cmd += ["-cipher", cipher_arg]
diff --git a/setup.py b/setup.py
index 1b8ecc3..cbe219b 100644
--- a/setup.py
+++ b/setup.py
@@ -31,7 +31,5 @@ setup(
     version="0.6",
     url="http://ooni.nu/",
     packages=find_packages(),
-    scripts=["bin/canary", "bin/oonib", "bin/ooniprobe"],
-    install_requires=install_requires,
-    dependency_links=dependency_links,
+    scripts=["bin/oonib", "bin/ooniprobe"]
 )
