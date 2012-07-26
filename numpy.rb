require 'formula'

class Numpy < Formula
  url 'http://sourceforge.net/projects/numpy/files/NumPy/1.6.2/numpy-1.6.2.tar.gz'
  homepage 'http://www.scipy.org/'
  sha1 'c36c471f44cf914abdf37137d158bf3ffa460141'
  head 'https://github.com/numpy/numpy.git'

  depends_on 'nose' => :python

  def install
    ENV.fortran
    ENV['FFLAGS']='-ff2c'

    system "python", "setup.py", "build", "--fcompiler=gfortran"
    system "python", "setup.py", "install"
  end

  def test
    system "python", "-c 'import numpy; numpy.test()'"
  end
end
