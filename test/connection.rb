ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "rails_test_db"
)

load File.dirname(__FILE__) + "/fixtures/schema.rb"
