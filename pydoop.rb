require 'formula'

class JdkInstalled < Requirement
  fatal true
  satisfy{ which 'javac'}
  def message; <<-EOS.undent
    A JDK is required.  You can get the official Oracle installers from:
    http://www.oracle.com/technetwork/java/javase/downloads/index.html
    EOS
  end
end

class JavaHome < Requirement
  fatal true
  satisfy { ENV["JAVA_HOME"] }
  def message; <<-EOS.undent
    JAVA_HOME is not set:  please set it to the correct value for your Java
    installation. For instance:
    /Library/Java/JavaVirtualMachines/jdk1.7.0_11.jdk/Contents/Home
    EOS
  end
end

class Pydoop < Formula
  homepage 'http://http://pydoop.sourceforge.net/'
  url 'http://sourceforge.net/projects/pydoop/files/Pydoop-0.9/pydoop-0.9.1.tar.gz'
  sha1 'bd26426c49a293196d6ef20c751d2d18c0c7feea'

  depends_on :python
  depends_on JdkInstalled
  depends_on JavaHome
  depends_on 'boost'
  depends_on 'hadoop' unless(ENV["HADOOP_HOME"])

  def install
    unless(ENV["HADOOP_HOME"])
      ohai "HADOOP_HOME is not set. Using brewed version"
      ENV.append 'HADOOP_HOME', Formula.factory('hadoop').libexec
    end
    unless(ENV["BOOST_PYTHON"])
      ENV['BOOST_PYTHON'] = 'boost_python-mt'
    end

    python do
      system python.binary, 'setup.py', 'install', "--prefix=#{prefix}"
    end

    prefix.install %w[test examples]
  end

  def caveats;
    s = ''
    s += python.standard_caveats if python
    s += <<-EOS.undent
    If you use the Homebrew version of Python, you might get a
    "PyThreadState_Get: no current thread" error. In this case, try
    reinstalling boost with the --build-from-source option. For
    details, see:
    https://github.com/mxcl/homebrew/wiki/Common-Issues
    EOS
  end

end
