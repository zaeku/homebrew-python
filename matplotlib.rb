require 'formula'

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
  url 'https://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.3.0/matplotlib-1.3.0.tar.gz'
  sha1 '4bcf177bbe2a1a576fbc0896e69c2de2cf7429ae'
  head 'https://github.com/matplotlib/matplotlib.git'

  depends_on :python
  # depends_on :python3 => :optional # todo ...
  depends_on :freetype
  depends_on :libpng
  depends_on 'numpy'
  depends_on TexRequirement => :optional
  depends_on 'cairo' => :optional
  depends_on 'ghostscript' => :optional
  depends_on 'pyside' => :optional
  depends_on 'pyqt' => :optional
  # depends_on 'pygtk' => :optional
  # depends_on 'pygobject' if build.with? 'pygtk'
  # On Xcode-only Macs, the Tk headers are not found by matplotlib
  depends_on 'homebrew/dupes/tcl-tk' => :optional
  depends_on :python => 'pyparsing'
  depends_on :python => ['dateutil' => 'python-dateutil']

  def install
    # Tell matplotlib, where brew is installed
    inreplace "setupext.py",
              "'darwin': ['/usr/local/', '/usr', '/usr/X11', '/opt/local'],",
              "'darwin': ['#{HOMEBREW_PREFIX}', '/usr', '/usr/X11', '/opt/local'],"

    # Apple has the Frameworks (esp. Tk.Framework) in a different place
    unless MacOS::CLT.installed?
      inreplace "setupext.py",
                "'/System/Library/Frameworks/',",
                "'#{MacOS.sdk_path}/System/Library/Frameworks',"
    end

    # This block will take care that "python" is the right python version and
    # will be run once for each python executable.
    python do
      system python.binary, "setup.py", "install", "--prefix=#{prefix}", "--record=installed.txt", "--single-version-externally-managed"
    end
  end

  def caveats
    python.standard_caveats +
    <<-EOS.undent
      If you want to use the `wxagg` backend, do `brew install wxwidgets`.
      This can be done even after the matplotlib install.
    EOS
  end

  test do
    python do
      ohai "This test takes quite a while. Use --verbose to see progress."
      system "python", "-c", "import matplotlib as m; m.test()"
    end
  end

end
