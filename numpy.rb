require 'formula'

class GfortranAvailable < Requirement
  def satisfied?
    which 'gfortran' or which 'gfortran-4.7'
  end

  def fatal?
    true
  end

  def message; <<-EOS.undent
      No gfortran found! You may use gfortran provided by homebrew:
        `brew install gfortran`
    EOS
  end
end

class NoUserConfig < Requirement
  def satisfied?
    not File.exist? "#{ENV['HOME']}/.numpy-site.cfg"
  end

  def message; <<-EOS.undent
      A ~/.numpy-site.cfg has been detected, which may interfere with our business.
    EOS
  end
end

class Numpy < Formula
  homepage 'http://numpy.scipy.org'
  url 'http://sourceforge.net/projects/numpy/files/NumPy/1.7.0/numpy-1.7.0.tar.gz'
  sha1 'ba328985f20390b0f969a5be2a6e1141d5752cf9'
  head 'https://github.com/numpy/numpy.git'

  depends_on 'nose' => :python
  depends_on GfortranAvailable.new
  depends_on NoUserConfig.new
  depends_on 'homebrew/science/suite-sparse'  # for libamd and libumfpack

  option 'with-openblas', "Use openBLAS (slower for LAPACK functions) instead of Apple's Accelerate Framework"
  depends_on "homebrew/science/openblas" => :optional

  def patches
    # Help numpy/distutils find homebrew's versioned gfortran-4.7 executable,
    # if `brew install gcc --enable-fortran` was used.
    DATA
  end

  def install
    # Numpy ignores FC and FCFLAGS, but we declare fortran so Homebrew knows
    ENV.fortran

    # Numpy is configured via a site.cfg and we want to use some libs
    # For maintainers:
    # Check which BLAS/LAPACK numpy actually uses via:
    # xcrun otool -L /usr/local/Cellar/numpy/1.6.2/lib/python2.7/site-packages/numpy/linalg/lapack_lite.so
    config = <<-EOS.undent
      [DEFAULT]
      library_dirs = #{HOMEBREW_PREFIX}/lib
      include_dirs = #{HOMEBREW_PREFIX}/include

      [amd]
      amd_libs = amd

      [umfpack]
      umfpack_libs = umfpack

    EOS

    if build.with? 'openblas'
      openblas_dir = Formula.factory('openblas').opt_prefix
      # Setting ATLAS to None is important to prevent numpy from always
      # linking against Accelerate.framework.
      ENV['ATLAS'] = "None"
      ENV['BLAS'] = ENV['LAPACK'] = "#{openblas_dir}/lib/libopenblas.dylib"

      config << <<-EOS.undent
        [blas_opt]
        libraries = openblas
        library_dirs = #{openblas_dir}/lib
        include_dirs = #{openblas_dir}/include

        [lapack_opt]
        libraries = openblas
        library_dirs = #{openblas_dir}/lib
        include_dirs = #{openblas_dir}/include
      EOS
    end

    Pathname('site.cfg').write config

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
    system "python", "-c", "import numpy; numpy.test()"
  end

  def caveats
    'Numpy ignores the `FC` env var and looks for gfortran during build.'
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end

__END__
diff --git a/numpy/distutils/fcompiler/gnu.py b/numpy/distutils/fcompiler/gnu.py
index e80a417..15d164b 100644
--- a/numpy/distutils/fcompiler/gnu.py
+++ b/numpy/distutils/fcompiler/gnu.py
@@ -247,7 +247,7 @@ class Gnu95FCompiler(GnuFCompiler):
     #       GNU Fortran 95 (GCC) 4.2.0 20060218 (experimental)
     #       GNU Fortran (GCC) 4.3.0 20070316 (experimental)
 
-    possible_executables = ['gfortran', 'f95']
+    possible_executables = ['gfortran', 'gfortran-4.7']
     executables = {
         'version_cmd'  : ["<F90>", "--version"],
         'compiler_f77' : [None, "-Wall", "-ffixed-form",
