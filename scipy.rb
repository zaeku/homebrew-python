require 'formula'

class Scipy < Formula
  homepage 'http://www.scipy.org'
  url 'http://downloads.sourceforge.net/project/scipy/scipy/0.13.0/scipy-0.13.0.tar.gz'
  sha1 '704c2d0a855dd94a341546a475362038a9664dac'
  head 'https://github.com/scipy/scipy.git'

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on 'numpy'
  depends_on 'swig' => :build
  depends_on :fortran

  option 'with-openblas', "Use openBLAS (slower for LAPACK functions) instead of Apple's Accelerate Framework"
  depends_on 'homebrew/science/openblas' => :optional

  def install
    if build.with? 'openblas'
      # For maintainers:
      # Check which BLAS/LAPACK numpy actually uses via:
      # xcrun otool -L $(brew --prefix)/Cellar/scipy/<version>/lib/python2.7/site-packages/scipy/linalg/_flinalg.so
      # or the other .so files.
      openblas_dir = Formula.factory('openblas').opt_prefix
      # Setting ATLAS to None is important to prevent numpy from always
      # linking against Accelerate.framework.
      ENV['ATLAS'] = "None"
      ENV['BLAS'] = ENV['LAPACK'] = "#{openblas_dir}/lib/libopenblas.dylib"
    end

    python do
      # The Accelerate.framework uses a g77 ABI
      ENV.append 'FFLAGS', '-ff2c' unless build.with? 'openblas'

      # gfortran is gnu95
      system python, "setup.py", "build", "--fcompiler=gnu95", "install", "--prefix=#{prefix}"
    end
  end

  test do
    python do
      # If building for Python 2.x (at least the OS X provided python on 10.9)
      # Numpy and Scipy get confused when they find python 3.x in the
      # PKG_CONFIG_PATH, too. But that is what Homebrew does when we add the
      # `--with-python3`. So, until proper fixed, we clean that ENV var:
      ENV['PKG_CONFIG_PATH'] = ENV.determine_pkg_config_path
      ENV.prepend_path 'PKG_CONFIG_PATH', python.pkg_config_path

      system python, "-c", "import scipy; scipy.test()"
    end
  end

  def caveats
    python.standard_caveats if python
  end
end
