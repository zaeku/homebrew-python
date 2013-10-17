require 'formula'

class Scipy < Formula
  homepage 'http://www.scipy.org'
  url 'http://downloads.sourceforge.net/project/scipy/scipy/0.12.1/scipy-0.12.1.tar.gz'
  sha1 '72fc43def904105fd93b21283bdaa559c726154d'
  head 'https://github.com/scipy/scipy.git'

  devel do
    url 'http://downloads.sourceforge.net/project/scipy/scipy/0.13.0rc1/scipy-0.13.0rc1.tar.gz'
    sha1 'cc5c74c0a81900c9bfeccb70f79984d8e144fca6'
  end

  def patches
   # fix an ARPACK bug that shows primarily on Mac OS X
   "https://github.com/scipy/scipy/pull/2684.diff" unless build.devel?
  end

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
      system python, "-c", "import scipy; scipy.test()"
    end
  end

  def caveats
    python.standard_caveats if python
  end
end
