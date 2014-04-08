require 'formula'

class Scapy < Formula
  homepage 'http://www.secdev.org/projects/scapy/'
  url 'http://www.secdev.org/projects/scapy/files/scapy-2.2.0.tar.gz'
  sha1 'ae0a9947a08a01a84abde9db12fed074ac888e47'

  depends_on :python => :recommended
  depends_on 'libdnet' => 'with-python'
  depends_on 'pypcap'

  def install
    system "python", 'setup.py', 'install', "--prefix=#{prefix}"
  end
end
