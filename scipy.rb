require 'formula'
require Formula.path("numpy")  # For numpy distutils and gfortran check

class Scipy < Formula
  url 'http://sourceforge.net/projects/scipy/files/scipy/0.11.0rc2/scipy-0.11.0rc2.tar.gz'
  homepage 'http://www.scipy.org'
  sha1 '174923793f49b893699f5c601c4e64537fdb07d4'
  head 'https://github.com/scipy/scipy.git'

  depends_on Gfortran.new
  depends_on NoUserConfig.new
  depends_on 'numpy'
  depends_on 'swig' => :build

  option 'use-openblas', "Use openBLAS instead of Apple's Accelerate Framework"

  def install
    # This hack is no longer needed with superenv but I leave it here because
    # people might want to use a custom CC compiler with scipy by setting
    # --env=std and HOMEBREW_CC:
    # gfortran cannot link (call the linker) if LDFLAGS are set, because
    # numpy/scipy overwrite their internal flags if this var is set. Stupid.
    ENV['LDFLAGS'] = nil

    if build.include? 'use-openblas'
      # For maintainers:
      # Check which BLAS/LAPACK numpy actually uses via:
      # xcrun otool -L Cellar/scipy/0.11.0rc2/lib/python2.7/site-packages/scipy/linalg/_flinalg.so
      # or the other .so files.
      ENV['ATLAS'] = "None"
      ENV['BLAS'] = "#{Formula.factory('staticfloat/julia/openblas').lib}/libopenblas.dylib"
      ENV['LAPACK'] = "#{Formula.factory('staticfloat/julia/openblas').lib}/libopenblas.dylib"
    end

    system "python", "setup.py", "build", "--fcompiler=gnu95"
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end

  def test
    system "python", "-c", "import scipy; scipy.test()"
  end
end
