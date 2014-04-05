require 'formula'

class NoUserConfig < Requirement
  def satisfied?
    not File.exist? "#{ENV['HOME']}/.numpy-site.cfg"
  end

  def message; <<-EOS.undent
      A ~/.numpy-site.cfg has been detected, which may interfere with brew's build.
    EOS
  end
end

class Numpy < Formula
  homepage 'http://www.numpy.org'
  url 'https://downloads.sourceforge.net/project/numpy/NumPy/1.8.0/numpy-1.8.0.tar.gz'
  sha1 'a2c02c5fb2ab8cf630982cddc6821e74f5769974'
  head 'https://github.com/numpy/numpy.git'

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on :fortran
  depends_on NoUserConfig
  depends_on 'homebrew/science/suite-sparse'  # for libamd and libumfpack

  option 'with-openblas', "Use openBLAS instead of Apple's Accelerate Framework"
  depends_on "homebrew/science/openblas" => :optional

  resource 'nose' do
    url 'https://pypi.python.org/packages/source/n/nose/nose-1.3.1.tar.gz'
    sha1 '19ba8f266a8ee4f128ef3eebf3c3e04e8ea7b998'
  end

  def package_installed? python, module_name
    quiet_system python, "-c", "import #{module_name}"
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
    end

    rm_f 'site.cfg' if build.devel?
    Pathname('site.cfg').write config

    # Numpy ignores FC and FCFLAGS, but we declare fortran so Homebrew knows
    # gfortran is gnu95
    Language::Python.each_python(build) do |python, version|
      resource("nose").stage { system python, "setup.py", "install" } unless package_installed? python, "nose"
      system python, "setup.py", "build", "--fcompiler=gnu95", "install", "--prefix=#{prefix}"
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import numpy; numpy.test()"
    end
  end

  def caveats
    "Numpy ignores the `FC` env var and looks for gfortran during build."
  end
end
