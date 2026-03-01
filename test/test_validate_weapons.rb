require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'yaml'

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
    FileUtils.remove_entry(@tmpdir)
  end

  def run_script
    `ruby "#{@script_path}" 2>&1`
  end

  def test_valid_yaml
    File.write('weapons/valid.yaml', {
      'type' => 'tool',
      'lang' => 'ruby',
      'url' => 'https://github.com/example/repo',
      'tags' => ['security']
    }.to_yaml)

    output = run_script
    clean_output = output.lines.reject { |l| l.include?("Is a directory") || l.strip.empty? }
    assert_empty clean_output
  end

  def test_empty_type
    File.write('weapons/empty_type.yaml', {
      'type' => '',
      'lang' => 'ruby',
      'url' => 'https://github.com/example/repo',
      'tags' => ['security']
    }.to_yaml)

    output = run_script
    assert_includes output, "./weapons/empty_type.yaml :: none-type\n"
  end

  def test_nil_type
    File.write('weapons/nil_type.yaml', {
      'type' => nil,
      'lang' => 'ruby',
      'url' => 'https://github.com/example/repo',
      'tags' => ['security']
    }.to_yaml)

    output = run_script
    assert_includes output, "./weapons/nil_type.yaml :: none-type\n"
  end

  def test_empty_lang_with_github_url
    File.write('weapons/empty_lang.yaml', {
      'type' => 'tool',
      'lang' => '',
      'url' => 'https://github.com/example/repo',
      'tags' => ['security']
    }.to_yaml)

    output = run_script
    assert_includes output, "./weapons/empty_lang.yaml :: none-lang\n"
  end

  def test_nil_lang_with_github_url
    File.write('weapons/nil_lang.yaml', {
      'type' => 'tool',
      'lang' => nil,
      'url' => 'https://github.com/example/repo',
      'tags' => ['security']
    }.to_yaml)

    output = run_script
    assert_includes output, "./weapons/nil_lang.yaml :: none-lang\n"
  end

  def test_empty_lang_without_github_url
    File.write('weapons/empty_lang_no_github.yaml', {
      'type' => 'tool',
      'lang' => '',
      'url' => 'https://example.com/repo',
      'tags' => ['security']
    }.to_yaml)

    output = run_script
    clean_output = output.lines.reject { |l| l.include?("Is a directory") || l.strip.empty? }
    assert_empty clean_output
  end

  def test_invalid_yaml
    File.write('weapons/invalid.yaml', "invalid: yaml: content: :")

    output = run_script
    clean_output = output.lines.reject { |l| l.include?("Is a directory") || l.strip.empty? }
    refute_empty clean_output
    assert_match(/Psych::SyntaxError|mapping values are not allowed/, output)
  end
end
