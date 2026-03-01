require 'minitest/autorun'
require 'fileutils'
require 'open3'
require 'tmpdir'

class TestValidateWeapons < Minitest::Test
  def setup
    @original_dir = Dir.pwd
    @temp_dir = File.join(Dir.tmpdir, "weapons_test_#{Time.now.to_i}")
    FileUtils.mkdir_p(File.join(@temp_dir, "weapons"))
  end

  def teardown
    FileUtils.rm_rf(@temp_dir)
  end

  def test_malformed_yaml_is_rescued
    # Create a malformed YAML file
    File.write(File.join(@temp_dir, "weapons", "malformed.yaml"), ": malformed\nyaml:\n  -")

    script_path = File.join(@original_dir, "scripts", "validate_weapons.rb")

    # Run the script in the temporary directory
    Dir.chdir(@temp_dir) do
      stdout, stderr, status = Open3.capture3("ruby #{script_path}")

      # Assert that the error was caught and printed to stdout
      assert_match(/did not find expected key/, stdout)

      # Script should not crash (exit status 0 because it rescued)
      assert status.success?
    end
  end
end
