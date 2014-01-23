require 'formula'

class OoniProbe < Formula
  homepage 'https://github.com/TheTorProject/ooni-probe'
  url 'https://github.com/TheTorProject/ooni-probe/archive/v0.0.10.tar.gz'
  sha1 '2028840ef0ccf1eab79012b3c7287b805e573eba'

  depends_on :python => 'argparse'
  depends_on :python => 'docutils'
  depends_on :python => 'ipaddr'
  depends_on :python => 'pygeoip'
  depends_on :python => 'repoze.sphinx.autointerface'
  depends_on :python => 'txsocksx'
  depends_on :python => 'storm'
  depends_on :python => 'transaction'
  depends_on :python => 'txtorcon'
  depends_on :python => 'wsgiref'
  depends_on :python => 'zope.component'
  depends_on :python => 'zope.event'
  depends_on :python => 'zope.interface'
  depends_on :python => 'Pyrex'
  depends_on :python => ['dns' => 'dnspython']
  depends_on :python => 'twisted'
  depends_on :python => 'pygments'
  depends_on :python => ['yaml' =>'PyYAML']
  depends_on :python => ['OpenSSL' => 'pyOpenSSL']

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
    python do
      system python, 'setup.py', 'install', "--prefix=#{prefix}",
                     "--record=installed.txt",  "--single-version-externally-managed"
    end
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
