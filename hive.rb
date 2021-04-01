class Hive < Formula
  desc "Hadoop-based data summarization, query, and analysis"
  homepage "https://hive.apache.org"
  url "https://apache-mirror.rbc.ru/pub/apache/hive/hive-2.3.8/apache-hive-2.3.8-bin.tar.gz"
  license "Apache-2.0"
  revision 2
  sha256 "3746528298fb70938e30bfbb66f756d1810acafbe86ba84edef7bd3455589176"

  bottle :unneeded

  depends_on "nevgin/hadoop/hadoop"

  # hive requires Java 8. Java 11 support ticket:
  # https://issues.apache.org/jira/browse/HIVE-22415
  depends_on "openjdk@8"
  conflicts_with "hive", because: "both install hive2 and hive3  binaries"

  def install
    rm_f Dir["bin/*.cmd", "bin/ext/*.cmd", "bin/ext/util/*.cmd"]
    libexec.install %w[bin conf examples hcatalog lib scripts]

    # Hadoop currently supplies a newer version
    # and two versions on the classpath causes problems
    #rm libexec/"lib/guava-19.0.jar"
    #guava = (Formula["hadoop"].opt_libexec/"share/hadoop/common/lib").glob("guava-*-jre.jar")
    #ln_s guava.first, libexec/"lib"

    Pathname.glob("#{libexec}/bin/*") do |file|
      next if file.directory?

      (bin/file.basename).write_env_script file,
        JAVA_HOME:   Formula["openjdk@8"].opt_prefix,
        HADOOP_HOME: "${HADOOP_HOME:-#{Formula["hadoop"].opt_libexec}}",
        HIVE_HOME:   libexec
    end
  end

  def caveats
    <<~EOS
      If you want to use HCatalog with Pig, set $HCAT_HOME in your profile:
        export HCAT_HOME=#{opt_libexec}/hcatalog
    EOS
  end

  test do
    system bin/"schematool", "-initSchema", "-dbType", "derby"
    assert_match "123", shell_output("#{bin}/hive -e 'SELECT 123'")
  end
end
