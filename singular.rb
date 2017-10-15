class Singular < Formula
  desc "Computer algebra system for polynomial computations."
  homepage "https://www.singular.uni-kl.de/"
  url "http://www.mathematik.uni-kl.de/ftp/pub/Math/Singular/src/4-1-0/singular-4.1.0p3.tar.gz"
  version "4.1.0"
  sha256 "440164c850d5a1575fcbfe95ab884088d03c0449570d40f465611932ffd0bf80"
  head "https://github.com/Singular/Sources.git"

  depends_on :xcode => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gmp"
  depends_on "ntl" => :recommended
  depends_on "flint" => :recommended
  depends_on "readline" => :recommended

  option "without-test", "Skip build-time tests (not recommended)"

  def install
    system "./autogen.sh"

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
    ]
    args << "--without-readline" if build.without? "readline"
    args << "--without-ntl" if build.without? "ntl"
    args << "--without-flint" if build.without? "flint"

    system "./configure", *args

    system "make"
    system "make", "check" if build.with? "test"
    system "make", "install"
  end

  test do
    File.open("test_input", "w") do |f|
      f.write <<-EOS.undent
        ring r = 0,(x,y,z),dp;
        poly p = x;
        poly q = y;
        poly qq = z;
        p*q*qq;
      EOS
    end
    test_output = `cat test_input | #{bin/"Singular"}`
    assert_equal 0, $CHILD_STATUS.exitstatus
    assert_match "xyz", test_output
  end
end
