require 'formula'

class Pillow < Formula
  homepage 'https://github.com/python-imaging/Pillow'
  url 'https://github.com/python-imaging/Pillow/tarball/1.7.8'
  sha1 '7dbdb96fc831425e89dacfa0a9289e3ed56d290e'
  head 'https://github.com/python-imaging/Pillow.git'

  depends_on 'little-cms'
  depends_on 'graphicsmagick'
  depends_on 'freetype'

  def install
    # In order to install into the Cellar, the dir must exist and be in the
    # PYTHONPATH.
    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages

    # Help pillow find little-cms
    inreplace "setup.py" do |s|
      s.gsub! "ZLIB_ROOT = None", "ZLIB_ROOT = ('#{MacOS.sdk_path}/usr/lib', '#{MacOS.sdk_path}/usr/include')" unless MacOS::CLT.installed?
      s.gsub! "LCMS_ROOT = None", "LCMS_ROOT = ('#{Formula.factory('littlecms').opt_prefix}/lib', '#{Formula.factory('littlecms').opt_prefix}/include')"
    end

    args = [
      "install",
      "--force",
      "--verbose",
      "--single-version-externally-managed",
      "--install-scripts=#{prefix}/share/python",
      "--install-lib=#{temp_site_packages}",
      "--record=installed-files.txt"
    ]

    system "python", "setup.py", *args

    # Move the installed-files.txt into the .egg-info dir so pip can uninstall
    mv 'installed-files.txt', Dir["#{temp_site_packages}/*.egg-info"].first
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
