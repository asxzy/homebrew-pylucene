require "formula"

class PyluceneCn < Formula
  homepage "http://lucene.apache.org/pylucene/index.html"
  url "http://www.apache.org/dyn/closer.cgi?path=lucene/pylucene/pylucene-4.9.0-0-src.tar.gz"
  sha1 "859613e405d266eaadc2f045e9200bc2d8765eb8"

  option "with-shared", "build jcc as a shared library"

  depends_on :ant => :build
  depends_on :java => "1.7"
  depends_on :python

  patch :DATA

  def install
    ENV.prepend_create_path "PYTHONPATH", lib/"python2.7/site-packages"
    jcc = "JCC=python -m jcc --arch #{MacOS.preferred_arch}"
    opt = "INSTALL_OPT=--prefix #{prefix}"
    if build.with? "shared"
      jcc << " --shared"
      opoo "shared option requires python to be built with the same compiler: #{ENV.compiler}"
    else
      opt << " --use-distutils"  # setuptools only required with shared
      ENV["NO_SHARED"] = "1"
    end

    cd "jcc" do
      system "python", "setup.py", "install", "--prefix=#{prefix}"
    end
    ENV.deparallelize  # the jars must be built serially
    system "make", "all", "install", opt, jcc, "ANT=ant", "PYTHON=python", "NUM_FILES=8"
  end

  test do
    ENV.prepend_path "PYTHONPATH", HOMEBREW_PREFIX/"lib/python2.7/site-packages"
    system "python", "-c", "import lucene; assert lucene.initVM()"
  end
end


__END__
diff --git a/Makefile b/Makefile
index ba74495..42d15c4 100644
--- a/Makefile
+++ b/Makefile
@@ -155,7 +155,7 @@ JARS+=$(EXTENSIONS_JAR)         # needs highlighter contrib
 JARS+=$(QUERIES_JAR)            # regex and other contrib queries
 JARS+=$(QUERYPARSER_JAR)        # query parser
 JARS+=$(SANDBOX_JAR)            # needed by query parser
-#JARS+=$(SMARTCN_JAR)            # smart chinese analyzer
+JARS+=$(SMARTCN_JAR)            # smart chinese analyzer
 JARS+=$(STEMPEL_JAR)            # polish analyzer and stemmer
 #JARS+=$(SPATIAL_JAR)            # spatial lucene
 JARS+=$(GROUPING_JAR)           # grouping module
@@ -342,6 +342,7 @@ GENERATE=$(JCC) $(foreach jar,$(JARS),--jar $(jar)) \
                              java.io.FileInputStream \
                              java.io.DataInputStream \
            --exclude org.apache.lucene.sandbox.queries.regex.JakartaRegexpCapabilities \
+                  --exclude org.apache.lucene.analysis.cn.smart.AnalyzerProfile\
            --exclude org.apache.regexp.RegexpTunnel \
            --python lucene \
            --mapping org.apache.lucene.document.Document 'get:(Ljava/lang/String;)Ljava/lang/String;' \
