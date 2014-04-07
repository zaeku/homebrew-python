require 'formula'

class Scipy < Formula
  homepage 'http://www.scipy.org'
  url 'https://downloads.sourceforge.net/project/scipy/scipy/0.13.3/scipy-0.13.3.tar.gz'
  sha1 '2c7d53fc1d7bfe0a3ab5818ef6d84cb5d8cfcca4'
  head 'https://github.com/scipy/scipy.git'

  # Due to possibly corrupted installs out there making, because
  # we had the `-D__ACCELERATE` flag used for clang for a few days, which
  # seems to make all kind of trouble (you can test with `brew test -v scipy)
  revision 1

  devel do
    url 'https://downloads.sourceforge.net/project/scipy/scipy/0.14.0rc1/scipy-0.14.0rc1.tar.gz'
    sha1 '07dd73a5f4eb2c9561bc6767e7ec8c24a1018456'
  end

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on 'swig' => :build
  depends_on :fortran
  option 'with-openblas', "Use openBLAS instead of Apple's Accelerate Framework"
  depends_on 'homebrew/science/openblas' => :optional

  numpy_options = []
  numpy_options << "with-python3" if build.with? "python3"
  numpy_options << "with-openblas" if build.with? "openblas"
  depends_on "numpy" => numpy_options

  def install
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
      # For maintainers:
      # Check which BLAS/LAPACK numpy actually uses via:
      # xcrun otool -L $(brew --prefix)/Cellar/scipy/<version>/lib/python2.7/site-packages/scipy/linalg/_flinalg.so
      # or the other .so files.
      openblas_dir = Formula["openblas"].opt_prefix
      # Setting ATLAS to None is important to prevent numpy from always
      # linking against Accelerate.framework.
      ENV['ATLAS'] = "None"
      ENV['BLAS'] = ENV['LAPACK'] = "#{openblas_dir}/lib/libopenblas.dylib"

      config << <<-EOS.undent
        [openblas]
        libraries = openblas
        library_dirs = #{openblas_dir}/lib
        include_dirs = #{openblas_dir}/include
      EOS
    else
      # The Accelerate.framework uses a g77 ABI
      ENV.append 'FFLAGS', '-ff2c' if build.without? 'openblas'
      # https://github.com/Homebrew/homebrew-python/pull/73
      # Only save for gcc and allows you to `brew install scipy --cc=gcc-4.8`
      ENV.append 'CPPFLAGS', '-D__ACCELERATE__' if ENV.compiler == :gcc
    end

    rm_f 'site.cfg' if build.devel?
    Pathname('site.cfg').write config

    # gfortran is gnu95
    Language::Python.each_python(build) do |python, version|
      system python, "setup.py", "build", "--fcompiler=gnu95", "install", "--prefix=#{prefix}"
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import scipy; scipy.test()"
    end
  end

  def caveats
    if build.with? "python" and not Formula['python'].installed?
      <<-EOS.undent
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you actually may
        have to set the `PYTHONPATH` in order to make the brewed packages come
        before these shipped packages in Python's `sys.path`.
            export PYTHONPATH=#{HOMEBREW_PREFIX}/lib/python2.7/site-packages
      EOS
    end
  end

end
