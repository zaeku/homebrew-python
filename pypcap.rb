require 'formula'

class Pypcap < Formula
  homepage 'http://code.google.com/p/pypcap/'
  # url 'http://pypcap.googlecode.com/files/pypcap-1.1.tar.gz'
  # sha1 '966f62deca16d5086e2ef6694b0c795f273da15c'
  # We use the url of this forked version as the googlecode project was
  # last updated on 2007
  url 'https://github.com/hellais/pypcap/archive/v1.1.1.tar.gz'
  sha1 '8e1669da927c3cdaa03204d4afa9a88707a19756'

  depends_on :python => :recommended
  depends_on 'Pyrex' => :python

  def install
    inreplace "setup.py", /^for d in dirs/,
                          "dirs = ['#{MacOS.sdk_path}/usr', '#{HOMEBREW_PREFIX}']\nfor d in dirs"

    system "python", 'setup.py', 'install', "--prefix=#{prefix}",
           "--record=installed.txt",  "--single-version-externally-managed"
  end
end
