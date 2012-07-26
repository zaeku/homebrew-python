require 'formula'

class Scipy < Formula
  url 'http://sourceforge.net/projects/scipy/files/scipy/0.10.0/scipy-0.10.0.tar.gz'
  homepage 'http://www.scipy.org'
  md5 'e357c08425fd031dce63bc4905789088'
  head 'https://github.com/scipy/scipy.git'

  depends_on 'nose' => :python
  depends_on 'numpy' => :python

  def install
    ENV.fortran
    ENV['CC']='gcc-4.2'
    ENV['CXX']='g++-4.2'
    ENV['FFLAGS']='-ff2c'
    system "python", "setup.py", "build", "--fcompiler=gfortran"
    system "python", "setup.py", "install"
  end

  def test
    system "python", "-c 'import scipy; scipy.test()'"
  end
end
