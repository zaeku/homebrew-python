require 'formula'
require Formula.path("numpy")  # For numpy distutils and gfortran check

class Scipy < Formula
  url 'http://sourceforge.net/projects/scipy/files/scipy/0.11.0/scipy-0.11.0.tar.gz'
  homepage 'http://www.scipy.org'
  sha1 'e8dc162cf3acf8aa4fe7aeafc0ce53cc9d0f51ed'
  head 'https://github.com/scipy/scipy.git'
  # devel do
  #   url 'not yet but will be for 0.12'
  #   sha1 'todo'
  # end

  depends_on GfortranAvailable.new
  depends_on NoUserConfig.new
  depends_on 'numpy'
  depends_on 'swig' => :build

  option 'use-openblas', "Use openBLAS instead of Apple's Accelerate Framework"
  depends_on 'openblas' if build.include? 'use-openblas'

  def install
    ENV.fortran

    if build.include? 'use-openblas'
      # For maintainers:
      # Check which BLAS/LAPACK numpy actually uses via:
      # xcrun otool -L /usr/local/Cellar/scipy/0.11.0/lib/python2.7/site-packages/scipy/linalg/_flinalg.so
      # or the other .so files.
      openblas_dir = Formula.factory('openblas').opt_prefix
      # Setting ATLAS to None is important to prevent numpy from always
      # linking against Accelerate.framework.
      ENV['ATLAS'] = "None"
      ENV['BLAS'] = ENV['LAPACK'] = "#{openblas_dir}/lib/libopenblas.dylib"
    end

    # In order to install into the Cellar, the dir must exist and be in the
    # PYTHONPATH.
    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages

    args = [
      "--no-user-cfg",
      "--verbose",
      "build",
      "--fcompiler=gnu95", # gfortran is gnu95
      "install",
      "--force",
      "--install-scripts=#{share}/python",
      "--install-lib=#{temp_site_packages}",
      "--install-data=#{share}",
      "--install-headers=#{include}",
      "--record=installed-files.txt"
    ]

    system "python", "-s", "setup.py", *args
  end

  def test
    system "python", "-c", "import scipy; scipy.test()"
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
