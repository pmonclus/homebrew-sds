class Sds < Formula
  desc "SDS - Synchronized Data Structures for IoT over MQTT"
  homepage "https://github.com/pmonclus/sds-library"
  url "https://github.com/pmonclus/sds-library/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "libpaho-mqtt"
  depends_on "python@3.12"

  def install
    # Build C library with CMake
    system "cmake", "-S", ".", "-B", "build",
           "-DSDS_BUILD_TESTS=OFF",
           "-DSDS_BUILD_EXAMPLES=OFF",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Install Python SDS bindings
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    system python3, "-m", "pip", "install", "--prefix=#{prefix}",
           "--no-build-isolation", "#{buildpath}/python"

    # Install codegen package (provides sds-codegen command)
    system python3, "-m", "pip", "install", "--prefix=#{prefix}",
           "--no-build-isolation", buildpath.to_s

    # Create Arduino ZIP in share directory
    (share/"sds").mkpath
    arduino_dir = buildpath/"arduino_temp/SDS"
    arduino_dir.mkpath
    (arduino_dir/"src").mkpath

    # Copy Arduino source files (excluding sds_types.h which is generated)
    %w[sds.h sds_error.h sds_json.h sds_platform.h].each do |header|
      cp "include/#{header}", arduino_dir/"src/"
    end
    cp "src/sds_core.c", arduino_dir/"src/"
    cp "src/sds_json.c", arduino_dir/"src/"
    cp "platform/esp32/sds_platform_esp32.cpp", arduino_dir/"src/"

    # Create library.properties
    (arduino_dir/"library.properties").write <<~EOS
      name=SDS
      version=#{version}
      author=SDS Team
      maintainer=SDS Team
      sentence=Lightweight MQTT state synchronization for IoT
      paragraph=Synchronized Data Structures library for ESP32/ESP8266
      category=Communication
      url=https://github.com/pmonclus/sds-library
      architectures=esp32,esp8266
      depends=PubSubClient
    EOS

    # Create the ZIP
    cd buildpath/"arduino_temp" do
      system "zip", "-r", share/"sds/sds-arduino-#{version}.zip", "SDS"
    end

    # Copy codegen tools to share
    (share/"sds/tools").mkpath
    cp_r "codegen", share/"sds/tools/"
    cp "tools/sds_codegen.py", share/"sds/tools/"
  end

  def caveats
    python = Formula["python@3.12"]
    <<~EOS
      SDS installed successfully!

      Usage:
        # Generate types from schema
        sds-codegen schema.sds --c --python

        # Arduino library available at:
        #{share}/sds/sds-arduino-#{version}.zip

        Install in Arduino IDE:
          Sketch → Include Library → Add .ZIP Library

      Python:
        You may need to add the Python site-packages to your PYTHONPATH:
        export PYTHONPATH="#{lib}/python#{python.version.major_minor}/site-packages:$PYTHONPATH"
    EOS
  end

  test do
    # Test sds-codegen
    (testpath/"test.sds").write <<~EOS
      @version = "1.0.0"
      table TestTable {
          @sync_interval = 1000
          config { uint8 value; }
          state { float temp; }
          status { uint8 code; }
      }
    EOS

    system "#{bin}/sds-codegen", "test.sds", "--c"
    assert_predicate testpath/"sds_types.h", :exist?
  end
end
