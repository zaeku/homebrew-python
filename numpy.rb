require 'formula'

class Numpy < Formula
  url 'http://sourceforge.net/projects/numpy/files/NumPy/1.6.1/numpy-1.6.1.tar.gz'
  homepage 'http://www.scipy.org/'
  md5 '2bce18c08fc4fce461656f0f4dd9103e'
  head 'https://github.com/numpy/numpy.git'

  depends_on 'nose' => :python

  def install
    ENV.fortran
    ENV['CC']='gcc-4.2'
    ENV['CXX']='g++-4.2'
    ENV['FFLAGS']='-ff2c'

    system "python", "setup.py", "build", "--fcompiler=gfortran"
    system "python", "setup.py", "install"
  end

  def test
    system "python", "-c 'import numpy; numpy.test()'"
  end
end
