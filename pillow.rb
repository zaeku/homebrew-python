require 'formula'

class Pillow < Formula
  homepage 'https://github.com/python-imaging/Pillow'
  url 'https://github.com/python-imaging/Pillow/tarball/1.7.8'
  sha1 '8da50546abec3d94640a97727ba416f90b3a14af'

  depends_on 'python'  # todo replace by :python in the future
  depends_on 'zlib'
  depends_on 'littlecms'
  depends_on 'graphicsmagick'

  def install
    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages
    inreplace "setup.py" do |s|
      s.gsub! "ZLIB_ROOT = None", "ZLIB_ROOT = ('#{Formula.factory('zlib').opt_prefix}/lib', '#{Formula.factory('zlib').opt_prefix}/include')"
      s.gsub! "LCMS_ROOT = None", "LCMS_ROOT = ('#{Formula.factory('littlecms').opt_prefix}/lib', '#{Formula.factory('littlecms').opt_prefix}/include')"
    end
    system "python", "setup.py", "--no-user-cfg", "install", "--force", "--verbose", "--single-version-externally-managed", "--prefix=#{prefix}", "--record=installed-files.txt"
    mv 'installed-files.txt', Dir["#{temp_site_packages}/*.egg-info"].first
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
