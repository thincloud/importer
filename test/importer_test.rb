# TODO: This needs work to make stand-alone in plugin
#
require File.dirname(__FILE__) + '/abstract_unit'
require File.dirname(__FILE__) + '/fixtures/organisation'
require File.dirname(__FILE__) + '/fixtures/area'

class ImporterTest < Test::Unit::TestCase

  def setup
    @organisations_data = File.dirname(__FILE__) + '/fixtures/organisations_data.csv'
    @areas_data = File.dirname(__FILE__) + '/fixtures/areas_data.csv'
    Area.create(:name => "South East England")
  end

  def test_should_import_csv_to_database
    Organisation.import(standard_options)

    organisation = Organisation.find_by_name("Curve21")
    assert_equal "Curve21", organisation.name
    assert_equal "South East England", organisation.area.name, "Should find linked area"
  end
    
  def test_should_ignore_specified_columns
    Organisation.destroy_all
    options = standard_options
    options[:ignore] = ['website']
    
    Organisation.import(options)
  
    assert_equal nil, Organisation.find_by_name("Curve21").website
  end
  
  def test_should_use_specified_columns
    Area.import(:from => @areas_data, :columns => ["name"])
    assert_not_nil Area.find_by_name("London")
  end
  
  def test_should_log_errors_on_missing_associations
    puts "TODO: Add error logging"
  end
    
  def test_should_log_errors_on_model_errors
    puts "TODO: Add error logging"
  end
  
  def test_should_read_csv_from_stringio
    csv_data = StringIO.new('"Apple","www.apple.com","info@apple.com"')
    Organisation.import(:from => csv_data, :columns => ["name","website","email"])
    assert_not_nil Organisation.find_by_name("Apple")
  end
  
  def standard_options
   standard_options = {:from => @organisations_data,
                       :map => {'Org' => 'name', 'Area' => 'area_id', 'Website' => 'website', 'EMail' => 'email'},
                       :associations => {'area_id' => lambda {|a| Area.find_by_name(a) } }
              }
  end

end