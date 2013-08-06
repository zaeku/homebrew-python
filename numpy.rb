require 'formula'

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
  homepage 'http://www.numpy.org'
  url 'http://downloads.sourceforge.net/project/numpy/NumPy/1.7.1/numpy-1.7.1.tar.gz'
  sha1 '11d878214d11a25e05a24f6b27e2b838815a2588'
  head 'https://github.com/numpy/numpy.git'

  devel do
    url 'http://downloads.sourceforge.net/project/numpy/NumPy/1.8.0b1/numpy-1.8.0b1.tar.gz'
    sha1 'eb8272284f290f4773039968c50ee81739227cf0'
  end

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on :python => 'nose'
  depends_on :python3 => 'nose' if build.with? 'python3'
  depends_on :fortran
  depends_on NoUserConfig
  depends_on 'homebrew/science/suite-sparse'  # for libamd and libumfpack

  option 'with-openblas', "Use openBLAS (slower for LAPACK functions) instead of Apple's Accelerate Framework"
  depends_on "homebrew/science/openblas" => :optional

  def patches
    # Help numpy/distutils find homebrew's versioned gfortran-4.7 executable,
    # if `brew install gcc --enable-fortran` was used.
    DATA unless build.devel?
  end

  def install
    # Numpy is configured via a site.cfg and we want to use some libs
    # For maintainers:
    # Check which BLAS/LAPACK numpy actually uses via:
    # xcrun otool -L /usr/local/Cellar/numpy/1.6.2/lib/python2.7/site-packages/numpy/linalg/lapack_lite.so
    config = <<-EOS.undent
      [DEFAULT]
      library_dirs = #{HOMEBREW_PREFIX}/lib
      include_dirs = #{HOMEBREW_PREFIX}/include

      [amd]
      amd_libs = amd, cholmod, colamd, ccolamd, camd, suitesparseconfig
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

    rm_f 'site.cfg' if build.devel?
    Pathname('site.cfg').write config

    python do
      # Numpy ignores FC and FCFLAGS, but we declare fortran so Homebrew knows
      # gfortran is gnu95
      system python, "setup.py", "build", "--fcompiler=gnu95", "install", "--prefix=#{prefix}"
    end
  end

  def test
    python do
      system python, "-c", "import numpy; numpy.test()"
    end
  end

  def caveats
    s = "Numpy ignores the `FC` env var and looks for gfortran during build.\n"
    s += python.standard_caveats if python
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
