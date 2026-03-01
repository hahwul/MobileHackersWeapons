require 'minitest/autorun'
require 'fileutils'
require 'open3'
require 'tmpdir'

class TestErbScript < Minitest::Test
  def setup
    # Save current directory
    @original_dir = Dir.pwd

    # Create a temporary directory for testing
    @temp_dir = Dir.mktmpdir("weapons_test")

    # Change to temp directory
    Dir.chdir(@temp_dir)

    # Set up necessary directory structure
    FileUtils.mkdir_p('weapons')
    FileUtils.mkdir_p('images')
    FileUtils.mkdir_p('categorize/tags')
    FileUtils.mkdir_p('categorize/langs')

    # Create required files that erb.rb expects
    FileUtils.touch('images/mhw-dark.png')
    FileUtils.touch('images/mhw-light.png')
    FileUtils.touch('CONTRIBUTING.md')
  end

  def teardown
    # Change back to original directory
    Dir.chdir(@original_dir)

    # Remove the temporary directory
    FileUtils.remove_entry(@temp_dir)
  end

  def test_yaml_load_error_handling
    # Create an invalid YAML file in the temp weapons directory
    File.write('weapons/invalid.yaml', "invalid: \n- : : ")

    # Create a valid YAML file to ensure the script continues processing
    valid_yaml = <<~YAML
      name: TestTool
      type: Pentest
      description: A test tool
      platform: ['linux']
      tags: ['test']
      lang: Ruby
      url: https://github.com/test/tool
      category: All
    YAML
    File.write('weapons/valid.yaml', valid_yaml)

    # Run the erb.rb script from the original directory inside the temp directory context
    script_path = File.join(@original_dir, 'scripts/erb.rb')
    stdout, stderr, status = Open3.capture3("ruby #{script_path}")

    # The script should exit successfully because the error is rescued
    assert status.success?, "Script failed to execute successfully. Stderr: #{stderr}"

    # The output should contain the syntax error from the invalid YAML
    assert_match(/did not find expected key|Psych::SyntaxError/, stdout)

    # The script should still process the valid YAML and generate output
    assert File.exist?('README.md'), "README.md was not generated"
    readme_content = File.read('README.md')
    assert_match(/TestTool/, readme_content)

    # Verify categorized files were also generated
    assert File.exist?('categorize/tags/test.md'), "Tag markdown was not generated"
    assert File.exist?('categorize/langs/Ruby.md'), "Lang markdown was not generated"
  end
end
