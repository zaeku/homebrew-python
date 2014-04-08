require 'formula'

class Retext < Formula
  homepage 'http://sourceforge.net/projects/retext/'
  url 'https://downloads.sourceforge.net/project/retext/ReText-4.0/ReText-4.0.0.tar.gz'
  # 4.1 will drop python 2.x support!
  sha1 '4a2ada905d790b4d8f3709271945008f50cd4d06'

  depends_on :python
  depends_on 'pyqt'
  depends_on 'markups' => :python
  depends_on 'markdown' => :python
  depends_on 'docutils' => :python
  depends_on 'enchant' => "with-python"

  resource 'retext_icons' do
    url 'https://downloads.sourceforge.net/project/retext/Icons/ReTextIcons_r3.tar.gz'
    sha1 'c51d4a687c21b7de3fd24a14a7ae16e9b0869e31'
  end

  def install
    Language::Python.each_python(build) do |python, version|
      system python, "setup.py", "install", "--prefix=#{prefix}"

      # Copy icons to correct place an fix the path
      target_dir = lib/"python#{version}/site-packages/ReText"
      resource('retext_icons').stage { (target_dir/"icons/").install Dir['*.*'] }
      inreplace target_dir/'__init__.py',
                'icon_path = "icons/"',
                "icon_path = '#{target_dir}/icons/'"
    end
  end

  def caveats
    "Run ReText by typing `retext.py`"
  end
end
