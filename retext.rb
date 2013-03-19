require 'formula'

class RetextIcons < Formula
  url 'http://sourceforge.net/projects/retext/files/Icons/ReTextIcons_r3.tar.gz'
  sha1 'c51d4a687c21b7de3fd24a14a7ae16e9b0869e31'
end

class Retext < Formula
  homepage 'http://sourceforge.net/projects/retext/'
  url 'http://sourceforge.net/projects/retext/files/ReText-4.0/ReText-4.0.0.tar.gz'
  # 4.1 will drop python 2.x support!
  sha1 '4a2ada905d790b4d8f3709271945008f50cd4d06'

  depends_on :python
  depends_on 'pyqt'
  depends_on 'markups' => :python
  depends_on 'markdown' => :python
  depends_on 'docutils' => :python
  depends_on 'enchant'
  # depends_on LanguageModuleDependency.new(:python, 'pyenchant', 'enchant')

  def install
    python do
      system python.binary, "setup.py", "install", "--prefix=#{prefix}"

      # Copy icons to correct place an fix the path
      icons_dir = lib/python.xy/'site-packages/ReText/icons/'
      RetextIcons.new.brew { icons_dir.install Dir['*.*'] }
      inreplace lib/python.xy/'site-packages/ReText/__init__.py',
                'icon_path = "icons/"',
                "icon_path = '#{lib/python.xy}/site-packages/ReText/icons/'"
    end
  end

  def caveats
    <<-EOS.undent
      Run ReText by typing `retext.py`
    EOS
  end

end
