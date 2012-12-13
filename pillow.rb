require 'formula'

class Pillow < Formula
  homepage 'https://github.com/python-imaging/Pillow'
  url 'http://pypi.python.org/packages/source/P/Pillow/Pillow-1.7.8.zip'
  sha1 '1afa1b74f84957015689d4344b3453a5c0c348aa'
  head 'https://github.com/python-imaging/Pillow.git'

  conflicts_with 'pil',
    :because => 'both install the same "PIL" module but Pillow is the better maintained distribution for PIL.'

  depends_on 'little-cms'
  depends_on 'graphicsmagick'
  depends_on 'freetype'

  def install
    # In order to install into the Cellar, the dir must exist and be in the
    # PYTHONPATH.
    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages

    # Help pillow find zlib and little-cms (Note freetype2 is detected correctly)
    inreplace "setup.py" do |s|
      s.gsub! "ZLIB_ROOT = None", "ZLIB_ROOT = ('#{MacOS.sdk_path}/usr/lib', '#{MacOS.sdk_path}/usr/include')" unless MacOS::CLT.installed?
      s.gsub! "LCMS_ROOT = None", "LCMS_ROOT = ('#{Formula.factory('littlecms').opt_prefix}/lib', '#{Formula.factory('littlecms').opt_prefix}/include')"
    end

    args = [
      "--no-user-cfg",
      "--verbose",
      "install",
      "--force",
      "--single-version-externally-managed",
      "--install-scripts=#{share}/python",
      "--install-lib=#{temp_site_packages}",
      "--install-data=#{share}",
      "--install-headers=#{include}",
      "--record=installed-files.txt"
    ]
    system "python", "-s", "setup.py", *args

    # Move the installed-files.txt into the .egg-info dir so pip can uninstall
    mv 'installed-files.txt', Dir["#{temp_site_packages}/*.egg-info"].first

  end

  def test
    # Only a small test until https://github.com/python-imaging/Pillow/issues/17
    system "python", "-c", "import PIL"
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
