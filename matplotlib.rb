require 'formula'

class NumpyRequirement < Requirement
  fatal true

  def satisfied?
    system("python", "-c", "import numpy")
  end

  def message; <<-EOS.undent
    Numpy is needed for matplotlib:
        brew install numpy
    EOS
  end
end

class TexRequirement < Requirement
  fatal false
  env :userpaths

  def satisfied?
    quiet_system('latex', '-version')  && quiet_system("dvipng", "-version")
  end

  def message; <<-EOS.undent
    LaTeX not found. This is optional for Matplotlib.
    If you want, https://www.tug.org/mactex/ provides an installer.
    EOS
  end
end

class Matplotlib < Formula
  homepage 'http://matplotlib.org'
  url 'https://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.2.0/matplotlib-1.2.0.tar.gz'
  sha1 '1d0c319b2bc545f1a7002f56768e5730fe573518'
  head 'https://github.com/matplotlib/matplotlib.git'

  option 'with-pyside', 'Build with PySide (Qt) backend'
  option 'with-pyqt', 'Build with the older PyQt backend'
  option 'with-gtk', 'Build with PyGTK backend'
  option 'with-wx', 'Build with WxWidgets backend'
  option 'with-brewed-tk', 'Use the newer Tkinter from homebrew and not from OS X'

  depends_on :freetype
  depends_on :libpng
  # Because `depends_on 'numpy' => :python` would suggest to `pip install numpy`
  # that fails to build, we use our requirement to suggest `brew install numpy`:
  depends_on NumpyRequirement.new
  depends_on TexRequirement.new
  depends_on 'cairo' => :optional
  depends_on 'ghostscript' => :optional
  depends_on 'pyside' if build.include? 'with-pyside'
  depends_on 'pyqt' if build.include? 'with-pyqt'
  depends_on 'pygtk' if build.include? 'with-pygtk'
  # On Xcode-only Macs, the Tk headers are not found by matplotlib
  depends_on 'homebrew/dupes/tk' if build.include?('with-brewed-tk')

  def install
    # Tell matplotlib, where brew is installed
    inreplace "setupext.py",
              "'darwin' : ['/usr/local/', '/usr', '/usr/X11', '/opt/local'],",
              "'darwin' : ['#{HOMEBREW_PREFIX}', '/usr', '/usr/X11', '/opt/local'],"

    # Apple has the Frameworks (esp. Tk.Framework) in a different place
    unless MacOS::CLT.installed?
      inreplace "setupext.py",
                "'/System/Library/Frameworks/',",
                "'#{MacOS.sdk_path}/System/Library/Frameworks',"
    end

    # In order to install into the Cellar, the dir must exist and be in the
    # PYTHONPATH.
    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages

    args = [
      "--no-user-cfg",
      "--verbose",
      "install",
      "--force",
      "--install-scripts=#{share}/python",
      "--install-lib=#{temp_site_packages}",
      "--install-data=#{share}",
      "--install-headers=#{include}",
    ]

    system "python", "-s", "setup.py", *args
  end

  def caveats
    <<-EOS.undent
      For non-homebrew Python, you need to amend your PYTHONPATH like so:
      export PYTHONPATH=#{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages:$PYTHONPATH

      If you want to use the `wxagg` backend, do `brew install wxwidgets`.
      This can be done even after the matplotlib install.
    EOS
  end

  test do
    ohai "This test takes quite a while. Use --verbose to see progress."
    system "python", "-c", "import matplotlib as m; m.test()"
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
