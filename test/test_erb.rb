require 'minitest/autorun'
require 'open3'
require 'tmpdir'
require 'fileutils'

class TestErbScript < Minitest::Test
  def setup
    @original_dir = Dir.pwd
    @tmp_dir = Dir.mktmpdir

    # Copy necessary directories to the temp dir to avoid modifying the real repo
    %w[scripts images weapons categorize].each do |dir|
      FileUtils.cp_r(File.join(@original_dir, dir), @tmp_dir)
    end

    # Add dummy file to satisfy README.md template (images/mhw-dark.png, etc)
    # The real files were copied, so we are good.

    # Write a malformed YAML file that triggers an error in the second data processing block
    @test_file = File.join(@tmp_dir, "weapons", "zz_malformed_test.yml")
    File.write(@test_file, <<~YAML)
      name: malformed
      category: android
      description: test
      url: ''
      platform: []
      tags: 123
      lang: []
      type: none
    YAML
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  def test_error_handling_in_data_processing
    # Change directory to the temp dir and run the script
    Dir.chdir(@tmp_dir) do
      # Run the script and capture output
      stdout, stderr, status = Open3.capture3("ruby scripts/erb.rb")

      # Script should rescue the error and not crash
      assert_equal 0, status.exitstatus, "Script should not crash on malformed data"

      # The output should contain the specific error message caught by rescue => e
      assert_match /undefined method `each' for 123:Integer/m, stdout, "Should catch and print error from processing malformed tags"
    end
  end
end
