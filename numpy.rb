require 'formula'

class Gfortran < Requirement
  def satisfied?
    which 'gfortran' or which 'gfortran-4.7'
  end

  def fatal?
    true
  end

  def message; <<-EOS.undent
      You have to either
        - `brew install gfortran` or
        - `brew tap homebrew/dupes && brew install gcc --enable-fortran`.

      The latter builts the latest gcc release from source and takes some time.
    EOS
  end
end

class NoUserConfig < Requirement
  def satisfied?
    not File.exist? '~/.numpy-site.cfg'
  end

  def message; <<-EOS.undent
      A ~/.numpy-site.cfg has been detected, which may interfere with our business.
    EOS
  end
end

class Numpy < Formula
  url 'http://sourceforge.net/projects/numpy/files/NumPy/1.6.2/numpy-1.6.20060218.tar.gz'
  homepage 'http://www.scipy.org/'
  sha1 'c36c471f44cf914abdf37137d158bf3ffa460141'
  head 'https://github.com/numpy/numpy.git'

  depends_on 'nose' => :python
  depends_on Gfortran.new
  depends_on NoUserConfig.new
  depends_on 'suite-sparse'  # for libamd and libumfpack

  # temporary use staticfloat's openblas until it has been pulled into homebrew/science
  # depends_on 'openblas' if build.include? 'use-openblas'
  depends_on "staticfloat/julia/openblas" if build.include? 'use-openblas'

  option 'use-openblas', "Use openBLAS instead of Apple's Accelerate Framework"

  def patches
    # Help numpy/distutils find homebrew's versioned gfortran-4.7 executable,
    # if `brew install gcc --enable-fortran` was used.
    DATA
  end

  def install
    # Numpy ignores FC and FCFLAGS therefore we don't need ENV.fortran here :-(

    if build.include? 'use-openblas'
      # For maintainers:
      # Check which BLAS/LAPACK numpy actually uses via:
      # xcrun otool -L Cellar/numpy/1.6.2/lib/python2.7/site-packages/numpy/linalg/lapack_lite.so
      ENV['ATLAS'] = "None"
      ENV['BLAS'] = "#{Formula.factory('staticfloat/julia/openblas').lib}/libopenblas.dylib"
      ENV['LAPACK'] = "#{Formula.factory('staticfloat/julia/openblas').lib}/libopenblas.dylib"
    end

    # Numpy is configured via a site.cfg and we want to use some libs
    config = <<-EOS.undent
      [DEFAULT]
      library_dirs = #{HOMEBREW_PREFIX}/lib
      include_dirs = #{HOMEBREW_PREFIX}/include

      [amd]
      amd_libs = amd

      [umfpack]
      umfpack_libs = umfpack

    EOS

    Pathname('site.cfg').write config

    # gfortran is gnu95
    system "python", "setup.py", "build", "--fcompiler=gnu95"
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end

  def test
    system "python", "-c", "import numpy; numpy.test()"
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
+    possible_executables = ['gfortran-4.7', 'f95', 'gfortran']
     executables = {
         'version_cmd'  : ["<F90>", "--version"],
         'compiler_f77' : [None, "-Wall", "-ffixed-form",
