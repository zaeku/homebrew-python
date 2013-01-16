require 'formula'

class Retext < Formula
  homepage 'http://sourceforge.net/projects/retext/'
  url 'http://sourceforge.net/projects/retext/files/ReText-4.0/ReText-4.0.0.tar.gz/download'
  sha1 '4a2ada905d790b4d8f3709271945008f50cd4d06'

  depends_on 'pyqt'
  depends_on 'markups' => :python
  depends_on 'markdown2' => :python
  depends_on 'docutils' => :python
  depends_on 'enchant' => :python
  depends_on 'enchant'

  def install
    # In order to install into the Cellar, the dir must exist and be in the
    # PYTHONPATH.
    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages

    args = [
      "--no-user-cfg",
      "--verbose",
      "install",
      "--force",
      "--install-scripts=#{share}/python",
      "--install-lib=#{temp_site_packages}",
      "--install-data=#{share}",
      "--install-headers=#{include}",
    ]
    system "python", "-s", "setup.py", *args
  end

  def test
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test retext`.
    system "false"
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
