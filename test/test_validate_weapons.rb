require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'yaml'
require 'open3'

class TestValidateWeapons < Minitest::Test
  def setup
    @original_dir = Dir.pwd
    @script_path = File.join(@original_dir, 'scripts', 'validate_weapons.rb')

    @tmpdir = Dir.mktmpdir
    Dir.chdir(@tmpdir)
    Dir.mkdir('weapons')
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.remove_entry(@tmpdir) rescue nil
  end

  def create_weapon_file(filename, content)
    File.write(File.join('weapons', filename), content.to_yaml)
  end

  def run_script
    stdout, stderr, status = Open3.capture3("ruby", @script_path)
    output = stdout + stderr
    [output, status]
  end

  def clean_output(output)
    output.lines.reject { |l| l.include?("Is a directory") || l.strip.empty? }.join
  end

  def test_valid_yaml
    create_weapon_file('valid.yaml', {
      'type' => 'tool',
      'lang' => 'ruby',
      'url'  => 'https://github.com/example/repo',
      'tags' => ['security']
    })

    output, status = run_script
    assert status.success?
    assert_empty clean_output(output)
  end

  def test_empty_type
    create_weapon_file('empty_type.yaml', {
      'type' => '',
      'lang' => 'ruby',
      'url'  => 'https://github.com/example/repo',
      'tags' => ['security']
    })

    output, _ = run_script
    assert_includes output, "./weapons/empty_type.yaml :: none-type\n"
  end

  def test_nil_type
    create_weapon_file('nil_type.yaml', {
      'type' => nil,
      'lang' => 'ruby',
      'url'  => 'https://github.com/example/repo',
      'tags' => ['security']
    })

    output, _ = run_script
    assert_includes output, "./weapons/nil_type.yaml :: none-type\n"
  end

  def test_empty_lang_with_github_url
    create_weapon_file('empty_lang.yaml', {
      'type' => 'tool',
      'lang' => '',
      'url'  => 'https://github.com/example/repo',
      'tags' => ['security']
    })

    output, _ = run_script
    assert_includes output, "./weapons/empty_lang.yaml :: none-lang\n"
  end

  def test_nil_lang_with_github_url
    create_weapon_file('nil_lang.yaml', {
      'type' => 'tool',
      'lang' => nil,
      'url'  => 'https://github.com/example/repo',
      'tags' => ['security']
    })

    output, _ = run_script
    assert_includes output, "./weapons/nil_lang.yaml :: none-lang\n"
  end

  def test_empty_lang_without_github_url
    create_weapon_file('empty_lang_no_github.yaml', {
      'type' => 'tool',
      'lang' => '',
      'url'  => 'https://example.com/repo',
      'tags' => ['security']
    })

    output, status = run_script
    assert status.success?
    assert_empty clean_output(output)
  end

  def test_invalid_yaml_syntax_error
    File.write(File.join('weapons', 'invalid.yaml'), "invalid: yaml: content: :")

    output, status = run_script

    assert status.success?
    refute_empty clean_output(output)
    assert_match(/Psych::SyntaxError|mapping values are not allowed|did not find expected key/, output)
  end

  def test_malformed_yaml_is_rescued
    File.write(File.join('weapons', 'malformed.yaml'), ": malformed\nyaml:\n  -")

    output, status = run_script

    assert status.success?
    assert_match(/did not find expected key|malformed/, output)
  end
end