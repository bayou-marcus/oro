require 'minitest/autorun'
# require 'yaml'
# require_relative '../lib/oro/settings' # FIXME Should this even be needed?  See Rakefile for the fail.
# require_relative '../lib/oro/settings_parser' # FIXME Should this even be needed?  See Rakefile for the fail.

class TestPreference < Minitest::Test

  def setup
    @clio = '-w7 -p -n3 -i10 -c -dDeutsch'
    @PREFERENCE_FILE = Preference::PREFERENCE_FILE
    @prfs = Preference.instance # Creates preference file
  end

  def test_that_preference_file_exists
    assert FileTest.readable?(@PREFERENCE_FILE), "#{@PREFERENCE_FILE} is missing"
  end

  def test_reset_defaults_sets_defaults
    @prfs.reset_defaults
    assert_equal @prfs.get, YAML.load(File.read(Preference::DEFAULTS_FILE))
  end

  def test_get_returns_open_struct_with_format_and_config
    @prfs.set(@clio)
    structured_options = @prfs.get
    assert (structured_options.class.name == 'OpenStruct' and structured_options.to_h.has_key?(:format) and structured_options.to_h.has_key?(:config)), 'get_structured not OpenStruct or missing format or config'
  end

  def test_get_defaults_equals_defaults
    assert_equal @prfs.get_defaults, YAML.load(File.read(Preference::DEFAULTS_FILE))
  end

  def teardown
    remove_instance_variable(:@clio)
    remove_instance_variable(:@PREFERENCE_FILE)
    remove_instance_variable(:@prfs)
    # File.delete(@PREFERENCE_FILE) # FIXME "setup and teardown runs before/after each test" doesn't manage the preference file accurately so unable to test its creation; perhaps what the filesystem reports is out of sync
  end

end
